#!/usr/bin/env bash
set -u

MODE="changed"
REPO_ROOT=""
FILES=()
BLOCKS=0
WARNS=0

usage() {
  cat <<'USAGE'
Usage:
  bash .codex/guardrails/run.sh --changed
  bash .codex/guardrails/run.sh --staged
  bash .codex/guardrails/run.sh --all
  bash .codex/guardrails/run.sh --files <path> [path ...]

Exit codes:
  0  no blocking findings
  1  one or more BLOCK findings
  2  usage or environment error
USAGE
}

find_repo_root() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  if [ -n "$root" ]; then
    printf '%s\n' "$root"
  else
    pwd -P
  fi
}

is_cs_file() {
  case "$1" in
    *.cs) return 0 ;;
    *) return 1 ;;
  esac
}

is_unity_serialized_file() {
  case "$1" in
    *.unity|*.prefab|*.asset) return 0 ;;
    *) return 1 ;;
  esac
}

existing_file() {
  [ -f "$1" ]
}

display_path() {
  local path="$1"
  case "$path" in
    "$REPO_ROOT"/*) printf '%s\n' "${path#"$REPO_ROOT"/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

emit_block() {
  local file="$1"
  local line="$2"
  local rule="$3"
  local message="$4"
  BLOCKS=$((BLOCKS + 1))
  printf 'BLOCK %s:%s [%s] %s\n' "$(display_path "$file")" "$line" "$rule" "$message"
}

emit_warn() {
  local file="$1"
  local line="$2"
  local rule="$3"
  local message="$4"
  WARNS=$((WARNS + 1))
  printf 'WARN %s:%s [%s] %s\n' "$(display_path "$file")" "$line" "$rule" "$message"
}

grep_rule() {
  local file="$1"
  local pattern="$2"
  local rule="$3"
  local message="$4"
  local line

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_block "$file" "$line" "$rule" "$message"
  done < <(grep -nE "$pattern" "$file" 2>/dev/null || true)
}

check_unity_editor_runtime() {
  local file="$1"
  local line

  if ! grep -qE 'using[[:space:]]+UnityEditor|UnityEditor\.' "$file" 2>/dev/null; then
    return
  fi

  if grep -q '#if[[:space:]]+UNITY_EDITOR' "$file" 2>/dev/null; then
    return
  fi

  line="$(grep -nE 'using[[:space:]]+UnityEditor|UnityEditor\.' "$file" 2>/dev/null | head -n 1 | cut -d: -f1)"
  emit_block "$file" "${line:-1}" "unityeditor-runtime" "UnityEditor usage in runtime code must be wrapped in #if UNITY_EDITOR."
}

check_monobehaviour_new_service() {
  local file="$1"
  local line

  if ! grep -qE ':[[:space:]]*MonoBehaviour\b' "$file" 2>/dev/null; then
    return
  fi

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_block "$file" "$line" "monobehaviour-new-service" "Do not instantiate services from MonoBehaviour; inject dependencies with VContainer."
  done < <(grep -nE 'new[[:space:]]+[A-Z][A-Za-z0-9_]*Service[[:space:]]*\(' "$file" 2>/dev/null || true)
}

check_concrete_service_dependency() {
  local file="$1"

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    emit_block "$file" "$line" "concrete-service-dependency" "Service constructors must depend on interfaces, not concrete service classes."
  done < <(awk '
    /class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*Service/ {
      className = $0
      sub(/^.*class[[:space:]]+/, "", className)
      sub(/[[:space:]:{(<].*$/, "", className)
    }
    className != "" {
      pattern = "(public|internal)[[:space:]]+" className "[[:space:]]*\\("
      if ($0 ~ pattern && $0 ~ /[,(][[:space:]]*[A-HJ-Z][A-Za-z0-9_]*Service[[:space:]]+[A-Za-z_][A-Za-z0-9_]*/) {
        print NR
      }
    }
  ' "$file" 2>/dev/null)
}

check_hot_paths() {
  local file="$1"

  while IFS='|' read -r kind line rule message; do
    [ "$kind" = "WARN" ] || continue
    emit_warn "$file" "$line" "$rule" "$message"
  done < <(awk -v file="$file" '
    function brace_delta(text, i, ch, delta) {
      delta = 0
      for (i = 1; i <= length(text); i++) {
        ch = substr(text, i, 1)
        if (ch == "{") delta++
        if (ch == "}") delta--
      }
      return delta
    }
    function emit(kind, line, rule, message) {
      print kind "|" line "|" rule "|" message
    }
    /(^|[^A-Za-z0-9_])(Update|FixedUpdate|LateUpdate|Tick|FixedTick|LateTick)[[:space:]]*\(/ {
      inHot = 1
      depth = 0
    }
    inHot {
      if ($0 ~ /GetComponent[[:space:]]*</ || $0 ~ /Camera\.main/ || $0 ~ /FindObjectOfType/ || $0 ~ /FindObjectsOfType/ || $0 ~ /tag[[:space:]]*==/ || $0 ~ /SendMessage[[:space:]]*\(/ || $0 ~ /BroadcastMessage[[:space:]]*\(/) {
        emit("WARN", NR, "hot-path-getcomponent", "Avoid expensive Unity calls inside hot paths; cache references or use serialized fields.")
      }
      if ($0 ~ /\.(Where|Select|ToArray|ToList|Any|First|Count)[[:space:]]*\(/) {
        emit("WARN", NR, "hot-path-linq", "Avoid LINQ in hot paths; it can allocate per frame.")
      }
      depth += brace_delta($0)
      if (depth <= 0 && $0 ~ /}/) {
        inHot = 0
      }
    }
  ' "$file" 2>/dev/null)
}

diff_for_file() {
  local file="$1"
  local rel

  rel="$(display_path "$file")"
  if [ "$MODE" = "staged" ]; then
    git -C "$REPO_ROOT" diff --cached -- "$rel" 2>/dev/null || true
  else
    git -C "$REPO_ROOT" diff -- "$rel" 2>/dev/null || true
    git -C "$REPO_ROOT" diff --cached -- "$rel" 2>/dev/null || true
  fi
}

check_serialized_rename() {
  local file="$1"
  local diff_text
  local line

  [ "$MODE" = "changed" ] || [ "$MODE" = "staged" ] || return
  is_cs_file "$file" || return

  diff_text="$(diff_for_file "$file")"
  [ -n "$diff_text" ] || return

  if ! printf '%s\n' "$diff_text" | grep -qE '^-[^-].*\[SerializeField\].*private'; then
    return
  fi

  if ! printf '%s\n' "$diff_text" | grep -qE '^\+[^+].*\[SerializeField\].*private'; then
    return
  fi

  if grep -q 'FormerlySerializedAs' "$file" 2>/dev/null; then
    return
  fi

  line="$(grep -n '\[SerializeField\]' "$file" 2>/dev/null | head -n 1 | cut -d: -f1)"
  emit_warn "$file" "${line:-1}" "serialized-rename" "SerializeField appears renamed without FormerlySerializedAs."
}

check_cs_file() {
  local file="$1"

  grep_rule "$file" 'UnityEvent(<|\b)|UnityEngine\.Events' "unity-event" "UnityEvent is forbidden; use IEventBus."
  grep_rule "$file" 'Time\.timeScale[[:space:]]*=' "time-scale" "Do not assign Time.timeScale directly; use PauseService via IEventBus."
  grep_rule "$file" 'static[[:space:]]+[^;{=]*(Instance|_instance)\b' "singleton" "Static singleton pattern is forbidden; use VContainer."
  grep_rule "$file" 'Input\.(GetKey|GetAxis|GetButton|mousePosition)' "legacy-input" "Legacy Input API is forbidden; use the New Input System."
  check_unity_editor_runtime "$file"
  check_monobehaviour_new_service "$file"
  check_concrete_service_dependency "$file"
  check_hot_paths "$file"
  check_serialized_rename "$file"
}

collect_changed_files() {
  {
    git -C "$REPO_ROOT" diff --name-only --diff-filter=ACMRTUXB HEAD -- 2>/dev/null || true
    git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMRTUXB -- 2>/dev/null || true
    git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || true
  } | sort -u
}

collect_staged_files() {
  git -C "$REPO_ROOT" diff --cached --name-only --diff-filter=ACMRTUXB -- 2>/dev/null | sort -u
}

collect_all_files() {
  {
    git -C "$REPO_ROOT" ls-files 2>/dev/null || true
    git -C "$REPO_ROOT" ls-files --others --exclude-standard 2>/dev/null || true
  } | sort -u
}

resolve_repo_path() {
  local path="$1"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s\n' "$REPO_ROOT/$path" ;;
  esac
}

parse_args() {
  if [ "$#" -eq 0 ]; then
    MODE="changed"
    return
  fi

  case "$1" in
    --changed)
      MODE="changed"
      ;;
    --staged)
      MODE="staged"
      ;;
    --all)
      MODE="all"
      ;;
    --files)
      MODE="files"
      shift
      if [ "$#" -eq 0 ]; then
        printf 'ERROR: --files requires at least one path.\n' >&2
        exit 2
      fi
      while [ "$#" -gt 0 ]; do
        FILES+=("$1")
        shift
      done
      return
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'ERROR: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac

  if [ "$#" -gt 1 ]; then
    printf 'ERROR: mode %s does not accept additional arguments.\n' "$MODE" >&2
    exit 2
  fi
}

main() {
  local raw_file
  local file

  parse_args "$@"
  REPO_ROOT="$(find_repo_root)"

  if [ "$MODE" = "changed" ]; then
    while IFS= read -r raw_file; do
      [ -n "$raw_file" ] && FILES+=("$raw_file")
    done < <(collect_changed_files)
  elif [ "$MODE" = "staged" ]; then
    while IFS= read -r raw_file; do
      [ -n "$raw_file" ] && FILES+=("$raw_file")
    done < <(collect_staged_files)
  elif [ "$MODE" = "all" ]; then
    while IFS= read -r raw_file; do
      [ -n "$raw_file" ] && FILES+=("$raw_file")
    done < <(collect_all_files)
  fi

  if [ "${#FILES[@]}" -eq 0 ]; then
    printf 'Guardrails: 0 block, 0 warn\n'
    exit 0
  fi

  for raw_file in "${FILES[@]}"; do
    file="$(resolve_repo_path "$raw_file")"
    existing_file "$file" || continue

    if is_unity_serialized_file "$file" && [ "$MODE" != "all" ]; then
      emit_block "$file" 1 "unity-serialized-text-edit" "Do not text-edit .unity, .prefab, or .asset files; use Unity MCP/editor tools."
      continue
    fi

    if is_cs_file "$file"; then
      check_cs_file "$file"
    fi
  done

  printf 'Guardrails: %s block, %s warn\n' "$BLOCKS" "$WARNS"

  if [ "$BLOCKS" -gt 0 ]; then
    exit 1
  fi
}

main "$@"

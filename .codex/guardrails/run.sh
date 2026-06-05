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

is_test_path() {
  printf '%s\n' "$1" | grep -qiE '(Tests?|Spec|EditModeTest|PlayModeTest)/'
}

is_editor_path() {
  printf '%s\n' "$1" | grep -qE '/Editor/'
}

is_service_domain_path() {
  printf '%s\n' "$1" | grep -qiE '(_Framework|Games/Abstracts|Games/Concretes|Game/Abstracts|Game/Concretes)/.*\.cs$'
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

check_protected_config_file() {
  local file="$1"
  local rel
  local base
  local ext
  local blocked=0

  rel="$(display_path "$file")"
  base="$(basename "$file")"
  ext="${base##*.}"

  case "$rel" in
    ProjectSettings/*.asset|*/ProjectSettings/*.asset)
      emit_block "$file" 1 "project-settings" "Do not text-edit ProjectSettings/*.asset; use Unity Editor or MCP tools."
      return 1
      ;;
    Packages/manifest.json|*/Packages/manifest.json)
      emit_block "$file" 1 "config-protection" "Do not text-edit Packages/manifest.json; use Unity Package Manager or intentional setup workflow."
      return 1
      ;;
    Packages/packages-lock.json|*/Packages/packages-lock.json)
      emit_block "$file" 1 "config-protection" "packages-lock.json is generated; never edit it by hand."
      return 1
      ;;
  esac

  if [ "$ext" = "asmdef" ] && ! printf '%s\n' "$rel" | grep -qiE '(EditModeTest|PlayModeTest)'; then
    emit_block "$file" 1 "config-protection" "Do not change non-test .asmdef files to work around code problems."
    blocked=1
  fi

  if [ "$ext" = "inputactions" ]; then
    emit_block "$file" 1 "config-protection" "Do not text-edit .inputactions files; edit them through the Unity Input System asset UI."
    blocked=1
  fi

  [ "$blocked" -eq 0 ]
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

check_service_unity_inheritance() {
  local file="$1"
  local line

  is_service_domain_path "$file" || return

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_block "$file" "$line" "service-unity-inheritance" "Domain/service files must not inherit MonoBehaviour or ScriptableObject; move Unity API to providers/views."
  done < <(grep -nE 'class[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]:,A-Za-z0-9_]*\b(MonoBehaviour|ScriptableObject)\b' "$file" 2>/dev/null || true)
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

check_runtime_gameobject_lifecycle() {
  local file="$1"
  local line

  is_test_path "$file" && return
  is_editor_path "$file" && return

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_block "$file" "$line" "new-gameobject" "new GameObject(...) is forbidden in runtime code; instantiate prefab-backed objects."
  done < <(grep -nE '\bnew[[:space:]]+GameObject[[:space:]]*\(' "$file" 2>/dev/null || true)

  if ! printf '%s\n' "$file" | grep -qiE '(Pool|Manager|Spawner)\.cs$'; then
    while IFS=: read -r line _; do
      [ -n "$line" ] || continue
      emit_warn "$file" "$line" "runtime-destroy" "Destroy(...) found outside Pool/Manager/Spawner; return pool-managed objects instead."
    done < <(grep -nE '\bDestroy[[:space:]]*\(' "$file" 2>/dev/null | grep -v 'OnDestroy' || true)
  fi
}

check_async_void() {
  local file="$1"
  local lifecycle='(Awake|Start|OnEnable|OnDisable|OnDestroy|OnApplicationQuit|OnApplicationPause|OnApplicationFocus|Reset|OnValidate|OnDrawGizmos|OnDrawGizmosSelected)'
  local line
  local content
  local method

  is_test_path "$file" && return

  while IFS=: read -r line content; do
    method="$(printf '%s\n' "$content" | grep -oE 'async[[:space:]]+void[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' | awk '{print $3}')"
    printf '%s\n' "$method" | grep -qE "^${lifecycle}$" && continue
    emit_warn "$file" "$line" "async-void" "async void swallows exceptions; use async UniTask and .Forget() for fire-and-forget calls."
  done < <(grep -nE 'async[[:space:]]+void[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null | grep -v '//' || true)
}

check_unitask_cancellation() {
  local file="$1"
  local line
  local content

  is_test_path "$file" && return

  while IFS=: read -r line content; do
    printf '%s\n' "$content" | grep -q 'CancellationToken' && continue
    printf '%s\n' "$content" | grep -qE '\boverride\b' && continue
    printf '%s\n' "$content" | grep -qE ';[[:space:]]*$' && continue
    emit_warn "$file" "$line" "unitask-cancellation" "async UniTask methods should accept a CancellationToken."
  done < <(grep -nE 'async[[:space:]]+UniTask(<[^>]+>)?[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(' "$file" 2>/dev/null | grep -v '//' || true)
}

check_unity_null_propagation() {
  local file="$1"
  local line

  is_test_path "$file" && return
  is_editor_path "$file" && return

  grep -qE 'using[[:space:]]+UnityEngine|MonoBehaviour|ScriptableObject|Component' "$file" 2>/dev/null || return

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_warn "$file" "$line" "unity-null-propagation" "Avoid ?. on Unity objects; use == null so destroyed-object checks work."
  done < <(grep -nE '(_[a-z][A-Za-z0-9_]*|transform|gameObject|Camera|Renderer|Animator|Rigidbody|Collider|AudioSource|ParticleSystem)\?\.' "$file" 2>/dev/null || true)

  while IFS=: read -r line _; do
    [ -n "$line" ] || continue
    emit_warn "$file" "$line" "unity-null-propagation" "Avoid 'is null' on Unity objects; use == null."
  done < <(grep -nE '(_[a-z][A-Za-z0-9_]*|transform|gameObject)[[:space:]]+is[[:space:]]+null' "$file" 2>/dev/null || true)
}

check_getcomponent_in_awake() {
  local file="$1"
  local line

  is_test_path "$file" && return

  while IFS= read -r line; do
    [ -n "$line" ] && emit_warn "$file" "$line" "awake-getcomponent" "Prefer [SerializeField] Inspector assignment instead of GetComponent in Awake."
  done < <(awk '
    /(^|[[:space:]])(void|async)[[:space:]]+Awake[[:space:]]*\(/ { inAwake=1; depth=0 }
    inAwake {
      if ($0 ~ /GetComponent(InChildren)?[[:space:]]*[<(]/) {
        print NR
      }
      for (i = 1; i <= length($0); i++) {
        c = substr($0, i, 1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      if (depth <= 0 && $0 ~ /}/) inAwake=0
    }
  ' "$file" 2>/dev/null)
}

check_ecs_enum_byte_base() {
  local file="$1"
  local line
  local content

  if ! printf '%s\n' "$file" | grep -qE '/Ecs/' && ! grep -qE '(IEvent|IComponentData)' "$file" 2>/dev/null; then
    return
  fi

  while IFS=: read -r line content; do
    printf '%s\n' "$content" | grep -qE 'enum[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*byte' && continue
    emit_block "$file" "$line" "enum-byte-base" "Enums in ECS/IEvent context must declare ': byte'."
  done < <(grep -nE 'enum[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null | grep -v '//' || true)
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
  check_service_unity_inheritance "$file"
  check_concrete_service_dependency "$file"
  check_runtime_gameobject_lifecycle "$file"
  check_async_void "$file"
  check_unitask_cancellation "$file"
  check_unity_null_propagation "$file"
  check_getcomponent_in_awake "$file"
  check_ecs_enum_byte_base "$file"
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

    if ! check_protected_config_file "$file"; then
      continue
    fi

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

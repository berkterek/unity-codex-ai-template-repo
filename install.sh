#!/usr/bin/env bash
# Bootstrap a Unity project with this Codex template.
#
# Usage:
#   ./install.sh /path/to/UnityProject
#   ./install.sh
#   ./install.sh /path/to/UnityProject --force
#   ./install.sh --force /path/to/UnityProject
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *) TARGET="$arg" ;;
  esac
done
TARGET="${TARGET:-$PWD}"

echo "Unity Codex AI Template installer"
echo "  source : $SOURCE_DIR"
echo "  target : $TARGET"
echo

if [ ! -d "$TARGET" ]; then
  echo "ERROR: target directory does not exist: $TARGET" >&2
  exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
  echo "ERROR: $TARGET is not a git repo. Run 'git init' there first." >&2
  exit 1
fi

if [ -d "$TARGET/.codex" ] && [ "$FORCE" != "true" ]; then
  echo "ERROR: $TARGET/.codex already exists. Re-run with --force to overwrite." >&2
  exit 1
fi

copy_dir() {
  local name="$1"
  local source="$SOURCE_DIR/$name"
  local target="$TARGET/$name"

  [ -d "$source" ] || return 0
  if [ -e "$target" ]; then
    if [ "$FORCE" = "true" ]; then
      rm -rf "$target"
    else
      echo "Skipping $name (already exists; use --force to overwrite)."
      return 0
    fi
  fi
  echo "Copying $name/ ..."
  cp -R "$source" "$target"
}

copy_file() {
  local name="$1"
  local source="$SOURCE_DIR/$name"
  local target="$TARGET/$name"

  [ -f "$source" ] || return 0
  if [ -e "$target" ] && [ "$FORCE" != "true" ]; then
    echo "Skipping $name (already exists; use --force to overwrite)."
    return 0
  fi
  echo "Copying $name ..."
  cp "$source" "$target"
}

copy_dir ".codex"
copy_dir ".githooks"
copy_dir ".github"

copy_file "AGENTS.md"
copy_file ".editorconfig"
copy_file ".gitattributes"
copy_file ".gitignore"

echo "Setting script permissions ..."
find "$TARGET/.codex" -name "*.sh" -print0 | xargs -0 chmod +x
if [ -d "$TARGET/.githooks" ]; then
  find "$TARGET/.githooks" -type f -print0 | xargs -0 chmod +x
fi

echo "Clearing generated state from copied template ..."
rm -f "$TARGET/.codex/graph/graph.json" \
      "$TARGET/.codex/graph/graph.json.bak" \
      "$TARGET/.codex/graph/.last-build" 2>/dev/null || true
find "$TARGET/.codex/graph/cache" -type f ! -name ".gitkeep" -delete 2>/dev/null || true
rm -rf "$TARGET/.codex/project/state" \
       "$TARGET/.codex/project/logs" \
       "$TARGET/.codex/runtime" 2>/dev/null || true

cat <<'NEXTSTEPS'

SUCCESS - template installed.

NEXT STEPS:

1. Open the target project in Codex.

2. Read the required startup files:
   - AGENTS.md
   - .codex/packs/unity-game/guides/guardrails.md
   - .codex/project/PROJECT.md
   - .codex/project/RULES.md

3. Fill the project overlay files in .codex/project/.

4. Enable the optional local git hook once per clone:
   git config core.hooksPath .githooks

5. Run guardrails at workflow gates:
   bash .codex/guardrails/run.sh --changed
NEXTSTEPS

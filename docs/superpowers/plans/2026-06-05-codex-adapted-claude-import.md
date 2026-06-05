# Codex-Adapted Claude Import Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the useful Unity Claude template improvements into this Codex template without copying Claude-only runtime systems.

**Architecture:** Keep `.codex/` as the single runtime source. Convert Claude hook behavior into explicit Codex guardrail runner checks, port graph-builder warnings into `.codex/graph`, and add only tool-neutral root project hygiene files plus a Codex installer.

**Tech Stack:** Bash, POSIX shell utilities, Python 3 stdlib snippets already used by graph tooling, jq for graph tests, Markdown docs.

---

## File Structure

- Modify: `.codex/guardrails/run.sh`
  - Add reusable skip helpers and new check functions for runtime GameObject creation, async, UniTask cancellation, Unity null checks, Awake component lookup, ECS enum base type, config protection, and MonoBehaviour/ScriptableObject inheritance in service/domain files.
- Modify: `.codex/guardrails/test/verify-guardrails.sh`
  - Add red tests for each new guardrail behavior before implementation.
- Modify: `.codex/guardrails/README.md`
  - Document the expanded BLOCK and WARN lists.
- Modify: `.codex/packs/unity-game/guides/guardrails.md`
  - Align runtime instantiate wording with the stricter `new GameObject(...)` rule and document protected config files.
- Modify: `.codex/packs/unity-game/guides/hooks-blocking.md`
  - Update checklist parity with the executable Codex checks.
- Modify: `.codex/packs/unity-game/guides/hooks-warning.md`
  - Update warning checklist parity with the executable Codex checks.
- Modify: `.codex/graph/graph-builder.sh`
  - Port full-build MCP cache invalidation and validation warnings for stale prefab paths and missing scripts.
- Modify: `.codex/packs/unity-game/guides/knowledge-graph.md`
  - Document the graph-builder behavior with Codex paths.
- Create: `.editorconfig`
  - Add Unity-safe whitespace and newline defaults.
- Create: `.gitattributes`
  - Add Unity YAML merge hints and binary asset attributes.
- Create: `.gitignore`
  - Ignore local/generated artifacts only.
- Create: `install.sh`
  - Add Codex-specific installer for copying `.codex`, `.githooks`, `.github`, and `AGENTS.md`.

---

### Task 1: Guardrail Tests

**Files:**
- Modify: `.codex/guardrails/test/verify-guardrails.sh`

- [ ] **Step 1: Add failing BLOCK tests**

Add `assert_block` cases for:

```bash
assert_block \
  "Runtime new GameObject is blocked" \
  "Assets/Scripts/BadNewGameObject.cs" \
  'using UnityEngine;
public sealed class BadNewGameObject
{
    public GameObject Create()
    {
        return new GameObject("Bad");
    }
}' \
  "new-gameobject"
```

```bash
assert_block \
  "ECS enum without byte base is blocked" \
  "Assets/Scripts/Game/Ecs/BadEcsEnum.cs" \
  'using Unity.Entities;
public struct BadEcsEnumComponent : IComponentData
{
    public State Value;
    public enum State
    {
        Idle,
        Moving
    }
}' \
  "enum-byte-base"
```

```bash
assert_block \
  "ProjectSettings asset edit is blocked" \
  "ProjectSettings/ProjectSettings.asset" \
  '%YAML 1.1
PlayerSettings:
  companyName: Bad' \
  "project-settings"
```

```bash
assert_block \
  "Runtime inputactions edit is blocked" \
  "Assets/Input/PlayerControls.inputactions" \
  '{"name":"PlayerControls"}' \
  "config-protection"
```

```bash
assert_block \
  "Non-test asmdef edit is blocked" \
  "Assets/Scripts/Game.Game.asmdef" \
  '{"name":"Game.Game"}' \
  "config-protection"
```

```bash
assert_block \
  "MonoBehaviour inheritance in service folder is blocked" \
  "Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs" \
  'using UnityEngine;
public sealed class AudioService : MonoBehaviour
{
}' \
  "service-unity-inheritance"
```

- [ ] **Step 2: Add failing WARN tests**

Add `assert_warn` cases for:

```bash
assert_warn \
  "Destroy outside pool manager warning" \
  "Assets/Scripts/BadDestroy.cs" \
  'using UnityEngine;
public sealed class BadDestroy : MonoBehaviour
{
    public void Remove(GameObject target)
    {
        Destroy(target);
    }
}' \
  "runtime-destroy"
```

```bash
assert_warn \
  "async void warning outside lifecycle" \
  "Assets/Scripts/WarnAsyncVoid.cs" \
  'public sealed class WarnAsyncVoid
{
    public async void Load()
    {
    }
}' \
  "async-void"
```

```bash
assert_warn \
  "UniTask without CancellationToken warning" \
  "Assets/Scripts/WarnUniTask.cs" \
  'using Cysharp.Threading.Tasks;
public sealed class WarnUniTask
{
    public async UniTask LoadAsync()
    {
    }
}' \
  "unitask-cancellation"
```

```bash
assert_warn \
  "Unity null propagation warning" \
  "Assets/Scripts/WarnNullPropagation.cs" \
  'using UnityEngine;
public sealed class WarnNullPropagation : MonoBehaviour
{
    [SerializeField] private Transform _target;
    public void Ping()
    {
        _target?.gameObject.SetActive(true);
    }
}' \
  "unity-null-propagation"
```

```bash
assert_warn \
  "GetComponent in Awake warning" \
  "Assets/Scripts/WarnAwakeGetComponent.cs" \
  'using UnityEngine;
public sealed class WarnAwakeGetComponent : MonoBehaviour
{
    private Rigidbody _body;
    private void Awake()
    {
        _body = GetComponent<Rigidbody>();
    }
}' \
  "awake-getcomponent"
```

- [ ] **Step 3: Verify tests fail before implementation**

Run:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
```

Expected: FAIL entries for the new tests because `.codex/guardrails/run.sh` does not emit the new rule IDs yet.

---

### Task 2: Guardrail Implementation

**Files:**
- Modify: `.codex/guardrails/run.sh`

- [ ] **Step 1: Add skip and path helpers**

Add helpers near existing file-type helpers:

```bash
is_test_path() {
  printf '%s\n' "$1" | grep -qiE '(Tests?|Spec|EditModeTest|PlayModeTest)/'
}

is_editor_path() {
  printf '%s\n' "$1" | grep -qE '/Editor/'
}

is_service_domain_path() {
  printf '%s\n' "$1" | grep -qiE '(_Framework|Games/Abstracts|Games/Concretes|Game/Abstracts|Game/Concretes)/.*\.cs$'
}
```

- [ ] **Step 2: Add config protection checks**

Add `check_protected_config_file()` and call it for every existing file before C# checks:

```bash
check_protected_config_file() {
  local file="$1"
  local rel
  local base
  local ext

  rel="$(display_path "$file")"
  base="$(basename "$file")"
  ext="${base##*.}"

  case "$rel" in
    ProjectSettings/*.asset|*/ProjectSettings/*.asset)
      emit_block "$file" 1 "project-settings" "Do not text-edit ProjectSettings/*.asset; use Unity Editor or MCP tools."
      return
      ;;
    Packages/manifest.json|*/Packages/manifest.json)
      emit_block "$file" 1 "config-protection" "Do not text-edit Packages/manifest.json; use Unity Package Manager or intentional setup workflow."
      return
      ;;
    Packages/packages-lock.json|*/Packages/packages-lock.json)
      emit_block "$file" 1 "config-protection" "packages-lock.json is generated; never edit it by hand."
      return
      ;;
  esac

  if [ "$ext" = "asmdef" ] && ! printf '%s\n' "$rel" | grep -qiE '(EditModeTest|PlayModeTest)'; then
    emit_block "$file" 1 "config-protection" "Do not change non-test .asmdef files to work around code problems."
  fi

  if [ "$ext" = "inputactions" ]; then
    emit_block "$file" 1 "config-protection" "Do not text-edit .inputactions files; edit them through the Unity Input System asset UI."
  fi
}
```

- [ ] **Step 3: Add runtime and async checks**

Add functions:

```bash
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
```

- [ ] **Step 4: Add Unity-specific warnings and service inheritance checks**

Add functions:

```bash
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

  is_test_path "$file" && return

  awk '
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
  ' "$file" 2>/dev/null | while IFS= read -r line; do
    [ -n "$line" ] && emit_warn "$file" "$line" "awake-getcomponent" "Prefer [SerializeField] Inspector assignment instead of GetComponent in Awake."
  done
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
```

- [ ] **Step 5: Add ECS enum base check and wire all checks**

Add:

```bash
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
```

Then call the new functions from `check_cs_file()` and call
`check_protected_config_file "$file"` in the main file loop before serialized
Unity file handling.

- [ ] **Step 6: Verify guardrails pass**

Run:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
```

Expected: all guardrail unit tests pass.

---

### Task 3: Graph Builder Port

**Files:**
- Modify: `.codex/graph/graph-builder.sh`
- Modify: `.codex/packs/unity-game/guides/knowledge-graph.md`

- [ ] **Step 1: Add graph validation behavior**

Port from Claude while preserving `.codex/project/FEATURES.json`:

```bash
# --full forces fresh extraction — ignore cache age
[[ "$MODE" == "full" ]] && MCP_AGE=9999
```

Add stale prefab detection using env vars so Python does not lose stdin to the
heredoc:

```bash
STALE_PATH_WARNINGS="[]"
if [[ "$MCP_PREFABS" != "[]" && "$MCP_PREFABS" != "null" ]]; then
  STALE_PATH_WARNINGS=$(MCP_PREFABS_JSON="$MCP_PREFABS" UNITY_FOLDER="$UNITY_FOLDER" python3 <<'PYEOF'
import json, os, sys
prefabs = json.loads(os.environ['MCP_PREFABS_JSON'])
unity_folder = os.environ.get('UNITY_FOLDER', '.')
warnings = []
for p in prefabs:
    path = p.get("path", "")
    disk_path = path if unity_folder == "." else os.path.join(unity_folder, path)
    if path and not os.path.exists(disk_path):
        warnings.append({
            "code": "STALE_PREFAB_PATH",
            "message": "Prefab path no longer exists on disk: " + path,
            "entity": p.get("name", "?")
        })
if warnings:
    print("graph-builder: STALE_PREFAB_PATH — " + str(len(warnings)) + " stale prefab(s) detected. Run /build-knowledge-graph with MCP to refresh.", file=sys.stderr)
print(json.dumps(warnings))
PYEOF
  )
fi
```

Add missing script detection:

```bash
MISSING_SCRIPT_WARNINGS="[]"
MISSING_INPUT=$(jq -n --argjson scenes "$MCP_SCENES" --argjson prefabs "$MCP_PREFABS" \
  '{scenes: $scenes, prefabs: $prefabs}' 2>/dev/null || echo '{"scenes":[],"prefabs":[]}')
[[ -z "$MISSING_INPUT" ]] && MISSING_INPUT='{"scenes":[],"prefabs":[]}'

MISSING_SCRIPT_WARNINGS=$(MISSING_INPUT_JSON="$MISSING_INPUT" python3 <<'PYEOF'
import json, os, sys

data = json.loads(os.environ['MISSING_INPUT_JSON'])
warnings = []

def check_go(go, scene_name, path=""):
    full_path = (path + "/" + go["name"]) if path else go["name"]
    if go.get("has_missing_scripts"):
        warnings.append({
            "code": "MISSING_SCRIPT",
            "message": "Null component (missing/deleted script) on: " + full_path + " in scene: " + scene_name,
            "entity": go["name"],
            "scene": scene_name
        })
    for child in go.get("children", []):
        check_go(child, scene_name, full_path)

for scene in data.get("scenes", []):
    scene_name = scene.get("name", "?")
    for go in scene.get("gameObjects", scene.get("gameobjects", [])):
        check_go(go, scene_name)

for prefab in data.get("prefabs", []):
    if prefab.get("has_missing_scripts"):
        warnings.append({
            "code": "MISSING_SCRIPT",
            "message": "Null component (missing/deleted script) on prefab: " + prefab.get("path", prefab.get("name", "?")),
            "entity": prefab.get("name", "?")
        })

if warnings:
    print("graph-builder: MISSING_SCRIPT — " + str(len(warnings)) + " missing script(s) detected.", file=sys.stderr)
print(json.dumps(warnings))
PYEOF
)
```

Pass `stale_warnings` and `missing_warnings` into the final jq assembly and set:

```jq
validation: { errors: [], warnings: ($stale_warnings + $missing_warnings) }
```

- [ ] **Step 2: Update graph docs**

Add Codex-specific notes to `.codex/packs/unity-game/guides/knowledge-graph.md`
covering `--full`, `STALE_PREFAB_PATH`, `MISSING_SCRIPT`, env-var JSON passing,
subfolder path handling, and `gameObjects`/`gameobjects` casing.

- [ ] **Step 3: Verify graph builder**

Run:

```bash
bash .codex/graph/test/verify-graphify.sh --json
```

Expected: exit 0. Template-mode skips are acceptable and must be reported.

---

### Task 4: Repo Hygiene and Installer

**Files:**
- Create: `.editorconfig`
- Create: `.gitattributes`
- Create: `.gitignore`
- Create: `install.sh`

- [ ] **Step 1: Add `.editorconfig`**

Use the Unity-safe content from the design.

- [ ] **Step 2: Add `.gitattributes`**

Use Unity YAML merge attributes and binary asset attributes from the Claude repo.

- [ ] **Step 3: Add `.gitignore`**

Ignore only:

```gitignore
.DS_Store
config.ini
.codex/graph/graph.json
.codex/graph/graph.json.bak
.codex/graph/*.tmp
.codex/graph/cache/*
!.codex/graph/cache/.gitkeep
.codex/graph/.last-build
.codex/project/state/
.codex/project/logs/
.codex/runtime/
```

- [ ] **Step 4: Add Codex installer**

Create `install.sh` that parses optional `--force`, validates target git repo,
copies `.codex`, `.githooks`, `.github`, and `AGENTS.md`, clears generated
state/cache files, and prints Codex-specific next steps.

- [ ] **Step 5: Syntax-check installer**

Run:

```bash
bash -n install.sh
```

Expected: no output and exit 0.

---

### Task 5: Documentation and Final Verification

**Files:**
- Modify: `.codex/guardrails/README.md`
- Modify: `.codex/packs/unity-game/guides/guardrails.md`
- Modify: `.codex/packs/unity-game/guides/hooks-blocking.md`
- Modify: `.codex/packs/unity-game/guides/hooks-warning.md`

- [ ] **Step 1: Update docs**

Document every new BLOCK/WARN rule added to `run.sh`.

- [ ] **Step 2: Run all focused verification**

Run:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
bash .codex/guardrails/test/verify-integration.sh
bash -n install.sh
bash .codex/graph/test/verify-graphify.sh --json
```

Expected: all exit 0. Report graph template-mode skips if present.

- [ ] **Step 3: Review changed files**

Run:

```bash
git status --short
git diff -- . ':!.DS_Store' ':!config.ini'
```

Expected: only scoped import files plus the two docs created for this workflow are changed. Existing `.DS_Store` and `config.ini` remain untouched.

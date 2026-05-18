# Unity Bug Fixer

Diagnoses and fixes Unity bugs. Reads console errors via MCP, checks common Unity-specific causes, uses `unity_reflect` for live API inspection.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- Relevant source files identified during diagnosis.

## Diagnosis Flow

### Step 1: Gather Evidence
- `read_console` via MCP — get errors, warnings, stack traces
- Read the bug description carefully
- Grep codebase for error message terms

### Step 2: Check Common Unity Causes

1. **NullReferenceException**
   - Missing serialized reference (field not assigned in Inspector)
   - Destroyed object accessed (`?.` should be `== null`)
   - Execution order issue (Awake/Start cross-object ordering)
   - `GetComponent` returning null — missing `[RequireComponent]`

2. **Missing Script Reference**
   - Class name doesn't match file name
   - Script renamed without updating references
   - Assembly definition issue

3. **Coroutine Issues**
   - Coroutine stopped by `SetActive(false)`
   - `new WaitForSeconds` in tight loop (allocation)

4. **Serialization Data Loss**
   - Field renamed without `[FormerlySerializedAs]`
   - Field type changed
   - Public field made private without `[SerializeField]`

5. **Physics Issues**
   - Wrong collision layer matrix
   - Checking physics in `Update` instead of `FixedUpdate`
   - Transform change then immediate raycast (needs `Physics.SyncTransforms`)

6. **Editor vs Build Discrepancy**
   - `UnityEditor` namespace without `#if UNITY_EDITOR`
   - Platform-specific code without fallback

### Step 3: Live Inspection via MCP
- `unity_reflect` — inspect live object state
- `manage_components` — read component configurations
- `read_console` — re-check after applying fix

## Fix Flow

1. Identify root cause (not symptom)
2. Apply minimal fix — don't refactor unrelated code
3. Verify via `read_console` — confirm error is gone
4. If fix involves serialization changes, always add `[FormerlySerializedAs]`

## Rules

- Don't suppress errors with try/catch unless genuinely expected
- Don't add null checks everywhere — find WHY it's null
- Don't change execution order as a band-aid
- Don't edit scene/prefab files directly — use MCP

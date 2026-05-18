# Unity Verifier

Verify-fix loop — reviews code changes, auto-fixes common issues, re-verifies up to 3 iterations. Used after coder passes.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- Changed `.cs` files.

## Loop Protocol

Max **3 iterations**. Track current iteration number explicitly.

### Step 1: Scope Changes

```bash
git diff --name-only HEAD
git diff --cached --name-only
```

Filter to `.cs` files. If none changed, report "No C# changes to verify" and exit.

### Step 2: Review

**Auto-Fixable Issues** (fix automatically):
- Missing `[FormerlySerializedAs("oldName")]` on renamed `[SerializeField]` fields
- `?.` or `is null` on Unity objects → `== null`
- `tag == "string"` → `CompareTag("string")`
- `GetComponent<T>()` / `Camera.main` / `FindObjectOfType` in Update → cache in Awake
- Missing `#if UNITY_EDITOR` guard around `UnityEditor` usage in runtime code
- `new WaitForSeconds()` in Update → cache as field
- `async void` → `async UniTaskVoid`
- `SendMessage` / `BroadcastMessage` → flag for replacement with IEventBus

**Requires Human Judgment** (report, don't fix):
- Architecture concerns (god classes, deep inheritance)
- Design pattern choices
- Performance tradeoffs that change behavior
- Missing tests for complex logic

### Step 3: Fix

For each auto-fixable issue:
1. Read the file
2. Apply minimal fix via Edit
3. Log what changed and why

### Step 4: Test

**MCP connected:**

```
refresh_unity   → trigger recompile
read_console    → check for compilation errors
run_tests       → run Edit Mode test suite
```

**MCP disconnected / not installed:** Fall back to dotnet CLI:

```bash
dotnet build   # compile check
dotnet test    # test run
```

Note in the report which path was used.

If tests fail due to a fix you applied, revert that specific fix and flag for human review.

### Step 5: Re-Verify Decision

- Fixes applied → increment counter, go back to Step 2
- No auto-fixable issues remain → Final Report
- Iteration 3 reached → Final Report regardless

## Final Report

```
## Verify-Fix Loop Results

**Iterations:** N of 3
**Files scanned:** N

### Auto-Fixed
- `File.cs:N` — description of fix

### Requires Human Review
- `File.cs` — description of issue

### Test Results
- Compilation: PASS/FAIL
- Tests: N passed, N failed
```

## Rules

- Minimal fixes only — don't refactor or add features
- One concern per fix
- Explain every change
- Preserve behavior — fixes must not change runtime behavior

# Fix — Bug Investigation and Regression Pipeline

Fixes a bug using a five-step pipeline: investigate root cause, write a failing
regression test, fix to make it pass, review, commit.

## Usage

```
/fix <bug description>
/fix BayManager throws NullReferenceException when a car exits during FlowEngine tick
```

If no argument is given, ask: "Describe the bug."

## Pipeline

```
[1] INVESTIGATE → [2] REGRESSION TEST → [3] FIX → [4] VALIDATE → [5] REVIEW → [6] COMMIT
```

---

## Inputs To Read

Before starting, read:

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/rules/testing.md`
- `.codex/packs/unity-game/agents/debugger.md`

---

## Step 1 — Investigate

Act as the debugger agent
(`.codex/packs/unity-game/agents/debugger.md`):

1. Read the relevant source files to understand the code paths involved.
2. Identify the root cause (not just symptoms).
3. Identify all files that need to change.

Output format:

```
ROOT CAUSE: <one sentence>

AFFECTED FILES:
- <file path> — <what needs to change>

REPRODUCTION PATH:
<step-by-step sequence of calls that leads to the bug>
```

Show the investigation output to the user. Ask: "Root cause found — proceed?
(yes / stop)"

If **stop** → abort.

---

## Step 2 — Regression Test

Write a failing regression test that reproduces this bug BEFORE any fix:

1. The test must FAIL right now.
2. The test must PASS once the root cause is fixed.
3. The test serves as a permanent regression guard.
4. Do NOT fix the bug in this step.

Follow `.codex/packs/unity-game/rules/testing.md` and
`.codex/packs/unity-game/guides/nsubstitute.md`.

If blocked → stop and show the blocker.

---

## Step 3 — Fix

Act as the coder agent (`.codex/packs/unity-game/agents/coder.md`):

1. Fix only what the root cause analysis identified.
2. Make the regression test from Step 2 pass.
3. Do NOT modify the test files.
4. Do NOT refactor surrounding code.
5. Follow all architecture rules.

If blocked → stop and show the blocker.

---

## Step 4 — Validate

Use Unity MCP to verify the project compiles and all tests pass:

1. `mcp__UnityMCP__refresh_unity` — trigger script recompile.
2. Wait until `isCompiling` is false.
3. `mcp__UnityMCP__read_console` type "Error" — check for compile errors.
4. If compile errors → fix (max 2 passes), re-validate.
5. `mcp__UnityMCP__run_tests` — run all Edit Mode tests.
6. If tests fail → fix implementation (max 2 passes), re-validate.
7. After 2 failed passes → show all errors, ask `skip` or `stop`.

---

## Step 5 — Review

Review the fix against these criteria:

1. Regression test passes; test file was not modified.
2. Fix addresses the root cause, not just the symptom.
3. Fix does not introduce new bugs or regressions.
4. Architecture — VContainer DI, no singletons.
5. Performance — no allocations in Update/FixedUpdate.
6. UniTask — no `async void`, CancellationToken on every async method.
7. Unity null safety — no `?.` or `is null` on UnityEngine objects.

If issues found → fix and re-review (max 3 passes). After 3 failed passes →
show remaining issues, ask `skip` or `stop`.

---

## Step 6 — Commit

Act as the committer agent (`.codex/packs/unity-game/agents/committer.md`):

1. `git status && git diff`
2. Stage only files related to this fix.
3. Commit message format: `fix: <short description in English>`.
4. One commit.
5. Do NOT push.

---

## Completion

Print:

```
## Fixed
Bug: [description]
Root cause: [one sentence]
Commit: [hash] — [message]
Validation: PASS
Review: PASS
```

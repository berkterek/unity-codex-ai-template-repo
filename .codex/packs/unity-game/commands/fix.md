# Fix — Bug Investigation and Regression Pipeline

Fixes a bug using a five-agent TDD pipeline: debugger finds root cause, test writer writes a failing regression test, coder fixes to make it pass, reviewer checks, committer commits.

## Usage

```
/fix <bug description>
/fix BayManager throws NullReferenceException when a car exits during FlowEngine tick
```

If no argument is given, ask: "Describe the bug."

## Pipeline

```
[1] DEBUGGER → [2] TEST WRITER → [3] CODER → [4] VALIDATOR ⟲ → [5] REVIEWER ⟲ → [5.5] VERIFIER → [5.7] SILENT FAILURE AUDIT → [6] COMMITTER
```

---

## Step 0 — Review Mode

Read `production/review-mode.txt` (default: `lean` if file missing):

| Mode | Effect |
|------|--------|
| `solo` | Skip Test Writer and Reviewer — Coder → Committer only. |
| `lean` | Standard pipeline. |
| `full` | Standard pipeline + unity-developer second review always active. |

---

## Step 0.5 — Complexity Scoring

Before spawning any agents, score the task complexity (0.0–1.0):

| Score | Label | Pipeline |
|-------|-------|----------|
| 0.0–0.3 | **Simple** | Spawn Coder directly — skip Debugger and Test Writer |
| 0.4–0.6 | **Medium** | Full pipeline |
| 0.7–1.0 | **Complex** | Full pipeline + unity-developer review after Reviewer |

Scoring signals: new module folder +0.3, IEventBus events +0.2, ECS/Addressables +0.3, AppScope/InputView/Installer +0.2, single method −0.3.

Print:
```
Complexity: [score] — [Label]
Rationale: [one sentence]
Review Mode: [solo | lean | full]
```

### SCOPE_GATE

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: bug description, complexity score.
Wait for `go` before spawning any agents.

After receiving `go`:
```bash
mkdir -p .codex/state && echo '{"gate":"SCOPE_GATE","pipeline":"fix","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .codex/state/gate-cleared
```

---

## Inputs To Read

- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/rules/testing.md`

---

## Step 1 — Debugger

**If complexity score ≥ 0.4:** Spawn **unity-fixer** and **unity-scout** simultaneously.

**If complexity score < 0.4 (Simple):** Spawn unity-fixer only, skip to Step 3 (no Test Writer).

Spawn a **unity-fixer** subagent:

```
You are a senior Unity engineer specializing in root cause analysis. Investigate the following bug.

## Bug Report
$BUG_DESCRIPTION

## Project Context
- Read .codex/project/RULES.md for architecture overview
- VContainer DI, UniTask async, IEventBus for events

## Your Task
1. Read the relevant source files to understand the code paths involved.
2. Identify the root cause (not just symptoms).
3. Identify all files that need to change.

## Output Format
ROOT CAUSE: <one sentence>

AFFECTED FILES:
- <file path> — <what needs to change>

REPRODUCTION PATH:
<step-by-step sequence of calls that leads to the bug>

DO NOT fix anything. Report only.
```

### unity-scout Agent Prompt (complexity ≥ 0.4 only)

```
You are a Unity risk analyst. While the debugger investigates, scan in parallel for Unity-specific risk patterns.

BUG: $BUG_DESCRIPTION

Scan for:
- VContainer registration gaps or scope hierarchy issues
- UniTask async methods missing CancellationToken or using async void
- Input System lifecycle violations (missing Enable/Disable)
- ECS structural changes outside EntityCommandBuffer
- Addressables handles not released
- Unity null check violations (?. or is null on UnityEngine objects)
- Missing [Inject] Construct() methods on MonoBehaviours

Output:
UNITY_RISKS:
- [risk type] — [file:line] — [description]
OR: UNITY_RISKS: none
```

### Merge (after both agents complete)

Combine into unified output and show to user. Ask: "Root cause found — proceed? (yes / stop)"

If **stop** → abort.

**BREAKING_GATE:** If affected files > 3, show the BREAKING_GATE from `.codex/packs/unity-game/guides/director-gates.md`. Show full affected file list. Wait for `go` or `stop`.

---

## Step 2 — Find Existing Test File

For each file in `$DEBUGGER_AFFECTED_FILES`:
```bash
find . -name "[ClassName]Tests.cs" -path "*/Tests/*"
```

- **Test file found** → Test Writer adds a regression test case to that file.
- **No test file** → Test Writer creates a new file in the correct test assembly.
- **NoTest decision** → skip Step 3, proceed directly to Step 3 (Coder).

---

## Step 3 — Test Writer (skip in `solo` mode or Simple complexity)

Spawn a **tester** subagent:

```
Read .codex/packs/unity-game/agents/tester.md for your role and testing philosophy.
Read .codex/packs/unity-game/rules/testing.md for project-specific rules.
Read .codex/project/RULES.md for project architecture.

## Bug
$BUG_DESCRIPTION

## Root Cause
$DEBUGGER_ROOT_CAUSE

## Affected Files
$DEBUGGER_AFFECTED_FILES

## Your job
Write regression test(s) that:
1. Directly reproduce the bug — the test must FAIL right now
2. Will PASS once the root cause is fixed
3. Serve as a permanent regression guard

When done: list every test file created with a summary.
Report: DONE or BLOCKED with reason.
```

If **BLOCKED** → stop and show the blocker.

---

## Step 4 — Coder

**Agent routing:**

| Target | Agent |
|--------|-------|
| `_Framework/`, `Abstracts/`, pure C# (no Unity API) | **coder** |
| MonoBehaviour, Provider, Installer, scene wiring | **unity-coder** |
| Mixed | **unity-coder** |

Spawn the appropriate subagent:

```
You are a senior C# Unity developer. Fix the following bug.

## Bug
$BUG_DESCRIPTION

## Root Cause (already investigated)
$DEBUGGER_ROOT_CAUSE

## Files to Change
$DEBUGGER_AFFECTED_FILES

## Regression Test (make this pass)
$TEST_WRITER_OUTPUT

## Project Rules
- Read .codex/project/RULES.md before writing any code
- Follow all rules in .codex/packs/unity-game/rules/
- No singletons — VContainer only
- No coroutines — UniTask only
- Fix only what is broken — do not refactor surrounding code
- Do NOT modify the test files

When done: list every file modified with a one-line summary.
Confirm the regression test now passes.
Report: DONE or BLOCKED with reason.
```

If **BLOCKED** → stop and show the blocker.

---

## Step 4.5 — Unity Validator (runs before Reviewer)

Spawn a **unity-verifier** subagent:

```
You are a Unity build validator. Verify the project compiles and all tests pass.

## What Was Fixed
$BUG_DESCRIPTION

## Files Changed
$CODER_OUTPUT

## Instructions
1. Use mcp__unityMCP__refresh_unity to trigger recompile.
2. Wait until isCompiling is false.
3. Use mcp__unityMCP__read_console type "Error" — check compile errors.
4. If compile errors → report COMPILE FAILED. Stop here.
5. Use mcp__unityMCP__run_tests — run all Edit Mode tests.
6. If tests fail → report TEST FAILED. Stop here.
7. If all pass → report VALIDATED.

VALIDATED — zero compile errors, all tests pass.
COMPILE FAILED: [error] — [file:line]
TEST FAILED: [test name] — [failure message]
```

### Validator Loop (max 2 fix passes)

If COMPILE FAILED or TEST FAILED → spawn **unity-coder** to fix:

```
Fix the following build or test failures.

## Bug Fix Context: $BUG_DESCRIPTION
## Failures: $VALIDATOR_OUTPUT

Rules:
- Fix only what is listed
- For assembly definition issues: check test assembly references correct game assembly with NSubstitute precompiledReferences and overrideReferences: true
- For compile errors: fix exact file:line reported
- For test failures: fix implementation, never change the test

Report: DONE or BLOCKED.
```

Re-run validator after fixes. After 2 failed passes → ask: `skip` or `stop`.

---

## Step 5 — Reviewer (skip in `solo` mode)

Reviewer priority — try in order:
1. Spawn Agent with `subagent_type: "claude-code"` — if plugin available
2. Spawn Agent with `subagent_type: "codex:codex-rescue"` — if claude-code unavailable
3. Fallback: **unity-reviewer**

```
Review this bug fix.

## Bug: $BUG_DESCRIPTION
## Root Cause: $DEBUGGER_ROOT_CAUSE
## Files Changed: $CODER_OUTPUT

## Review Criteria
1. Regression test passes — test file was not modified
2. Fix addresses root cause, not just symptom
3. Fix does not introduce new bugs
4. Architecture — VContainer DI, no singletons
5. Performance — no allocations in Update/FixedUpdate
6. UniTask — no async void, CancellationToken on every async method
7. Unity null safety — no ?. or is null on UnityEngine objects

APPROVED — fix is correct.
CHANGES NEEDED:
- [file:line] Issue and fix.
```

### Review Loop (max 3 passes)

On CHANGES NEEDED → spawn **unity-coder** to fix all listed issues:
```
Fix the following review issues.

## Bug Fix Context: $BUG_DESCRIPTION
## Review Feedback: $REVIEWER_FEEDBACK

Rules: fix only what reviewer flagged, read .codex/project/RULES.md first.
Report: DONE or BLOCKED.
```

Re-run reviewer after fixes. After 3 failed passes → ask: `skip` or `stop`.

**In `full` mode or Complex score:** after standard reviewer passes, spawn **unity-developer** for a second review pass.

---

## Step 5.5 — Unity Verifier (Final Bounded Check)

Spawn a **unity-verifier** subagent (max 3 internal iterations):

```
Perform a final bounded check on the delivered bug fix.

## Bug Fixed: $BUG_DESCRIPTION
## Files Changed: $CODER_OUTPUT

Run up to 3 internal fix-check iterations:
1. mcp__unityMCP__refresh_unity + wait for compile.
2. mcp__unityMCP__read_console for errors.
3. mcp__unityMCP__run_tests — check for failures.
4. Verify prefab structure: root holds logic components, Body child holds visual components.
5. If issues remain and iterations left — fix and re-check.
6. If clean → report VERIFIED.
7. After 3 iterations still failing → report VERIFY FAILED.

VERIFIED — compile clean, all tests pass, prefab structure valid.
VERIFY FAILED: [issue description]
```

If VERIFY FAILED → ask: `skip` or `stop`.

---

## Step 5.7 — Silent Failure Audit

Spawn a **silent-failure-hunter** subagent:

```
Audit the following C# files for silent failure patterns:

FILES: $CHANGED_FILES

Check for:
1. catch blocks that swallow exceptions without logging or rethrowing
2. async void outside Unity lifecycle methods
3. IEventBus Subscribe<T> without matching Unsubscribe<T> in Dispose/OnDisable
4. UniTask.Forget() without an onException error handler
5. Empty catch blocks

[file:line] — [pattern type] — [description] — [suggested fix]
If nothing found: CLEAN
```

If findings → ask: `fix` / `skip` / `stop`.
- `fix` → spawn **unity-coder** with all findings, re-run hunter once. Proceed regardless.

---

### COMMIT_GATE

Show the COMMIT_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: bug description, all changed files, reviewer verdict, verifier verdict.
Wait for `go` before committing. `stop` → leave files staged, print summary.

---

## Step 6 — Committer

Read `.codex/packs/unity-game/agents/committer.md` for full conventions, then:

- `git status`, `git diff`
- Stage only files related to this fix
- Commit: `fix: <short description in English>`
- One commit; do NOT push
- Report: commit hash and message

---

## Completion

Run: `rm -f .codex/state/gate-cleared`

Print:
```
## Fixed
Bug: [description]
Root cause: [one sentence]
Commit: [hash] — [message]
Reviewer: [Codex | Claude] — APPROVED
Verifier: VERIFIED
```

$ARGUMENTS

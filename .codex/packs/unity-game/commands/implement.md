# Implement — TDD Feature Implementation Pipeline

Implements a feature using a four-agent TDD pipeline: test writer writes failing tests first, coder implements to pass them, reviewer checks, committer commits.

## Usage

```
/implement <task description>
/implement add BoxCollectedEvent publishing to BayManager
```

If no argument is given, ask: "What needs to be implemented?"

## Pipeline

```
[1] TEST WRITER → [2] CODER → [2.5] VALIDATOR ⟲ → [3] REVIEWER ⟲ → [3.5] VERIFIER → [3.7] SILENT FAILURE AUDIT → [4] COMMITTER
```

---

## Step 0 — MCP Preflight

Check MCP connection state:
- **Connected** → unity-verifier uses MCP for compile + test checks
- **Disconnected** → Steps 2.5 and 3.5 fall back to `dotnet build` + `dotnet test`
- **Not installed** → code-only mode; Steps 2.5 and 3.5 use dotnet CLI fallback

---

## Step 0b — Review Mode

Read `production/review-mode.txt` (default: `lean` if file missing):

| Mode | Effect |
|------|--------|
| `solo` | Skip Test Writer and Reviewer — Coder → Committer only. |
| `lean` | Standard pipeline. |
| `full` | Standard pipeline + unity-developer second review always active. |

---

## Step 0c — Complexity Scoring

Score the task (0.0–1.0):

| Score | Label | Signals | Pipeline |
|-------|-------|---------|----------|
| 0.0–0.3 | **Simple** | Single class, no new interfaces, no DI wiring | Skip Test Writer |
| 0.4–0.6 | **Medium** | 2–4 classes, new interface, or touches event bus | Full pipeline |
| 0.7–1.0 | **Complex** | New module, cross-system events, ECS, or Addressables | Full pipeline + unity-developer review |

Scoring signals: new module folder +0.3, IEventBus events +0.2, ECS/Addressables +0.3, AppScope/AppModules/ConfigCatalog/InputService/static Module +0.2, single method -0.3.

Print:
```
Complexity: [score] — [Label]
Rationale: [one sentence]
Review Mode: [solo | lean | full]
```

**ARCHITECTURE_GATE:** If task creates a new module folder (score includes +0.3 new-module signal), show the ARCHITECTURE_GATE from `.codex/packs/unity-game/guides/director-gates.md`. Show proposed module structure and wait for `go`.

### SCOPE_GATE

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: task description, complexity score, known affected files.
Wait for `go` before spawning any agents.

After receiving `go`:
```bash
mkdir -p .codex/state && echo '{"gate":"SCOPE_GATE","pipeline":"implement","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .codex/state/gate-cleared
```

---

## Test Type Routing

Determine the test type for this task:

| Decision | Action |
|----------|--------|
| **EditMode** | Test Writer creates tests in Edit Mode assembly |
| **PlayMode-ECS** | Test Writer creates tests in Play Mode ECS assembly |
| **PlayMode-Scene** | Test Writer writes stub only; run `/create-test` separately for scene wiring |
| **NoTest** | Skip Step 1 (Test Writer) entirely |

Emit:
```
TEST TYPE DECISION
  Target:   [class name or file path]
  Decision: [EditMode | PlayMode-ECS | PlayMode-Scene | NoTest]
  Reason:   [one sentence]
```

---

## Inputs To Read

- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/rules/testing.md`
- `.codex/packs/unity-game/rules/performance.md`
- `.codex/packs/unity-game/guides/nsubstitute.md`

---

## Step 1 — Test Writer (skip if NoTest or Simple or `solo` mode)

Spawn a **tester** subagent:

```
Read .codex/packs/unity-game/agents/tester.md for your role and testing philosophy.
Read .codex/packs/unity-game/rules/testing.md for project-specific rules.
Read .codex/project/RULES.md for project architecture.

## Task
$TASK_DESCRIPTION

## Your job
1. Identify which class(es) and method(s) this task requires.
2. Write all tests that define the expected behavior — they must FAIL right now (no implementation yet).
3. Do NOT write any implementation code.

When done: list every test file created with a summary of what each covers.
Report: DONE or BLOCKED with reason.
```

If **BLOCKED** → stop and show the blocker.

---

## Step 2 — Coder

**Agent routing:**

| Target | Agent |
|--------|-------|
| `_Framework/`, `Abstracts/`, pure C# (no Unity API) | **coder** |
| MonoBehaviour, Provider, Installer, scene wiring | **unity-coder** |
| Mixed | **unity-coder** |

Spawn the appropriate subagent:

```
You are a senior C# Unity developer. Implement the following task.

## Task
$TASK_DESCRIPTION

## Existing Tests (make these pass)
$TEST_WRITER_OUTPUT

## Project Rules
- Read .codex/project/RULES.md before writing any code
- Follow all rules in .codex/packs/unity-game/rules/
- No singletons — VContainer only
- No coroutines — UniTask only
- No legacy Input API
- sealed classes by default
- IEventBus for cross-system communication
- #region tags required in _GameFolders/Scripts/
- Do NOT modify the test files — only write implementation code

When done: list every file created or modified with a one-line summary.
Confirm all tests now pass.
Report: DONE or BLOCKED with reason.
```

If **BLOCKED** → stop and show the blocker.

---

## Step 2.5 — Unity Validator (runs before Reviewer)

Spawn a **unity-verifier** subagent:

```
You are a Unity build validator. Verify the project compiles and all tests pass.

## What Was Implemented: $TASK_DESCRIPTION
## Files Changed: $CODER_OUTPUT

1. mcp__unityMCP__refresh_unity → trigger recompile.
2. Wait until isCompiling is false.
3. mcp__unityMCP__read_console type "Error" → check compile errors.
4. If compile errors → COMPILE FAILED. Stop.
5. mcp__unityMCP__run_tests → run all Edit Mode tests.
6. If tests fail → TEST FAILED. Stop.
7. If all pass → VALIDATED.

VALIDATED — zero compile errors, all tests pass.
COMPILE FAILED: [error] — [file:line]
TEST FAILED: [test name] — [failure message]
```

### Validator Loop (max 2 fix passes)

On COMPILE FAILED or TEST FAILED → spawn **unity-coder** to fix:

```
Fix the following build or test failures.

## Original Task: $TASK_DESCRIPTION
## Failures: $VALIDATOR_OUTPUT

Rules:
- Fix only what is listed
- For assembly definition issues: check test assembly references correct game assembly, NSubstitute in precompiledReferences, overrideReferences: true
- For compile errors: fix exact file:line
- For test failures: fix implementation, never change the test

Report: DONE or BLOCKED.
```

Re-run validator. After 2 failed passes → ask: `skip` or `stop`.

---

## Step 3 — Reviewer (skip in `solo` mode)

Reviewer priority — try in order:
1. Spawn native Codex subagent `unity-reviewer` when subagents are available and authorized.
2. If subagents are unavailable or not authorized, review locally using the same criteria and report the gap.

```
Review the following Unity C# implementation.

## What Was Implemented: $TASK_DESCRIPTION
## Files Changed: $CODER_OUTPUT

## Review Criteria
1. Tests — all pre-written tests pass; no test files were modified
2. Architecture — VContainer DI, no singletons, interfaces only across modules
3. Naming — PascalCase types, _camelCase private fields
4. Performance — no allocations in Update/FixedUpdate, no LINQ on hot paths
5. Events — IEvent structs past-tense with Event suffix, published via IEventBus
6. UniTask — no async void outside lifecycle, CancellationToken on every async method
7. Unity null safety — no ?. or is null on UnityEngine objects
8. Serialization — FormerlySerializedAs on any renamed [SerializeField]

APPROVED — all criteria pass.
CHANGES NEEDED:
- [file:line] Issue description and fix.
```

### Review Loop (max 3 passes)

On CHANGES NEEDED → spawn **unity-coder** to fix all listed issues:

```
Fix the following review issues.

## Original Task: $TASK_DESCRIPTION
## Review Feedback: $REVIEWER_FEEDBACK

Rules: fix only what reviewer flagged, do not refactor anything else.
Report: DONE or BLOCKED.
```

Re-run reviewer. After 3 failed passes → ask: `skip` or `stop`.

**In `full` mode or Complex score:** after standard reviewer passes, spawn **unity-developer** for a second review pass.

---

## Step 3.5 — Unity Verifier (Final Bounded Check)

Spawn a **unity-verifier** subagent (max 3 internal iterations):

```
Perform a final bounded check on the delivered implementation.

## What Was Implemented: $TASK_DESCRIPTION
## Files Changed: $CODER_OUTPUT

Run up to 3 internal fix-check iterations:
1. mcp__unityMCP__refresh_unity + wait for compile.
2. mcp__unityMCP__read_console for errors.
3. mcp__unityMCP__run_tests — check failures.
4. Verify prefab structure: root holds logic components, Body child holds visual components.
5. If issues remain and iterations left — fix and re-check.
6. If clean → VERIFIED.
7. After 3 iterations still failing → VERIFY FAILED.

VERIFIED — compile clean, all tests pass, prefab structure valid.
VERIFY FAILED: [issue description]
```

If VERIFY FAILED → ask: `skip` or `stop`.

---

## Step 3.7 — Silent Failure Audit

Spawn a **silent-failure-hunter** subagent:

```
Audit the following C# files for silent failure patterns:

FILES: $CHANGED_FILES

1. catch blocks swallowing exceptions without logging or rethrowing
2. async void outside Unity lifecycle methods
3. IEventBus Subscribe<T> without matching Unsubscribe<T> in Dispose/OnDisable
4. UniTask.Forget() without onException handler
5. Empty catch blocks

[file:line] — [pattern type] — [description] — [suggested fix]
If nothing found: CLEAN
```

If findings → ask: `fix` / `skip` / `stop`.

---

### COMMIT_GATE

Show the COMMIT_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: task description, all changed files, reviewer verdict, verifier verdict.
Wait for `go` before committing. `stop` → leave files staged, print summary.

---

## Step 4 — Committer

Read `.codex/packs/unity-game/agents/committer.md` for full conventions, then:

- `git status`, `git diff`
- Stage only files related to this task (never `git add -A`)
- Commit: `feat: <short description in English>`
- One commit unless changes are clearly separable
- Do NOT push

---

## Completion

Run: `rm -f .codex/state/gate-cleared`

Print:
```
## Implemented
Task: [task description]
Commit: [hash] — [message]
Reviewer: [local | unity-reviewer] — APPROVED
Verifier: VERIFIED
```

$ARGUMENTS

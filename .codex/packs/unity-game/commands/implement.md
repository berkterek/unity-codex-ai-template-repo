# Implement — TDD Feature Implementation Pipeline

Implements a feature using a TDD pipeline: write failing tests first, implement
to make them pass, review, commit.

## Usage

```
/implement <task description>
/implement add BoxCollectedEvent publishing to BayManager
```

If no argument is given, ask: "What needs to be implemented?"

## Pipeline

```
[1] TESTS → [2] IMPLEMENTATION → [3] VALIDATION → [4] REVIEW → [4.7] SILENT FAILURE AUDIT → [5] COMMIT
```

---

## Complexity Scoring

Before starting, score the task on a 0.0–1.0 scale:

| Score | Label | Signals | Action |
|-------|-------|---------|--------|
| 0.0–0.3 | Simple | Single class, no new interfaces, no DI wiring | Skip Step 1 (no tests) |
| 0.4–0.6 | Medium | 2–4 classes, new interface, or touches event bus | Full pipeline |
| 0.7–1.0 | Complex | New module, cross-system events, ECS, or Addressables | Full pipeline + unity-developer review after Step 4 |

Scoring signals: new module folder +0.3, IEventBus events +0.2, ECS/Addressables +0.3, AppScope/InputView/Installer +0.2, single method addition −0.3.

Print:
```
Complexity: [score] — [Label]
Rationale: [one sentence]
```

### Director Gate

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: task description, complexity score, known affected files.
Wait for `go` before spawning any agents.

---

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

Before starting, read:

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/rules/testing.md`
- `.codex/packs/unity-game/rules/performance.md`
- `.codex/packs/unity-game/guides/nsubstitute.md`

---

## Step 1 — Write Failing Tests

Act as the tester agent (`.codex/packs/unity-game/agents/tester.md`):

1. Identify which class(es) and method(s) the task requires.
2. Write all tests that define the expected behavior — they must FAIL right now
   (no implementation yet).
3. Do NOT write any implementation code.
4. List every test file created with a summary of what each test covers.

If blocked (cannot determine what to test) → stop and ask the user for
clarification.

---

## Step 2 — Implement

Act as the coder agent (`.codex/packs/unity-game/agents/coder.md`):

1. Implement only what is needed to make the tests from Step 1 pass.
2. Do NOT modify the test files.
3. Follow all rules: no singletons, VContainer only; no coroutines, UniTask
   only; sealed classes by default; IEventBus for cross-system communication.
4. List every file created or modified with a one-line summary.

If blocked → stop and show the blocker to the user.

---

## Step 3 — Validate

Use Unity MCP to verify the project compiles and all tests pass:

1. `mcp__UnityMCP__refresh_unity` — trigger script recompile.
2. Wait until `isCompiling` is false (poll `editor_state` resource).
3. `mcp__UnityMCP__read_console` with type "Error" — check for compile errors.
4. If compile errors exist → fix them (max 2 fix passes), then re-validate.
5. `mcp__UnityMCP__run_tests` — run all Edit Mode tests.
6. If any tests fail → fix implementation (max 2 fix passes), then re-validate.
7. If still failing after 2 passes → show all errors and ask:
   - `skip` — proceed to review (user accepts responsibility)
   - `stop` — abort

---

## Step 3.5 — Unity Verifier (after validation, before review)

Spawn a `unity-verifier` subagent for a final bounded check (max 3 iterations):
1. Compile check via `refresh_unity` + `read_console`.
2. Run all Edit Mode tests via `run_tests`.
3. Auto-fix any auto-fixable issues found.

If still failing → stop, surface blockers.

---

## Step 4 — Review

**For Complex tasks (score ≥ 0.7):** also run `unity-developer` as a second reviewer after Step 4.

Review the implementation against these criteria:

1. All pre-written tests pass; no test files were modified.
2. Architecture — VContainer DI, no singletons, interfaces only across modules.
3. Naming — PascalCase types, `_camelCase` private fields.
4. Performance — no allocations in Update/FixedUpdate, no LINQ on hot paths.
5. Events — IEvent structs past-tense with Event suffix, published via IEventBus.
6. UniTask — no `async void` outside lifecycle, CancellationToken on every
   async method.
7. Unity null safety — no `?.` or `is null` on UnityEngine objects.
8. Serialization — FormerlySerializedAs on any renamed `[SerializeField]`.

If issues found → fix them and re-review (max 3 review passes). After 3 failed
passes → show remaining issues and ask `skip` or `stop`.

---

## Step 4.7 — Silent Failure Audit

Scan changed `.cs` files for:
1. `catch` blocks that swallow exceptions without logging or rethrowing.
2. `async void` outside Unity lifecycle methods.
3. `IEventBus` subscriptions without matching `Unsubscribe` in Dispose/OnDisable.
4. `UniTask.Forget()` without an `onException` handler.
5. Empty `catch { }` blocks.

If findings → show them and ask: `fix` / `skip` / `stop`.

### Director Gate — COMMIT_GATE

Show the COMMIT_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: task description, changed files, reviewer verdict.
Wait for `go` before committing.

---

## Step 5 — Commit

Act as the committer agent (`.codex/packs/unity-game/agents/committer.md`):

1. `git status && git diff`
2. Stage only files related to this task.
3. Commit message format: `feat: <short description in English>`.
4. One commit unless changes are clearly separable into logical units.
5. Do NOT push.

---

## Completion

Print:

```
## Implemented
Task: [task description]
Commit: [hash] — [message]
Validation: PASS
Review: PASS
```

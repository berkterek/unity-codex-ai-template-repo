# Orchestrate — Automated WORKFLOW.md Executor

You are an orchestration agent. Read `docs/WORKFLOW.md` and execute every task automatically, one phase at a time. Each task runs a pipeline: **tester → coder → reviewer → committer**. After each phase you pause and ask the developer before moving on.

## Step 0 — Review Mode

Read `production/review-mode.txt` (default: `lean` if file missing):

| Mode | Effect |
|------|--------|
| `solo` | No reviewer — coder/unity-coder → committer only. For prototypes/jams. |
| `lean` | Standard pipeline. For regular solo development. |
| `full` | Standard pipeline + unity-developer second review always active. For team review or learning sessions. |

Set mode by editing `production/review-mode.txt`. Print the active mode before proceeding.

---

## Step 0b — Complexity Scoring

Before executing any task, score the overall workflow complexity (0.0–1.0):

| Score | Label | Coder Agent |
|-------|-------|-------------|
| 0.0–0.3 | **Simple** | Pure C# → **coder** / Unity → **unity-coder-lite** |
| 0.4–0.6 | **Medium** | Pure C# → **coder** / Unity → **unity-coder** |
| 0.7–1.0 | **Complex** | Pure C# → **coder** / Unity → **unity-coder** + unity-developer review after each task |

**Agent routing per task:**

| Target location | Simple | Medium/Complex |
|-----------------|--------|----------------|
| `_Framework/`, `Abstracts/`, pure C# (no Unity API) | **coder** | **coder** |
| MonoBehaviour, Provider, Installer, scene wiring | **unity-coder-lite** | **unity-coder** |
| Mixed | **unity-coder-lite** | **unity-coder** |

**Scoring signals:**
- Creates a new module folder? +0.3
- Adds or modifies IEventBus events? +0.2
- Touches ECS systems or Addressables? +0.3
- Modifies AppScope, InputView, or an Installer? +0.2
- Single method addition to existing class? −0.3

Print before proceeding:
```
Complexity: [score] — [Label]
Rationale: [one sentence]
Coder Agent: [coder | unity-coder-lite | unity-coder]
Review Mode: [solo | lean | full]
```

### SCOPE_GATE

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: WORKFLOW.md plan name, total phases and tasks, complexity score.
Wait for `go` before spawning any agents.

After receiving `go` → run:
```bash
mkdir -p .codex/state && echo '{"gate":"SCOPE_GATE","pipeline":"orchestrate","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .codex/state/gate-cleared
```

---

## Initialization

1. Verify `docs/WORKFLOW.md` exists. If not, stop: "WORKFLOW.md not found. Run `/plan-workflow` first."
2. Read `docs/WORKFLOW.md` completely.
3. Read `.codex/project/RULES.md` for project constraints.
4. Read `docs/PROGRESS.md` if it exists — resume from where work left off.
5. Append to `docs/EVENTS.jsonl` (create if missing):
   ```jsonl
   {"event":"ORCHESTRATION_STARTED","plan":"[game name]","phases":[N],"tasks":[M],"timestamp":"[ISO8601]"}
   ```
6. Announce:
   ```
   ## Orchestration Starting
   Plan: [game name]
   Total phases: X | Total tasks: Y
   Resuming from: [Phase N, Task P or "beginning"]
   ```

---

## Execution Loop

Repeat for each phase (skip completed phases from PROGRESS.md):

### Phase Start

Append to `docs/EVENTS.jsonl`:
```jsonl
{"event":"PHASE_STARTED","phase":[N],"name":"[Phase Name]","tasks":[count],"timestamp":"[ISO8601]"}
```

Print:
```
---
## Phase [N]: [Phase Name]
Goal: [phase goal from WORKFLOW.md]
Tasks: [count]
---
```

---

### Task Execution

Check for `parallel_group` annotations in WORKFLOW.md:

**If no tasks have `parallel_group`:** Execute all tasks sequentially.

**If tasks have `parallel_group` AND complexity score ≥ 0.4:**
1. Group tasks by `parallel_group` number.
2. **Conflict check:** If two tasks in the same group list the same output file → demote the later task to sequential and warn.
3. Execute tasks in the same group simultaneously.
4. Wait for all tasks in the group to complete before starting the next group.
5. If any task in a group fails → stop. Do not proceed until user resolves.
6. Commit all group outputs in a single commit after the group completes.

**If complexity score < 0.4:** Ignore `parallel_group` — run all tasks sequentially.

---

#### For Each Task:

**Announce:**
```
### [P{phase}.T{task}] [Task Title]
Type: [type] | Agent: [agent type] | Group: [parallel_group or "sequential"]
Inputs: [list]
Outputs: [list]
```

Append to `docs/EVENTS.jsonl`:
```jsonl
{"event":"TASK_STARTED","phase":[N],"task":[P],"id":"P{phase}.T{task}","title":"[task title]","agent":"[agent type]","timestamp":"[ISO8601]"}
```

---

#### Step 1 — Test Writer (skip if `Agent: unity-setup`)

Spawn a **tester** subagent:

```
Read .codex/packs/unity-game/agents/tester.md for your role and testing philosophy.
Read .codex/packs/unity-game/rules/testing.md for project-specific rules.
Read .codex/project/RULES.md for project architecture.

## Task
ID: [P{phase}.T{task}]
Title: [task title]
Description: [full task description from WORKFLOW.md]

## Acceptance Criteria (tests must cover these)
[list every criterion from WORKFLOW.md]

## Your job
1. Write failing unit tests BEFORE any implementation exists.
2. Tests must FAIL right now — no implementation exists yet.
3. Do NOT commit anything.

Report: DONE (list every test file created) or BLOCKED with reason.
```

If **BLOCKED** → stop. Print blocker. Update PROGRESS.md. Append TASK_BLOCKED event. Exit.

---

#### Step 2 — Coder (or Unity Setup)

If `Agent: unity-setup` → spawn a **unity-setup** subagent.

**Coder prompt:**
```
You are a senior C# Unity developer implementing a specific task. Tests have already been written — your job is to make them pass.

## Task
ID: [P{phase}.T{task}]
Title: [task title]
Description: [full task description from WORKFLOW.md]

## Existing Tests (make these pass)
[tester output — list of test files and what they cover]

## Input Files
[list every input file path]

## Output Files
[list every output file path]

## Acceptance Criteria
[list every criterion from WORKFLOW.md]

## Project Rules
- Read .codex/project/RULES.md before writing any code
- Follow all rules in .codex/packs/unity-game/rules/
- No singletons — VContainer only
- No coroutines — UniTask only
- No legacy Input API
- sealed classes by default
- Do NOT modify the test files — only write implementation code
- #region tags required in _GameFolders/Scripts/

Report: DONE (list every file created or modified) or BLOCKED with reason.
```

**Unity Setup prompt:**
```
You are a Unity scene architect setting up a specific task.

## Task
ID: [P{phase}.T{task}]
Title: [task title]
Description: [full task description from WORKFLOW.md]

## Input Files
[list every input file path]

## Output Files
[list every output file path]

## Acceptance Criteria
[list every criterion from WORKFLOW.md]

## Rules
- Use Unity MCP tools for all scene/prefab work
- Check editor state first: mcpforunity://editor/state → wait until ready_for_tools == true
- Every GameObject in scene must be a prefab instance (except empty hierarchy organizers)
- Save all prefabs under _GameFolders/Prefabs/<Domain>/
- Root: logic components only. Body child: visual components only.
- Use Prefab Variants for shared base structures — never manually duplicate

Report: DONE (list every scene/prefab/asset created or modified) or BLOCKED with reason.
```

If **BLOCKED** → stop. Print blocker. Update PROGRESS.md. Append TASK_BLOCKED event. Exit.

---

#### Step 3 — Reviewer (skip in `solo` mode)

Spawn a **unity-reviewer** subagent:

```
Review the following Unity C# implementation.

## Task
ID: [P{phase}.T{task}]
Title: [task title]

## Files Changed
[coder output — list of files with summaries]

## Acceptance Criteria (must all pass)
[list every criterion from WORKFLOW.md]

## Review Criteria
1. Tests pass — all pre-written tests pass; no test files were modified
2. Acceptance criteria — does the implementation satisfy all of them?
3. Architecture — VContainer DI, no singletons, interfaces only across modules
4. Naming — PascalCase types, _camelCase private fields
5. Performance — no allocations in Update/FixedUpdate, no LINQ on hot paths
6. Events — IEvent structs past-tense + Event suffix, published via IEventBus
7. UniTask — no async void outside lifecycle, CancellationToken on every async method
8. Unity null safety — no ?. or is null on UnityEngine objects
9. Serialization — FormerlySerializedAs on any renamed [SerializeField]

Output:
APPROVED — all criteria pass.
CHANGES NEEDED:
- [file:line] Issue and required fix.
```

**Review Loop** (max 3 passes on CHANGES NEEDED):
1. Spawn a **unity-coder** subagent to fix every listed issue (fix only what reviewer flagged).
2. Re-run the reviewer.
3. If APPROVED → proceed to Step 3.5.
4. After 3 failed passes → ask: `skip` (proceed) or `stop` (abort).

In `full` mode or Complex score: after standard reviewer passes, also spawn **unity-developer** for a second review pass.

---

#### Step 3.5 — Bounded Verification

Spawn a **unity-verifier** subagent:

```
Run a final bounded check on completed work.

## Task: [P{phase}.T{task}] — [task title]
## Files Changed: [list from coder output]
## Acceptance Criteria: [from WORKFLOW.md]

Max 3 internal iterations:
1. Compile check via MCP refresh_assets
2. Test run via MCP run_tests
3. Quick scan: null refs, missing SerializeField, event leaks

Report: VERIFIED or ISSUES FOUND with details.
```

If VERIFIED → proceed to Step 4.
If ISSUES FOUND and unfixable → stop. Print blockers. Update PROGRESS.md.

---

#### Step 4 — Committer

Read `.codex/packs/unity-game/agents/committer.md` for full conventions, then:

- Run `git status`, `git diff` to confirm what changed
- Stage only files related to this task (never `git add -A`)
- Commit: `feat: [P{phase}.T{task}] [task title]`
- Do NOT push
- Report: commit hash and message

---

#### After Each Task

Update `docs/PROGRESS.md`:
```markdown
- [x] P{phase}.T{task} — [title] — [commit hash]
```

Append to `docs/EVENTS.jsonl`:
```jsonl
{"event":"TASK_COMPLETED","phase":[N],"task":[P],"id":"P{phase}.T{task}","title":"[task title]","commit":"[hash]","timestamp":"[ISO8601]"}
```

---

### Phase Gate

After all tasks in a phase complete:

#### Step 1 — Compile + Test Green

Spawn a **unity-verifier** subagent to compile and run tests. If failures found → spawn **unity-fixer** (max 3 passes). If still failing → stop and report to user.

Print: `Compile + tests: PASS` or `FAIL — [issues].`

#### Step 2 — Silent Failure Hunt

Spawn a **unity-linter** subagent:

```
Audit all files changed in this phase for silent failure patterns:
- catch blocks that swallow exceptions without logging
- async void outside Unity lifecycle methods
- IEventBus subscriptions without matching Unsubscribe
- UniTask.Forget() without an error handler
- empty catch blocks

Files to audit: [list of output files from this phase's tasks]

Report each finding as: [file:line] — [pattern] — [fix]
If none found: CLEAN
```

#### Step 3 — Validate

Run `/validate` on the phase to verify all acceptance criteria are met.

If FAIL → ask user: `retry` or `skip`.

#### Step 4 — Developer Prompt

Print:
```
## Phase [N] Complete
Compile: PASS | Silent failures: [CLEAN / N findings] | Validate: PASS

Ready to start Phase [N+1]: [name]
Goal: [goal]
Tasks: [count]

Proceed? (yes / no / stop)
```

Wait for response.
- `yes` → append PHASE_COMPLETED event, continue.
- `no` or `stop` → exit. Remind user to run `/continue` to resume.

---

## Progress Tracking

`docs/PROGRESS.md` format:

```markdown
# Execution Progress
**Plan:** [game name]
**Started:** [date]
**Last updated:** [date]

## Phase 1: Infrastructure Foundation — COMPLETE
- [x] P1.T1 — IEventBus + EventBus — abc1234
- [x] P1.T2 — ModuleInstaller base — def5678

## Phase 2: Core Game Logic — IN PROGRESS
- [x] P2.T1 — EnemyService — 9ab1234
- [ ] P2.T2 — ScoreService — pending

## Phase 3: Unit Tests — PENDING
```

---

## Rules

- **Never skip acceptance criteria.**
- **Never continue past a BLOCKED task.** Fix it first.
- **Phase gates are mandatory.** Always pause and ask between phases.
- **One pipeline per task.** Never batch multiple tasks into one subagent call.
- **Subagents get no session history.** Write every prompt as if they know nothing about this conversation.

---

## On Completion

Run: `rm -f .codex/state/gate-cleared`

```
## Orchestration Complete
All [N] phases, [M] tasks executed.

Summary:
- Phase 1: [N] tasks ✓
- Phase 2: [N] tasks ✓
...

Next step: Run /validate to verify the full build, then /review-code on key systems.
```

Append to `docs/EVENTS.jsonl`:
```jsonl
{"event":"ORCHESTRATION_COMPLETE","phases":[N],"tasks":[M],"timestamp":"[ISO8601]"}
```

$ARGUMENTS

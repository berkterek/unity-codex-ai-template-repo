# Orchestrate — Module Tasks Executor

Execute a module `tasks.md` file one task at a time. This command replaces the
legacy `docs/WORKFLOW.md` phase executor for new work.

Usage:

```text
/orchestrate docs/modules/01-core-loop/tasks.md
/orchestrate docs/modules/01-core-loop/tasks.md --heavy
```

## Step 0 — Parse Arguments

- `$ARGUMENTS` must include a `tasks.md` path.
- `--heavy` upgrades implementation/setup subagents according to the project
  model-routing rules.

If the path is missing, stop:

```text
tasks.md path required.
Usage: /orchestrate docs/modules/01-core-loop/tasks.md
```

Read:

1. `AGENTS.md`
2. `.codex/packs/unity-game/guides/guardrails.md`
3. `.codex/project/PROJECT.md`
4. `.codex/project/RULES.md`
5. `.codex/packs/unity-game/guides/orchestrate-rules.md`
6. The requested `tasks.md`

## Step 1 — Read Tasks

Parse checkbox state:

- `- [x]` = complete, skip
- `- [ ]` = pending, execute

Extract per task:

- Task id and title
- File path in backticks
- `parallel_group:N` annotation if present
- Type
- Agent
- Test type
- Inputs
- Outputs
- Acceptance criteria

## Step 2 — Review Mode

Read `production/review-mode.txt`; default to `lean` if missing.

| Mode | Effect |
|------|--------|
| `solo` | Skip reviewer; use coder/setup then committer. Prototype only. |
| `lean` | Standard tester/coder/verifier/reviewer/committer flow. |
| `full` | Standard flow plus `unity-developer` second review for every task. |

Print the active mode before the scope gate.

## Step 3 — Complexity Score

Score the overall module workflow from `0.0` to `1.0`.

| Score | Label | Signals |
|-------|-------|---------|
| 0.0-0.3 | Simple | Single class, no DI wiring, no events |
| 0.4-0.6 | Medium | 2-4 classes, new interface, existing event bus touch |
| 0.7-1.0 | Complex | New module, cross-system events, ECS, Addressables, scene wiring |

Signals:

- Creates a new module folder: `+0.3`
- Adds or modifies `IEventBus` events: `+0.2`
- Touches ECS or Addressables: `+0.3`
- Modifies `AppScope`, `AppModules`, `ConfigCatalog`, `InputService`, or a module installer: `+0.2`
- Single method addition to an existing class: `-0.3`

Agent routing per task:

| Target location | Simple | Medium/Complex |
|-----------------|--------|----------------|
| `_Framework/`, `Games/Abstracts/`, pure C# `Games/Concretes/` | `coder` | `coder` |
| MonoBehaviour, Provider, Scope, static Module wiring, scene wiring | `unity-coder-lite` | `unity-coder` |
| Scene/prefab/asset work | `unity-setup` | `unity-setup` |

For complex tasks in `lean` or `full` mode, run an additional
`unity-developer` review after `unity-reviewer` passes.

## Step 4 — Codebase Pre-Scan

Prefer the knowledge graph when enabled:

- If `.codex/project/FEATURES.json` contains `"graph": true` and
  `.codex/graph/graph.json` exists, read the graph.
- Otherwise scan the filesystem.

Scan:

- `Assets/_Framework/`
- `Assets/_GameFolders/Scripts/Games/Abstracts/`
- `Assets/_GameFolders/Scripts/Games/Concretes/`
- `Assets/_GameFolders/Scripts/Tests/`

Print:

```markdown
## Pre-Scan Report

Framework: <assemblies/classes found>
Existing Abstracts: <interfaces or none>
Existing Concretes: <classes or none>
Conflicts with tasks.md: <existing outputs or none>
Architecture issues found: <list or none>
Graph confidence: EXTRACTED | INFERRED | N/A
```

If an output already exists and appears complete, ask whether to skip or
re-implement that task before continuing.

## Step 5 — Scope Gate

Show:

```markdown
## SCOPE_GATE — Module Orchestration

Plan: <tasks.md path>
Module: <heading from tasks.md>
Total tasks: <n>
Pending tasks: <n>
Completed tasks skipped: <n>
Complexity: <score> — <label>
Review Mode: <solo|lean|full>

Type `go` to execute.
```

Do not spawn subagents until the user says `go`.

After approval:

```bash
mkdir -p .codex/project/state
printf '{"gate":"SCOPE_GATE","pipeline":"orchestrate","plan":"%s","ts":"%s"}\n' "<tasks.md path>" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .codex/project/state/gate-cleared
```

## Step 6 — Initialize Event Journal

Append to `docs/EVENTS.jsonl`:

```json
{"event":"ORCHESTRATION_STARTED","plan":"<tasks.md path>","tasks":0,"timestamp":"<ISO8601>"}
```

Create `docs/PROGRESS.md` if missing. Treat `tasks.md` checkbox state as the
primary source of truth and `docs/PROGRESS.md` as a human-readable mirror.

## Execution Loop

Run pending tasks in order unless `parallel_group` allows safe parallel work.

### Parallel Groups

If tasks have `parallel_group:N` and complexity is at least `0.4`:

1. Group tasks by number.
2. Check output file conflicts. If two tasks write the same output, demote the
   later task to sequential and report the conflict.
3. Execute tasks in the same group in parallel only when their write scopes are
   disjoint.
4. Wait for all tasks in the group before continuing.
5. If any task fails, stop the group and report all failures.
6. Commit group outputs together after all grouped tasks pass review.

If complexity is below `0.4`, ignore `parallel_group` and run sequentially.

### Per Task

Announce:

```text
### <Task ID> <Task Title>
Type: <type> | Agent: <agent> | Complexity: <S/M/L/XL> | Group: <parallel_group|sequential>
Inputs: <paths>
Outputs: <paths>
```

Append `TASK_STARTED` to `docs/EVENTS.jsonl`.

#### Step 1 — Test Writer

Skip only when:

- `Agent: unity-setup`, or
- `Test type: NoTest` with a clear NoTest rationale.

Spawn/use the `tester` subagent with:

- The task description
- Acceptance criteria
- Test type decision
- Input/output files
- Rule: write failing tests first
- Rule: do not modify implementation files

If blocked, append `TASK_BLOCKED`, update `docs/PROGRESS.md`, and stop.

#### Step 2 — Coder Or Unity Setup

Use routing from Step 3:

- `coder` for pure C# contracts/services
- `unity-coder-lite` or `unity-coder` for MonoBehaviour/provider/static module wiring
- `unity-setup` for scene/prefab/asset work via MCP

Task prompt must require:

- Read project rules first
- Follow `.codex/packs/unity-game/rules/`
- No singletons
- No coroutines
- No legacy input API
- No UnityEngine in pure services
- Static `[Domain]Module.Install(...)` for module wiring
- No test file edits during implementation

If blocked, append `TASK_BLOCKED`, update progress, and stop.

#### Step 3 — Verification

Run the strongest available verification:

1. Unity MCP compile/console check when connected
2. Unity test runner when available and relevant
3. `.codex/guardrails/run.sh --changed`

Compilation errors block progress. Do not commit or mark the task complete while
Unity assembly errors are present.

#### Step 4 — Review

Skip only in `solo` mode.

Review order:

1. Local Codex review of changed files
2. `unity-reviewer` subagent when authorized/available
3. `unity-developer` second pass for complex or `full` mode

Review must check:

- Acceptance criteria
- Tests pass
- No test weakening
- Architecture boundaries
- Input/service/provider separation
- Guardrail output
- Unused code and silent failures

If review fails, append `TASK_BLOCKED`, leave checkbox unchecked, and stop.

#### Step 5 — Mark Complete

After verification and review pass:

- Change the task checkbox from `- [ ]` to `- [x]`
- Append `TASK_COMPLETED` to `docs/EVENTS.jsonl`
- Update `docs/PROGRESS.md`

#### Step 6 — Commit

When the task or parallel group is complete, use the repository smart commit
rules. Never run `git push`.

## Phase Checkpoints

At each `**Checkpoint:` line in `tasks.md`:

1. Run `.codex/guardrails/run.sh --changed`
2. Run `/qa`-equivalent checks when feasible
3. Confirm independent acceptance criteria for that phase
4. Ask the user before proceeding to the next phase

## Completion

When all tasks are checked:

- Set module status in `tasks.md` to `Complete`
- Update `docs/ROADMAP.md` status for this module to `Complete`
- Append `ORCHESTRATION_COMPLETED` to `docs/EVENTS.jsonl`
- Run final guardrails on changed files
- Report changed files, verification, commits, and any residual risks

$ARGUMENTS

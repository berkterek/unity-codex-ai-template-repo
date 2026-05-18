# Continue Orchestration Agent

You are the orchestrator continuing from an interrupted execution. Pick up exactly where things left off, wasting no effort on completed work.

## Initialization

1. Read `.codex/project/RULES.md` for project constraints.
2. Read `docs/GDD.md` for game design context.
3. Read `docs/TDD.md` for technical architecture.
4. Read `docs/WORKFLOW.md` for the full execution plan.
5. Read `docs/PROGRESS.md` — this is your source of truth for what's done.

## Resume Process

### Step 1: Assess State via Event Journal

**Primary method — Event replay (preferred):**

If `docs/EVENTS.jsonl` exists, read it line-by-line and replay events to reconstruct state:

1. Initialize: `phase=0, tasks={}, agents={}, commits=[], status="unknown"`
2. For each event line, update the model:
   - `orchestration_started` → set start time, initialize task/phase counts
   - `task_status` → update task: `tasks[id].status = event.data.to`
   - `agent_spawned` → register agent with task, type
   - `agent_completed` / `agent_failed` → update agent status, record files
   - `review_verdict` → update task review state (PASS → done, FAIL → failed)
   - `phase_transition` → advance phase counter
   - `commit_created` → record commit SHA
   - `orchestration_paused` → note pause state
   - `error` / `blocker` → record for display
3. After replay, you have the **ground truth**: current phase, every task's final status, all commits made.
4. Cross-reference with PROGRESS.md for display info (events are authoritative if they conflict).
5. If PROGRESS.md is inconsistent with events, **rebuild PROGRESS.md** from event-derived state.

**Fallback method — PROGRESS.md heuristic:**

If `docs/EVENTS.jsonl` does NOT exist, read PROGRESS.md and determine:
- Which phase are we in?
- Which tasks are COMPLETE (with PASS review)?
- Which tasks are IN_PROGRESS (agents don't survive restarts — may need restart)?
- Which tasks are PENDING?
- Are there any FAILED reviews that need re-attempts?
- Are there any blockers logged?

### Step 2: Recovery Plan

- **IN_PROGRESS tasks:** Check if output files exist and are complete. If yes, send to reviewer. If no, restart the task.
- **FAILED tasks:** Re-attempt with the review feedback included in the agent prompt.
- **PENDING tasks:** Schedule normally.

### Step 3: Report to User

Before resuming, show:

```
## Continuing Orchestration

**Last checkpoint:** Phase X, Task Y
**Completed:** N tasks
**Needs restart:** M tasks (were in-progress)
**Needs re-attempt:** K tasks (failed review)
**Remaining:** J tasks

Ready to resume?
```

### Step 4: Continue Execution

On user confirmation:

```bash
mkdir -p .codex/state && echo '{"started":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","phase":'$CURRENT_PHASE',"phaseName":"'"$PHASE_NAME"'"}' > .codex/state/orchestration-active.json
```

- Spawn agents for the current phase's remaining tasks
- Follow the same parallel dispatch, review gate, and phase gate process as `/orchestrate`
- Continue updating `docs/PROGRESS.md`

## Rules

- Do NOT re-run completed and reviewed tasks
- Do NOT skip the review step, even for restarted tasks
- Treat IN_PROGRESS tasks as potentially incomplete — verify before assuming done
- If PROGRESS.md is corrupted or missing, scan the file system for what exists and rebuild state

$ARGUMENTS

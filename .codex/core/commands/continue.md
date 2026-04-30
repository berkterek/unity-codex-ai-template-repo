# Continue

Resume an interrupted orchestration without redoing completed work.

## Inputs

Read:

- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`
- `.codex/project/EVENTS.jsonl`
- `.codex/runtime/orchestrator-state.md`
- `.codex/runtime/checkpoint/*.md`
- `.codex/runtime/mailbox/*.jsonl`
- `.codex/runtime/heartbeat/*.json`

If project files are missing, reconstruct as much as possible from the file
system and explain what could not be recovered.

## Resume Process

### 1. Replay Events

If `EVENTS.jsonl` exists, replay it line by line:

- `orchestration_started`: initialize run metadata.
- `agent_spawned`: register agent and task.
- `agent_completed`: mark agent complete and record files.
- `agent_failed`: mark agent failed and record reason.
- `task_status`: update task state.
- `review_verdict`: mark reviewed task pass/fail.
- `phase_transition`: update current phase.
- `commit_created`: record commit.
- `orchestration_paused`: mark paused.
- `orchestration_completed`: mark completed.
- `error` or `blocker`: record for display.

Events are authoritative. If `PROGRESS.md` disagrees, rebuild or correct
`PROGRESS.md` from events.

### 2. Fallback To Progress

If no event journal exists:

- Read `PROGRESS.md`.
- Identify completed, failed, working, and pending tasks.
- Treat working tasks as incomplete until outputs and review status are
  verified.

### 3. Inspect Checkpoints

For each interrupted agent:

- Read its checkpoint.
- Check whether output files exist and look complete.
- If complete, send to review.
- If incomplete, restart the task with checkpoint content as previous progress.

### 4. Report Recovery Plan

Before resuming, report:

```markdown
## Continuing Orchestration

Last known phase: [phase]
Completed tasks: [count]
Needs review: [count]
Needs restart: [count]
Failed tasks: [count]
Remaining tasks: [count]
Blockers: [list or none]
```

### 5. Resume

After recovery:

- Recreate `.codex/runtime/orchestration-active.json`.
- Continue with the normal orchestration protocol.
- Do not rerun completed reviewed tasks.
- Do not skip review for restarted tasks.

## Rules

- Never assume an in-progress task completed.
- Never discard checkpoint data.
- Never rewrite event history.
- Prefer event replay over progress-table parsing.


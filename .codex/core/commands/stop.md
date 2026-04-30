# Stop

Gracefully pause active orchestration.

## Inputs

Read:

- `.codex/project/PROGRESS.md`
- `.codex/project/EVENTS.jsonl`
- `.codex/runtime/orchestration-active.json`
- `.codex/runtime/mailbox/`
- `.codex/runtime/heartbeat/`

## Process

1. Identify current phase and working tasks.
2. Append an `orchestration_paused` event if the event journal exists.
3. Mark active tasks as `paused` or `working-paused` according to the progress
   protocol.
4. Add a pause note to `PROGRESS.md`.
5. Remove `.codex/runtime/orchestration-active.json`.
6. Tell the user how to resume.

## Rules

- Do not delete completed work.
- Do not mark incomplete tasks as done.
- Do not remove checkpoints, mailbox files, or event history.
- Do not clean runtime state except the active marker.

## Output

```markdown
Orchestration paused.

Phase: [current phase]
Tasks completed: [count]
Tasks paused: [count]
Tasks remaining: [count]

Resume with the continue command.
```


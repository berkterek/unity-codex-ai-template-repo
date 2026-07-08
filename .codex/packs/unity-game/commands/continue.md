# Continue — Resume Module Orchestration

Resume an interrupted `/orchestrate <tasks.md>` run. The checkbox state inside
the module `tasks.md` is the primary source of truth.

## Initialization

Read:

1. `AGENTS.md`
2. `.codex/packs/unity-game/guides/guardrails.md`
3. `.codex/project/RULES.md`
4. `docs/ROADMAP.md` when present
5. `docs/EVENTS.jsonl` when present
6. The target module `tasks.md`

If `$ARGUMENTS` includes a `tasks.md` path, resume that module. Otherwise infer
the active module from the most recent `ORCHESTRATION_STARTED` event, then from
`docs/ROADMAP.md` rows marked `In Progress`.

If no module can be inferred, stop and ask for the `tasks.md` path.

## Recovery Process

1. Replay `docs/EVENTS.jsonl` when present.
2. Parse every checkbox in `tasks.md`.
3. Treat checked tasks as complete unless changed outputs are missing.
4. Treat unchecked tasks as pending.
5. For any task that has `TASK_STARTED` but no `TASK_COMPLETED`, inspect outputs:
   - Complete and reviewed -> send to verification/review before checking it.
   - Incomplete -> restart the task.
6. Rebuild `docs/PROGRESS.md` if it conflicts with `tasks.md` and the event log.

## User Gate

Before resuming, show:

```markdown
## Continuing Orchestration

Plan: <tasks.md path>
Completed: <n>
Needs verification: <n>
Needs restart: <n>
Remaining: <n>

Type `go` to resume.
```

After approval, continue using the same execution loop as `/orchestrate`.

## Rules

- Do not rerun completed and reviewed tasks.
- Do not skip verification for tasks that were in progress during interruption.
- Do not skip review unless review mode is `solo`.
- Do not commit if Unity compilation errors are present.
- Never run `git push`.

$ARGUMENTS

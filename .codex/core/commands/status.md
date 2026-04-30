# Status

Report the current state of the Codex workflow.

## Inputs

Check:

- `.codex/project/PROJECT.md`
- `.codex/project/STRUCTURE.md`
- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`
- `.codex/project/EVENTS.jsonl`
- `.codex/runtime/orchestration-active.json`
- `.codex/runtime/mailbox/`
- `.codex/runtime/heartbeat/`

## Process

1. Determine whether a workflow exists.
2. Determine status: not started, ready, running, paused, failed, completed, or
   unknown.
3. If events exist, read recent events and summarize.
4. If progress exists, summarize phase and task counts.
5. If runtime state exists, report active agents and stale heartbeats.
6. Report the next useful action.

## Output

```markdown
## Codex Workflow Status

Project: [name or unknown]
Status: [not-started|ready|running|paused|failed|completed|unknown]
Current phase: [current / total - name]
Next action: [action]

Documents:
- Project: [yes/no]
- Workflow: [yes/no]
- Progress: [yes/no]
- Events: [yes/no]

Tasks:
- Done: [count]
- Working: [count]
- Review: [count]
- Failed: [count]
- Pending: [count]

Agents:
- Active: [count]
- Stale heartbeat: [count]

Recent events:
- [event summary]

Blockers:
- [none or list]
```

Keep it short. This is a dashboard-style command.

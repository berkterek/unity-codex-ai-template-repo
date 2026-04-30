# Event Journal Protocol

`EVENTS.jsonl` is the append-only source of truth for workflow recovery.

Recommended path:

```text
.codex/project/EVENTS.jsonl
```

## Format

One JSON object per line:

```json
{"ts":"2026-04-30T10:00:00Z","event":"orchestration_started","data":{"phases":5,"tasks_total":24}}
```

## Event Types

| Event | When | Data |
|-------|------|------|
| `orchestration_started` | Run begins | `phases`, `tasks_total` |
| `agent_spawned` | Agent starts | `agent`, `type`, `task`, `phase` |
| `agent_completed` | Agent succeeds | `agent`, `task`, `files` |
| `agent_failed` | Agent fails | `agent`, `task`, `reason` |
| `task_status` | Task changes state | `task`, `from`, `to`, `agent` |
| `review_verdict` | Review finishes | `task`, `verdict`, `reviewer`, `issues` |
| `phase_transition` | Phase changes | `from`, `to`, `name` |
| `commit_created` | Commit made | `phase`, `sha`, `message` |
| `orchestration_paused` | User pauses | `reason`, `phase` |
| `orchestration_completed` | Run completes | `phases`, `tasks_total`, `duration` |
| `orchestration_failed` | Run cannot continue | `reason`, `phase` |
| `error` | Error observed | `agent`, `task`, `message` |
| `blocker` | Agent reports blocker | `agent`, `task`, `message` |

## Rules

- Append only.
- Never rewrite history.
- Write the event before updating `PROGRESS.md`.
- Keep each event on one line.
- If an event payload changes, keep old fields backward compatible.


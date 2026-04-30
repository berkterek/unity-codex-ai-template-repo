# Checkpoint Protocol

Checkpoints preserve agent and orchestrator context across compaction,
interruptions, and restarts.

Recommended paths:

```text
.codex/runtime/checkpoint/{agent-id}.md
.codex/runtime/orchestrator-state.md
.codex/runtime/orchestration-active.json
```

## Agent Checkpoint

```markdown
# Checkpoint: coder-1

## Task
- ID: P1.T1
- Title: Add core interface

## Completed
- src/Foo.cs - added interface

## In Progress
- tests/FooTests.cs - started edge case tests

## Key Decisions
- Used existing repository fake style instead of adding a mocking dependency.

## Blockers
- None
```

Agents should update checkpoints:

- At start when resuming previous work.
- After every meaningful file or test group.
- Before long waits.
- When a blocker appears.

## Orchestrator State

```markdown
# Orchestrator State

## Updated
- 2026-04-30T10:00:00Z

## Current Phase
- Phase: 1 / 5
- Name: Foundation
- Status: waiting

## Current Tasks
| Task | Status | Agent | Notes |
|------|--------|-------|-------|
| P1.T1 | running | coder-1 | heartbeat current |

## Affinity Map
- coder-1: src/Foo.cs, tests/FooTests.cs

## Blockers
- None

## Next Steps
- Wait for coder-1, then review P1.T1.
```

## Active Marker

`orchestration-active.json` indicates that a run is active:

```json
{"started":"2026-04-30T10:00:00Z","phase":1,"phaseName":"Foundation"}
```

Stop/pause commands remove only the active marker. They do not delete
checkpoints.

## Rules

- Checkpoints are working memory, not authoritative history.
- Events remain the authoritative state source.
- Do not delete checkpoints for active or paused work.
- Include checkpoint content when restarting an interrupted task.


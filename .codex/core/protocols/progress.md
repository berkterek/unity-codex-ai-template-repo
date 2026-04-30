# Progress Protocol

`PROGRESS.md` is the human-readable workflow status file. It is optimized for
quick status checks and dashboards. It is not the source of truth when an event
journal exists; `EVENTS.jsonl` is.

Recommended path:

```text
.codex/project/PROGRESS.md
```

## Required Header

```markdown
# Codex Workflow Progress
## Status: running
## Phase: 1 / 5
## Phase Name: Foundation
## Started: 2026-04-30T10:00:00Z
```

Allowed statuses:

- `not-started`
- `ready`
- `running`
- `paused`
- `completed`
- `failed`

## Phases Table

```markdown
## Phases
| # | Name | Status |
|---|------|--------|
| 1 | Foundation | active |
| 2 | Feature Work | pending |
```

Allowed phase statuses:

- `pending`
- `active`
- `done`
- `paused`
- `failed`

## Agents Table

```markdown
## Agents
| Agent | Type | Status | Task | Progress |
|-------|------|--------|------|----------|
| coder-1 | coder | running | P1.T1 | 50% |
```

Allowed agent statuses:

- `idle`
- `running`
- `reviewing`
- `passed`
- `failed`
- `paused`

## Tasks Table

```markdown
## Tasks
| ID | Title | Status | Agent | Complexity |
|----|-------|--------|-------|------------|
| P1.T1 | Add core interface | working | coder-1 | S |
```

Allowed task statuses:

- `pending`
- `working`
- `review`
- `done`
- `failed`
- `paused`

Complexity values are project-defined. Suggested values:

- `S`
- `M`
- `L`
- `XL`

## Log

```markdown
## Log
[2026-04-30T10:00:00Z] [system] Orchestration started
[2026-04-30T10:02:00Z] [agent:coder-1] Started P1.T1
```

## Rules

- Update after significant state changes.
- Keep formatting stable.
- Use `-` for empty cells if the dashboard cannot handle blanks.
- Do not use progress as the only recovery source when events exist.


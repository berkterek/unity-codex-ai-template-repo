# Workflow Overlay

This file defines the current project execution plan. It is consumed by
`.codex/core/commands/orchestrate.md`, `dry-run.md`, `validate.md`, and
`continue.md`.

## Metadata

| Field | Value |
|-------|-------|
| Workflow version | `0.1` |
| Status | `[draft / ready / running / paused / completed]` |
| Created | `[ISO_DATE]` |
| Based on | `[PROJECT.md / issue / spec / design doc]` |

## Agent Team

| Agent type | Count | Notes |
|------------|-------|-------|
| coder | `[n]` | `[notes]` |
| tester | `[n]` | `[notes]` |
| reviewer | `1` | quality gate |
| committer | `[0/1]` | `[per phase / final / none]` |

## Phases

### Phase 1: `[PHASE_NAME]`

**Goal:** `[phase goal]`

**Entry Criteria:**
- `[criterion]`

**Exit Criteria:**
- `[criterion]`

**Parallel Capacity:** `[n]`

#### P1.T1: `[TASK_TITLE]`

- **Type:** `[implementation / test / review / docs / tooling / pack-specific]`
- **Agent:** `[coder / tester / reviewer / committer / pack-agent]`
- **Complexity:** `[S / M / L / XL]`
- **Inputs:**
  - `[path]`
- **Outputs:**
  - `[path]`
- **Description:** `[specific instructions]`
- **Acceptance Criteria:**
  - `[ ] [criterion]`
- **Parallel Group:** `[P1-A]`
- **Dependencies:** `[none or task ids]`

### Phase 2: `[PHASE_NAME]`

Add more phases as needed.

## Dependency Graph

Use plain text, Mermaid, or a table:

```text
P1.T1 -> P1.T2 -> P2.T1
```

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `[risk]` | `[low/medium/high]` | `[low/medium/high]` | `[plan]` |

## Commit Policy

Choose one:

- `per-phase`
- `final-only`
- `manual`
- `none`

Selected: `[policy]`


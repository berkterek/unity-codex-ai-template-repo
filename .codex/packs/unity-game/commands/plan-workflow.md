# Plan Workflow — GDD + TDD → Parallelized Execution Plan

Reads the GDD and TDD and produces a comprehensive, parallelism-optimized
execution workflow plan that orchestration agents will follow.

## Usage

```
/plan-workflow
```

No argument needed. Both `docs/GDD.md` and `docs/TDD.md` must exist.

---

## Inputs To Read

Before starting, read:

- `docs/GDD.md` (REQUIRED — if missing, stop and tell user to run `/game-idea`)
- `docs/TDD.md` (REQUIRED — if missing, stop and tell user to run `/architect`)
- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/project/WORKFLOW.md`
- `.codex/packs/unity-game/rules/architecture.md`

If either `docs/GDD.md` or `docs/TDD.md` is missing, stop immediately and
tell the user which document is missing and which command to run.

---

## Planning Principles

### Parallelism is Key

- Multiple agents will execute this plan simultaneously.
- Independent systems MUST be scheduled in parallel.
- Identify the critical path and optimize around it.

### Correct Build Order

1. **Infrastructure First** — core frameworks everything depends on (event
   system, pools, config, service locator).
2. **Pure C# Logic** — all game logic in pure C# with zero Unity dependencies.
3. **Tests for Logic** — unit tests for every pure C# system.
4. **Unity Integration Layer** — MonoBehaviour adapters, ScriptableObject
   definitions.
5. **Unity Scene Setup** — create scene hierarchy, prefabs, pools.
6. **Integration Tests** — tests that require Unity runtime.
7. **Polish and Wiring** — final assembly, configuration, edge cases.

### Task Granularity

- Each task should be completable by ONE agent in ONE session.
- Tasks should produce 1–3 files typically.
- Each task must have clear inputs (what files to read) and outputs (what
  files to produce).

---

## Your Process

### Step 1: Dependency Graph

Build a complete dependency graph:
- List every deliverable (class, interface, test, SO, prefab).
- Map dependencies between them.
- Identify the critical path.

### Step 2: Phase Definition

Group tasks into phases. Within each phase, tasks are parallelizable.

### Step 3: Task Specification

For each task, define:
- **Task ID**: `P{phase}.T{task}` (e.g., P1.T3)
- **Title**: Clear, concise description.
- **Type**: `infrastructure` | `logic` | `test` | `integration` |
  `unity-setup` | `polish`
- **Agent Type**: `coder` | `tester` | `unity-setup`
- **Inputs**: Files/interfaces this task depends on.
- **Outputs**: Files this task will produce (full paths).
- **Description**: Detailed implementation instructions.
- **Acceptance Criteria**: Exact, verifiable conditions for "done".
- **Complexity**: `S` (<100 LOC) | `M` (100–300) | `L` (300–600) | `XL`
  (600+, should be split)
- **Parallel Group**: Which tasks can run simultaneously.

### Step 4: Agent Team Plan

Recommend:
- Number of coder agents needed per phase.
- Number of tester agents needed per phase.
- Review checkpoints.
- Unity MCP setup scheduling.

### Step 5: Risk Assessment

Identify:
- Tasks most likely to cause merge conflicts.
- Tasks with highest technical risk.
- Bottleneck tasks on the critical path.
- Suggested mitigation for each risk.

### Step 6: Verify with Developer

Ask the developer:
- Does the parallelism level seem right?
- Any phases they prefer to do manually?
- Any systems to prioritize or deprioritize?

Wait for answers before finalizing.

---

## Output — Save to docs/WORKFLOW.md

Use this structure:

```markdown
# [Game Name] — Execution Workflow Plan
**Version:** 1.0
**Date:** [today's date]
**Based on:** GDD v1.0, TDD v1.0
**Status:** Ready for Orchestration

---

## 1. Overview
- Total phases: X
- Total tasks: Y
- Critical path length: N tasks
- Recommended agent team: X coders, Y testers, 1 reviewer

## 2. Dependency Graph
[Mermaid diagram]

## 3. Phases

### Phase 1: Infrastructure Foundation
**Goal:** Establish core frameworks.
**Parallel Capacity:** [how many agents]
**Entry Criteria:** None (first phase)
**Exit Criteria:** All infrastructure systems pass unit tests

#### P1.T1: [Task Title]
- **Type:** infrastructure
- **Agent:** coder
- **Inputs:** None
- **Outputs:** [file paths]
- **Description:** [implementation notes]
- **Acceptance Criteria:**
  - [ ] Criterion
- **Complexity:** M
- **Parallel Group:** P1-A

...

## 4. Review Checkpoints
- After each phase completion
- After any XL-complexity task
- Before phase transitions

## 5. Risk Register
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ... | ... | ... | ... |
```

After generating, ask the developer to review the plan and make adjustments.

Once confirmed, print:

```
Workflow plan saved: docs/WORKFLOW.md
Run /orchestrate to begin automated execution.
```

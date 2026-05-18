# Plan Workflow — GDD + TDD → Parallelized Execution Plan

Reads the GDD and TDD and produces a comprehensive, parallelism-optimized execution workflow plan that orchestration agents will follow.

## Usage

```
/plan-workflow
```

No argument needed. Both `docs/GDD.md` and `docs/TDD.md` must exist.

---

## Initialization

**Prerequisite check:** Verify both `docs/GDD.md` and `docs/TDD.md` exist. If either is missing, stop immediately — tell the user which is missing and which command to run (`/game-idea` for GDD, `/architect` for TDD). Do NOT proceed without both.

Read:
- `docs/GDD.md` thoroughly
- `docs/TDD.md` thoroughly
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`

---

## Planning Principles

### Parallelism is Key

- Multiple AI agents will execute this plan simultaneously.
- Independent systems MUST be scheduled in parallel.
- Identify the critical path and optimize around it.
- Agent teams: ~4 coders, ~2 testers, 1 reviewer (adjust based on project size).

### Correct Build Order

1. **Infrastructure First** — core frameworks everything depends on (event system, pools, config)
2. **Pure C# Logic** — all game logic in pure C# with zero Unity dependencies
3. **Tests for Logic** — unit tests for every pure C# system
4. **Unity Integration Layer** — MonoBehaviour adapters, ScriptableObject definitions
5. **Unity Scene Setup** — create scene hierarchy, prefabs, pools via MCP
6. **Integration Tests** — tests that require Unity runtime
7. **Polish and Wiring** — final assembly, configuration, edge cases

### Task Granularity

- Each task completable by ONE agent in ONE session.
- Tasks produce 1–3 files typically (a system + its interface, or a test class).
- Each task must have clear inputs (what files to read) and outputs (what files to produce).

---

## Your Process

### Step 1: Dependency Graph

Build a complete dependency graph:
- List every deliverable (class, interface, test, SO, prefab).
- Map dependencies between them.
- Identify the critical path (longest chain of sequential dependencies).

### Step 2: Phase Definition

Group tasks into phases. Within each phase, tasks are parallelizable.

### Step 3: Task Specification

For each task, define:
- **Task ID**: `P{phase}.T{task}` (e.g., P1.T3)
- **Title**: Clear, concise description
- **Type**: `infrastructure` | `logic` | `test` | `integration` | `unity-setup` | `polish`
- **Agent Type**: `coder` | `tester` | `unity-setup`
- **Inputs**: Files/interfaces this task depends on (must exist before starting)
- **Outputs**: Files this task will produce (full paths)
- **Description**: Detailed implementation instructions referencing specific TDD sections
- **Acceptance Criteria**: Exact, verifiable conditions for "done"
- **Complexity**: `S` (<100 LOC) | `M` (100–300) | `L` (300–600) | `XL` (600+, should be split)
- **parallel_group**: Integer (1, 2, 3…) or `—` if sequential. See Parallel Group Rules below.

### Parallel Group Rules

1. **Compile-time dependency (most important):** If Task B's code references a type introduced by Task A → Task B MUST be sequential after Task A. Different files ≠ safe to parallelize when there is a type dependency.
2. **File write conflict:** If two tasks write to the same file → they MUST be sequential.
3. **Independent:** If two tasks write to entirely different files AND neither references types introduced by the other → assign same integer `parallel_group`.
4. Tasks with no parallel candidate get `—`.

**Format required by `/orchestrate`** — use integer column:

| parallel_group | Meaning |
|----------------|---------|
| `1` | Can run simultaneously with other group-1 tasks |
| `2` | Can run simultaneously with other group-2 tasks |
| `—` | Sequential |

### Step 4: Agent Team Plan

Recommend:
- Number of coder agents needed per phase
- Number of tester agents needed per phase
- Review checkpoints (after which tasks should reviewer run?)
- Unity MCP setup scheduling

### Step 5: Risk Assessment

Identify:
- Tasks most likely to cause merge conflicts (agents writing to same files)
- Tasks with highest technical risk
- Bottleneck tasks on the critical path
- Suggested mitigation for each risk

### Step 6: Verification Questions

Ask the developer:
- Does the parallelism level seem right for their machine?
- Any phases they'd prefer to do manually?
- Any systems they want to prioritize or deprioritize?
- Preferences on agent team size?

Wait for answers before finalizing.

---

## Output — Save to docs/WORKFLOW.md

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
- Estimated parallel efficiency: Z% (parallel tasks / total tasks)
- Critical path length: N tasks
- Recommended agent team: X coders, Y testers, 1 reviewer

## 2. Dependency Graph
[Mermaid diagram]

## 3. Phases

### Phase 1: Infrastructure Foundation
**Goal:** Establish core frameworks.
**Parallel Capacity:** [how many agents can work simultaneously]
**Entry Criteria:** None (first phase)
**Exit Criteria:** All infrastructure systems pass unit tests

#### P1.T1: [Task Title]
- **Type:** infrastructure
- **Agent:** coder
- **Inputs:** None
- **Outputs:**
  - `Assets/_Framework/Events/IEventBus.cs`
  - `Assets/_Framework/Events/EventBus.cs`
- **Description:** [detailed implementation notes referencing TDD sections]
- **Acceptance Criteria:**
  - [ ] Interface defines Subscribe<T>, Unsubscribe<T>, Publish<T>
  - [ ] Implementation uses dictionary of delegate lists
  - [ ] Zero allocation on Publish
- **Complexity:** M
- **parallel_group:** 1

...

## 4. Agent Team Configuration
- Coder agents: phases active, task assignments
- Tester agents: phases active, task assignments
- Reviewer: checkpoints and criteria
- Unity Setup agent: Phase 5 task plan

## 5. Review Checkpoints
- After each phase completion
- After any XL-complexity task
- Before phase transitions

## 6. Risk Register
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|

## 7. Merge Strategy
- File ownership rules (each task owns specific files)
- Conflict resolution strategy
- Integration verification steps
```

After generating, ask the developer to review the plan. Make adjustments.

Once confirmed:
```
Workflow plan saved: docs/WORKFLOW.md
Run /orchestrate to begin automated execution.
```

## Rules

- **Be precise with file paths.** Every task must specify exact output file paths matching the TDD folder structure.
- **No circular dependencies between tasks.** Restructure if found.
- **Maximize parallelism** without sacrificing correctness.
- **Each task must be self-contained** — completable with only the listed inputs.
- **Acceptance criteria must be verifiable** — no subjective criteria like "good quality."

$ARGUMENTS

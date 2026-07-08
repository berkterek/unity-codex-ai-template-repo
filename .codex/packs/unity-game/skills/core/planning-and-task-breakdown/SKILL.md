---
name: planning-and-task-breakdown
description: "Use when breaking Unity work into roadmap modules and orchestrate-ready module tasks."
---

# Planning And Task Breakdown

New work uses:

1. `docs/ROADMAP.md`
2. `docs/modules/<n>-<name>/spec.md`
3. `docs/modules/<n>-<name>/design.md`
4. `docs/modules/<n>-<name>/tasks.md`

Legacy `docs/WORKFLOW.md` is supported only for older projects.

## When To Use

- `/roadmap`
- `/plan-module`
- `/create-plan` for module-level or feature-level planning
- Before parallel agent work
- When a task is too broad or ambiguous

## Task Shape

Each task in `tasks.md` should use:

```markdown
- [ ] T001 [parallel_group:1] `Assets/.../File.cs` — concise task title
  - Type: Add | Modify | Delete
  - Agent: coder | unity-coder | unity-setup | tester
  - Test type: EditMode | PlayMode | NoTest
  - Inputs: `path`
  - Outputs: `path`
  - Acceptance: specific, testable condition
```

## Dependency Rules

- Interfaces before implementations.
- Tests before implementations when behavior is logic-heavy.
- `ConfigCatalog` and `AppModules` edits are sequential unless the write scope is
  isolated.
- Scene/prefab tasks run through `unity-setup` and MCP.
- Shared output files cannot be in the same `parallel_group`.

## Vertical Slices

Prefer tasks that deliver a working slice:

```text
IService -> failing test -> Service -> Module wiring -> checkpoint
```

Avoid horizontal batches like "all interfaces" unless they are truly independent
and small.

## Parallelization

Can parallelize:

- Independent interfaces
- Independent tests
- Independent providers/prefabs
- Documentation-only tasks

Must be sequential:

- Shared public interface changes
- `AppModules.cs`
- `ConfigCatalog.cs`
- Scene or prefab operations touching the same asset
- Any task that depends on generated code from a prior task

## Checkpoints

Add a checkpoint after each playable slice:

```markdown
**Checkpoint: Phase 1 independent test passes.**
```

At a checkpoint, `/orchestrate` should run guardrails, compile/test verification,
and ask before proceeding.

## Verification Checklist

- [ ] Every task has outputs.
- [ ] Every logic task has test type or NoTest rationale.
- [ ] Acceptance criteria are observable.
- [ ] Parallel groups have no output conflicts.
- [ ] Critical architecture files are called out.
- [ ] Human approves the plan before execution.

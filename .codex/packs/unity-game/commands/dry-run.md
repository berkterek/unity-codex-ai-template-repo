# Dry Run — Preview Orchestration Plan

Preview what `/orchestrate` WOULD do without actually executing anything. Lets the developer see the full execution plan before committing resources.

## Initialization

1. **Prerequisite check:** Verify `docs/GDD.md`, `docs/TDD.md`, and `docs/WORKFLOW.md` all exist. If any are missing, tell the user which to create first.
2. Read all three documents.
3. Read `.codex/project/RULES.md` for constraints.
4. Check if `$ARGUMENTS` contains `--eco`. If present, use the eco routing table for all model assignments in the preview.

## Process

Analyze `docs/WORKFLOW.md` and produce an execution preview:

```
## Orchestration Dry Run

### Execution Summary
- Mode: [Standard | Eco]
- Total phases: X
- Total tasks: Y
- Estimated agent spawns: Z (including re-reviews)
- Max concurrent agents per phase: [list per phase]

### Phase-by-Phase Breakdown

#### Phase 1: [Name]
- Tasks: N
- Parallel groups: M
- Agent assignments:
  | Group | Task | Agent Type | Files Produced |
  |-------|------|-----------|----------------|
  | 1     | P1.T1 | unity-coder | file1.cs, file2.cs |
  | 1     | P1.T2 | unity-coder-lite | file3.cs |
  | seq   | P1.T3 | unity-setup | Bootstrap.unity |
  | R     | Review batch 1 | unity-reviewer | — |

#### Phase 2: [Name]
...

### Resource Estimate
- Coder agent invocations: X
- Tester agent invocations: Y
- Reviewer agent invocations: Z (1 per batch + ~20% re-review estimate)
- Unity setup agent invocations: W
- Total estimated agent invocations: TOTAL

### Risk Points
- [Tasks most likely to need re-review]
- [Potential file conflicts between parallel tasks]
- [Critical path bottlenecks]

### Proceed?
Run `/orchestrate` to execute this plan.
```

## Agent Routing Table

| Target | Simple (0.0–0.3) | Medium/Complex (0.4–1.0) |
|--------|-----------------|--------------------------|
| Pure C# (`_Framework/`, `Abstracts/`) | `coder` | `coder` |
| MonoBehaviour, Provider, Installer | `unity-coder-lite` | `unity-coder` |
| Scene / prefab wiring | `unity-setup` | `unity-setup` |

## Rules

- Do NOT spawn any agents or write any code
- Do NOT modify any files
- Be realistic about re-review estimates (assume ~20% of tasks need one re-review)
- Show the developer exactly what they're committing to

$ARGUMENTS

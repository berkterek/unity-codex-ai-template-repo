# Dry Run — Preview Module Orchestration

Preview what `/orchestrate <tasks.md>` would do without writing files, spawning
subagents, or modifying task checkboxes.

## Usage

```text
/dry-run docs/modules/01-core-loop/tasks.md
/dry-run docs/modules/01-core-loop/tasks.md --eco
```

## Initialization

1. Parse `$ARGUMENTS` for a `tasks.md` path.
2. If missing, infer the next pending module from `docs/ROADMAP.md`.
3. Read `.codex/project/RULES.md`, `docs/ROADMAP.md`, and the chosen `tasks.md`.
4. Check `--eco` for low-cost routing preview.

If no module plan is available, tell the user to run `/roadmap` and then
`/plan-module <n>`.

## Preview

Analyze tasks and print:

```markdown
## Orchestration Dry Run

Plan: <tasks.md>
Mode: Standard | Eco
Total tasks: <n>
Pending tasks: <n>
Completed tasks skipped: <n>
Estimated subagent calls: <n>
Max parallelism: <n>

### Task Breakdown

| Group | Task | Agent | Test Type | Outputs |
|-------|------|-------|-----------|---------|
| 1 | T001 | coder | EditMode | path.cs |

### Risk Points

- Output conflicts in parallel groups
- Critical architecture files
- Scene/prefab MCP requirements
- Tests or packages missing

### Next

Run `/orchestrate <tasks.md>` to execute.
```

## Agent Routing Table

| Target | Simple | Medium/Complex |
|--------|--------|----------------|
| Pure C# (`_Framework/`, `Games/Abstracts/`) | `coder` | `coder` |
| MonoBehaviour, Provider, static Module wiring | `unity-coder-lite` | `unity-coder` |
| Scene / prefab / asset wiring | `unity-setup` | `unity-setup` |

## Rules

- Do not spawn agents.
- Do not write code.
- Do not modify `tasks.md`.
- Surface file conflicts and missing prerequisites clearly.

$ARGUMENTS

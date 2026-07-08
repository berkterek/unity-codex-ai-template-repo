# Pipeline Status Reporter

Report the current Unity template pipeline state. Prefer the module roadmap
system, but still recognize legacy `docs/WORKFLOW.md` projects.

## Process

1. Check which documents exist:
   - `docs/GDD.md`
   - `docs/TDD.md`
   - `docs/ROADMAP.md`
   - `docs/modules/*/tasks.md`
   - `docs/PROGRESS.md`
   - `docs/EVENTS.jsonl`
   - legacy `docs/WORKFLOW.md`

2. Determine the current stage:
   - No docs -> suggest `/game-idea`
   - GDD only -> suggest `/architect`
   - GDD + TDD, no ROADMAP -> suggest `/roadmap`
   - ROADMAP exists, missing module plans -> suggest `/plan-module <next>`
   - Module `tasks.md` exists with pending tasks -> suggest `/orchestrate <tasks.md>`
   - All module tasks complete -> suggest `/validate` or `/smart-commit`
   - Legacy WORKFLOW only -> report legacy mode and suggest migrating through `/roadmap`

3. If `docs/ROADMAP.md` exists, summarize module counts by status.

4. If module task files exist, summarize:
   - Total tasks
   - Complete tasks
   - Pending tasks
   - Blocked markers

5. If `docs/EVENTS.jsonl` exists, show the last 10 relevant events.

6. Scan generated project assets when `Assets/` exists:
   - C# files
   - Test files
   - Config assets
   - Prefabs

## Output Format

```markdown
## Unity Pipeline Status

Project: <name or Not started>
Current Stage: <stage>
Next Action: <command>

### Documents
- GDD: yes/no
- TDD: yes/no
- Roadmap: yes/no
- Module plans: <count>
- Legacy WORKFLOW: yes/no

### Module Progress
- Pending: <count>
- In Progress: <count>
- Complete: <count>
- Blocked: <count>
- Tasks: <complete>/<total>

### Recent Events
- <timestamp> <event> <summary>

### Generated Assets
- C# Scripts: <count>
- Test Files: <count>
- Config Assets: <count>
- Prefabs: <count>
```

Keep the output short and actionable.

$ARGUMENTS

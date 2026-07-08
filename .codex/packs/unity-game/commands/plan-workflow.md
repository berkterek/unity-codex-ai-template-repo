# Plan Workflow — Legacy WORKFLOW.md Planner

This command is retained for existing projects that still use
`docs/WORKFLOW.md`.

For new work, prefer:

1. `/roadmap`
2. `/plan-module <n|slug>`
3. `/dry-run docs/modules/<n>-<name>/tasks.md`
4. `/orchestrate docs/modules/<n>-<name>/tasks.md`

## Legacy Use

Only use `/plan-workflow` when the repository already has a legacy
`docs/WORKFLOW.md` pipeline and the user explicitly asks to maintain it.

If the user did not explicitly request legacy mode, stop and suggest:

```text
This template now uses ROADMAP + module tasks.
Run /roadmap, then /plan-module <n>.
```

$ARGUMENTS

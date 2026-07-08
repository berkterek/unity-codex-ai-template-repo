# Game Plan — Legacy Planner

This command is retained for compatibility with older projects. New projects
should use the module roadmap pipeline:

1. `/roadmap`
2. `/plan-module <n|slug>`
3. `/orchestrate docs/modules/<n>-<name>/tasks.md`

If the user asks for `/game-plan` without explicitly requesting legacy output,
explain that the current Codex template uses `docs/ROADMAP.md` plus
`docs/modules/<module>/spec.md`, `design.md`, and `tasks.md`, then offer to run
`/roadmap`.

Do not create new `docs/0_MasterPlan.md` or numbered standalone plan files for
new work.

$ARGUMENTS

# Lean Planner

Produces a compact 3-5 task plan from researcher findings. Used by `/create-plan --lean`. No code skeletons, no acceptance criteria, no parallel groups. Never triggers implementer auto-spawn.

## Output Format

# PLAN — <Title> (LEAN)

> Version: v1 — <date>
> Mode: lean
> Status: Active

## Tasks

| # | Task | Files | Notes |
|---|------|-------|-------|
| 1 | <task name> | `path/to/File.cs` | one-line description |
| 2 | ... | ... | ... |

## Notes
- Maximum 5 tasks. If scope requires more, tell the user to re-run /create-plan without --lean.
- No code skeletons
- No acceptance criteria
- No parallel_group annotations
- Implementer auto-spawn: DISABLED — never spawn any pipeline agent after producing this plan.
- To expand to a full plan: re-run /create-plan without --lean flag

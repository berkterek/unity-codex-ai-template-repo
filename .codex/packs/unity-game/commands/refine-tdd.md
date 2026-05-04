# Refine TDD — Technical Design Document Iteration

You are the same senior architect from the TDD creation phase, returning to update
the Technical Design Document based on GDD changes or architectural insights.

## Inputs To Read

Read these when they exist:

- `docs/TDD.md` — required; this is the document you're refining.
- `docs/GDD.md`
- `.codex/project/RULES.md`
- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`

## Process

### Understand the Change

If the user provided specific changes, analyze them. Otherwise:
- Compare GDD version with the version the TDD was based on.
- If GDD was updated, identify the delta.
- Ask the developer what architectural changes are needed.

### Impact Assessment

This is critical when code already exists:
- **Not yet built**: Free to change anything in the TDD.
- **Already built**: Changes require migration plan.

Present the impact:

```
## TDD Change Impact

### Changes Needed
- [list of TDD sections to update]

### Code Impact (if code exists)
- New files: [list]
- Modified files: [list]
- Deleted files: [list]
- Breaking interface changes: [YES/NO — details]

### Risk: [LOW|MEDIUM|HIGH]
```

### Make Changes

- Update `docs/TDD.md` with architectural changes.
- Maintain ALL constraints from `.codex/project/RULES.md`.
- Bump version.
- Add changelog entry.
- If interfaces change, clearly mark breaking changes.

### Update Recommendations

If code exists:
- Generate a migration checklist for existing code.
- Suggest whether to refactor in-place or rebuild affected systems.

If `.codex/project/WORKFLOW.md` exists:
- Warn that the execution plan needs updating.

## Rules

- All constraints still apply — no relaxing rules during refinement.
- Prefer additive changes — extend interfaces, don't break them.
- If code exists, be careful — breaking changes cascade to tests, adapters, scene
  setup.
- Version everything — clear changelog in the TDD.
- Ask before breaking — if a change would break existing implementations, confirm
  with the developer.

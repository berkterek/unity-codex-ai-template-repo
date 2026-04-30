# Validate

Validate whether a workflow phase is actually complete.

## Inputs

Read:

- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`
- `.codex/project/STRUCTURE.md`
- `.codex/project/TOOLING.md`
- Task outputs for the selected phase.
- Relevant project rules and pack rules.

If the user specifies a phase, validate that phase. Otherwise validate the most
recent completed or active phase.

## Checks

### File Checks

- Every expected output exists.
- Files are not empty placeholders.
- Deleted files were intended.

### Acceptance Criteria

- Each criterion is verified with evidence.
- Criteria that cannot be verified are marked unknown, not assumed.

### Consistency

- Interfaces/contracts match implementations.
- Imports/dependencies respect allowed boundaries.
- Naming and layout match project conventions.
- No obvious circular dependencies were introduced.

### Tests And Verification

- Required tests exist.
- Relevant tests pass, or failures are reported.
- Build/lint/typecheck commands from tooling pass when available.

### Pack-Specific Checks

Apply enabled pack validation. Examples:

- Editor/tooling packs may require their own smoke checks.
- Web pack may require browser smoke tests.
- Backend pack may require migration or API contract checks.

## Output

```markdown
## Phase Validation Report: [phase]

Status: PASS | FAIL
Tasks validated: [x/y]
Acceptance criteria: [met/total]

File check:
| Expected file | Exists | Valid |
|---------------|--------|-------|
| path | yes/no | yes/no/unknown |

Criteria:
- [PASS/FAIL] [task] [criterion] - [evidence]

Verification:
- [command]: [result]

Issues:
1. [BLOCKING|WARNING] [description]

Recommendation:
[Proceed / Fix issues before proceeding]
```

## Rules

- Be specific.
- Reference files and lines where possible.
- Do not block on preferences not defined by the project.
- Do block on missing outputs, failed acceptance criteria, broken builds, or
  untested risky behavior.

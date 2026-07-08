---
name: plan-module
description: Create docs/modules/<n>-<name>/spec.md, design.md, and tasks.md for one roadmap module.
---

# Plan Module — Just-In-Time Module Planner

Plan exactly one module from `docs/ROADMAP.md`. Output is a
`docs/modules/<n>-<name>/` folder containing `spec.md`, `design.md`, and
`tasks.md`. The generated `tasks.md` must be directly executable by
`/orchestrate docs/modules/<n>-<name>/tasks.md`.

## Usage

```text
/plan-module 01
/plan-module 01-core-loop
```

## Inputs To Read

1. `AGENTS.md`
2. `.codex/packs/unity-game/guides/guardrails.md`
3. `.codex/project/PROJECT.md`
4. `.codex/project/RULES.md`
5. `docs/ROADMAP.md`
6. `docs/GDD.md`
7. `docs/TDD.md`
8. `.codex/templates/modules/spec.md`
9. `.codex/templates/modules/design.md`
10. `.codex/templates/modules/tasks.md`

## Rules

- Plan only the requested module.
- If `docs/modules/<n>-<name>/` already exists, stop and tell the user to use
  `/update-plan`; do not overwrite existing module plans.
- Scan the current codebase before planning. Existing target files become
  `Modify` tasks, not `Add` tasks.
- `tasks.md` must use checkbox tasks, explicit file paths, acceptance criteria,
  test type decisions, and optional `[parallel_group:N]` annotations.
- Keep write scopes disjoint for parallel groups. If two tasks write the same
  file, they cannot share a parallel group.
- Use Codex paths and terminology. Never write `.claude/` paths.

## Process

### Step 1 — Resolve Module

Parse `$ARGUMENTS` as a module number or slug. Read `docs/ROADMAP.md` and find
the matching row.

If no row matches, stop:

```text
Module not found in docs/ROADMAP.md: <argument>
Run /roadmap first or update the roadmap manually.
```

If the module folder already exists, stop:

```text
Module already planned: docs/modules/<n>-<name>/
Use /update-plan to revise the existing plan.
```

### Step 2 — Codebase Scan

Scan likely target folders:

- `Assets/_Framework/`
- `Assets/_GameFolders/Scripts/Games/Abstracts/`
- `Assets/_GameFolders/Scripts/Games/Concretes/`
- `Assets/_GameFolders/Scripts/Tests/`

If `.codex/project/FEATURES.json` enables graph and `.codex/graph/graph.json`
exists, prefer graph lookups and report graph confidence.

### Step 3 — Architecture Gate

Before writing files, show:

```markdown
## ARCHITECTURE_GATE — <n>-<name>

GDD summary: <what the module does>

Proposed structure:
- Abstracts: <interfaces>
- Concretes: <services, handlers, providers, configs>
- Module wiring: <Domain>Module.Install(...)
- Events: <IEvent structs>
- Tests: <EditMode/PlayMode/NoTest decisions>

Type `go` to create the module plan, or describe changes.
```

Do not write files until the user says `go`.

After approval, write:

```bash
mkdir -p .codex/project/state
printf '{"gate":"ARCHITECTURE_GATE","pipeline":"plan-module","module":"<n-name>","ts":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > .codex/project/state/gate-cleared
```

### Step 4 — Create Plan Files

Create:

- `docs/modules/<n>-<name>/spec.md`
- `docs/modules/<n>-<name>/design.md`
- `docs/modules/<n>-<name>/tasks.md`

Use the templates under `.codex/templates/modules/` and fill them with concrete
module content. Do not leave placeholder examples in final module plans.

### Step 5 — Update Roadmap

Update the matching `docs/ROADMAP.md` row:

- `Status` -> `Pending`
- `Plan` -> `[plan](modules/<n>-<name>/tasks.md)`

### Step 6 — Report

Print:

```text
Module planned: docs/modules/<n>-<name>/

Created:
- spec.md
- design.md
- tasks.md

Next: /orchestrate docs/modules/<n>-<name>/tasks.md
```

$ARGUMENTS

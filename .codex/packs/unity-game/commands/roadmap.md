---
name: roadmap
description: Create or update docs/ROADMAP.md from GDD, TDD, and existing module plans. Produces the module table used by /plan-module.
---

# Roadmap — Module Roadmap Generator

Create or update `docs/ROADMAP.md` by reading the project design docs and the
existing `docs/modules/` directory. The roadmap is the entry point for
just-in-time module planning.

## Usage

```text
/roadmap
```

## Inputs To Read

Read these files when they exist:

1. `AGENTS.md`
2. `.codex/packs/unity-game/guides/guardrails.md`
3. `.codex/project/PROJECT.md`
4. `.codex/project/RULES.md`
5. `docs/GDD.md`
6. `docs/TDD.md`
7. `docs/ROADMAP.md`
8. `docs/modules/*/tasks.md`

## Process

### Step 1 — Module Inventory

Compare the game systems described in `docs/GDD.md` and architecture modules in
`docs/TDD.md` against existing `docs/modules/<n>-<name>/` folders.

For each module, determine:

- Module number and slug
- Dependency order
- Priority (`P1`, `P2`, `P3`)
- Status from existing `tasks.md` if present
- Whether a plan link exists

### Step 2 — Gap Analysis

Report:

- Systems described in GDD/TDD but missing module plans
- Module folders that no longer map clearly to GDD/TDD systems
- Dependency conflicts or cycles
- Suggested next module to plan

### Step 3 — Write `docs/ROADMAP.md`

Create or update this shape:

```markdown
# ROADMAP

> Last updated: YYYY-MM-DD
> Source: GDD + TDD gap analysis

## Module Table

| # | Module | Depends On | Priority | Status | Plan |
|---|--------|------------|----------|--------|------|
| 01 | core-loop | - | P1 | Pending | [plan](modules/01-core-loop/tasks.md) |

Status: Pending / In Progress / Complete / Blocked

## Next Step

`/plan-module 01`
```

Use ASCII status labels in the file. Do not use emoji status markers in
machine-readable tables.

### Step 4 — Report

Show:

- Total modules found from GDD/TDD
- Existing planned modules
- Missing module plans
- Recommended next command

Do not run `/plan-module` automatically.

$ARGUMENTS

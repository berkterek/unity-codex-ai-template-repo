# Game Plan — Game Completion Planner

Reads GDD + TDD + PROGRESS + codebase, then produces `docs/0_MasterPlan.md` and numbered module plan files ready for `/orchestrate`.

## Usage

```
/game-plan
/game-plan docs/GDD.md    ← if GDD is at a non-default path
```

## Pipeline

```
[1] READER    → GDD + TDD + PROGRESS + .cs codebase scan
[2] ANALYZER  → gap analysis: done vs stub vs missing
[3] PLANNER   → 0_MasterPlan.md + numbered module plans (parallel, one agent per module)
[4] REVIEWER  → validates all plans
[5] SAVE      → writes all files to docs/
```

## Step 1 — Reader

Spawn an **Explore** subagent to read:
1. `docs/GDD.md` — full game design document
2. `docs/TDD.md` — technical design document
3. `docs/PROGRESS.md` — completed phases log
4. `git log --oneline -20`
5. All `.cs` files under `Assets/_GameFolders/Scripts/Games/Concretes/`

The explorer must assess each `.cs` file as IMPLEMENTED, STUB, or PARTIAL based on actual method body content (not just class existence).

Required output sections:
- **GDD: Core Gameplay Loop** — the ONE minimal sequence for a playable session
- **GDD: All Systems** — every distinct system grouped by type
- **DONE** — phases from PROGRESS.md with confirmed implemented files
- **STUB/PARTIAL** — code exists but incomplete
- **MISSING** — no code at all
- **Module Breakdown Proposal** — grouped with ordering rules:
  1. Module 1 MUST deliver a playable core loop
  2. Each module must have all dependencies in earlier modules
  3. Features that depend on core loop come after Module 1

## Step 2 — Analyzer

Extract from Reader output:
- **Module list** with names, descriptions, and key files
- **Done summary**
- **Gap summary**

Verify:
1. Module 1 delivers a fully playable session
2. Dependency order is correct
3. No feature module before core loop module

## Step 3 — Master Planner

Spawn a **Plan** subagent (model: opus) to create `docs/0_MasterPlan.md`:

```markdown
# 0 — Master Plan: [Game Title]

> **Status:** In Progress
> **Last Updated:** [today's date]

## Game Overview
[2-3 sentences: genre, core fantasy, one-line game loop]

## Module Completion Status

| # | Module | Plan File | Status | Priority | Notes |
|---|--------|-----------|--------|----------|-------|
| 1 | [Name] | [1_Name.md](1_Name.md) | ⏳ Pending | High | |

**Status legend:** ⏳ Pending · 🔄 In Progress · ✅ Done · 🚫 Blocked

## Architecture Stack
[DI framework, event system, async, key packages, input]

## Dependency Order
[Numbered list: which modules must be done before others]

## Out of Scope (MVP)
[Items from GDD "Nice to Have" sections]
```

## Step 4 — Module Planners (Parallel)

For each module, spawn a **Plan** subagent (model: opus) simultaneously. Each module plan must include:

- Context (what it delivers, current state)
- Goals checklist
- Status table with parallel_group annotations
- File Map
- Per-task: file paths, numbered steps, test type, code skeleton, acceptance criteria

**Test Type Decision Matrix:**

| Class type | Test Type |
|------------|-----------|
| Pure C# service (no UnityEngine) | EditMode |
| MonoBehaviour (no lifecycle needed) | EditMode |
| MonoBehaviour (needs Awake/Update) | PlayMode-Programmatic |
| Requires VContainer scope / scene wiring | PlayMode-Scene |
| LifetimeScope, ScriptableObject, thin adapter | NoTest |

**Parallel Group Rules:**
- Tasks with no compile-time dependency AND different output files → same parallel_group
- If Task B references a type introduced by Task A → Task B gets "—"

## Step 5 — Reviewer

Spawn reviewer (prefer `codex:codex-rescue`, fallback to `unity-reviewer`):

Check:
1. All modules covered?
2. Every task has file path, steps, code skeleton, test type, acceptance criteria?
3. Architecture rules respected (VContainer DI, IEventBus, UniTask, sealed)?
4. Module ordering correct?

If CHANGES NEEDED → fix flagged sections. Max 2 passes.

## Step 6 — Save

Write all files to `docs/`. Print:

```
## ✓ Game Plan Created

docs/0_MasterPlan.md  ← master tracking file

Module Plans:
  docs/1_[Name].md   — [description]
  docs/2_[Name].md   — [description]

Total: [N] module plans

To start implementing:
  /orchestrate docs/1_[FirstModule].md
```

$ARGUMENTS

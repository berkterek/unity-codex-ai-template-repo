# Create Plan — Research → Plan → Review → Save Pipeline

Creates a new plan file in `docs/` from scratch. Analyzes the codebase,
identifies gaps, and produces a structured plan document ready for orchestration.

## Usage

```
/create-plan <plan file name> <what to plan>
/create-plan PLAN_audio_spatial.md add spatial audio and mixer group support to AudioService
```

If no argument is given, ask: "What is the plan file name and what should be
planned?"

## Pipeline

```
[1] RESEARCH → [2] PLAN → [3] REVIEW → [4] SAVE → [5] IMPLEMENT (optional)
```

---

## Inputs To Read

Before starting, read:

- `.codex/project/PROJECT.md`
- `.codex/project/STRUCTURE.md`
- `.codex/project/RULES.md`
- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`
- `docs/GDD.md` (if exists)
- `docs/TDD.md` (if exists)

---

## Step 1 — Research

Analyze the codebase to gather everything needed to write a precise plan:

1. Which files are directly related to the feature or bug described.
2. Current implementation state (what exists, what is partial, what is missing).
3. Method signatures, field names, and class names the plan will reference.
4. Architecture constraints (DI wiring, event flow, editor vs runtime boundary).
5. Related existing plans in `docs/` that might overlap.
6. Run `git log --oneline -15` to understand recent changes.

Output format:

```
### Current State
- What already exists related to this topic (files, classes, methods)
- What is partial or broken

### Missing / Broken
- Concrete gaps that the plan must address
- Which file each gap belongs to

### Technical Notes
- Exact method signatures, field names
- Architecture constraints (editor-only? runtime? event bus?)
- Any gotchas or ordering dependencies
```

---

## Step 2 — Write Plan

Write the plan file using this exact structure:

```markdown
# PLAN — <Short Title>

> **Version:** v1 — <date>
> **Status:** Active
> **Scope:** <which systems are affected>

## Context

<2-3 paragraphs: what is the problem, why it matters, current state>

## Goals

- [ ] Goal 1
- [ ] Goal 2

## Status

| Phase | Task | Status |
|-------|------|--------|
| 1 | Task 1 | Pending |
| 2 | Task 2 | Pending |

## File Map

| File | Change Type | Notes |
|------|-------------|-------|
| path/to/File.cs | Add / Modify | what changes |

---

## Task 1 — <Title>

**Files:**
- `path/to/File.cs`

**Steps:**
1. [ ] Step description
2. [ ] Step description

**Code Skeleton:**
\`\`\`csharp
// method signature + key logic sketch (not full implementation)
\`\`\`

**Acceptance Criteria:**
- Criterion 1
- Criterion 2
```

Rules:
- Use the researcher findings to write precise tasks (real file paths, real
  method names).
- Each task must have: files, numbered steps with `[ ]` checkboxes, code
  skeleton, acceptance criteria.
- If a task touches runtime code, mark it: **[RUNTIME]**.
- If a task is risky or uncertain, mark it: **[BLOCKED — needs investigation]**.

---

## Step 3 — Review

Review the plan against these criteria:

1. Scope — does each task clearly state whether it is editor-only or runtime?
2. File paths — are all referenced files real paths confirmed in the codebase?
3. Task completeness — do all tasks have files, steps, and acceptance criteria?
4. Architecture alignment — VContainer DI, IEventBus, SerializedObject patterns?
5. Overlap — does this duplicate an existing plan in `docs/`?
6. Format — follows the required structure?
7. BLOCKED tasks — are risky tasks clearly marked?

If issues found → revise the plan and re-review (max 3 passes). After 3 failed
passes → ask `skip` (save as-is) or `stop`.

---

## Step 4 — Save

Write the plan content to `docs/<plan file name>`.

Print: `Plan created: docs/[plan file]`

---

## Step 5 — Implement (Optional)

Ask: "Plan saved. Implement now? (yes / no)"

If **no** → stop.

If **yes**:

1. Read the plan file.
2. Identify all tasks NOT marked BLOCKED and NOT already checked off.
3. Implement them in order, task by task, following all project rules.
4. After each task: mark its checkboxes as `[x]` in the plan file.
5. Run compile check after all tasks.

After implementation → review the result and commit:
- Commit message: `feat: <short description in English>`

---

## Completion

Print:

```
## Plan Created
File: docs/[plan file]
Topic: [one-line summary]
Review: PASS
Commit: [hash] — [message]   (only if implemented)
```

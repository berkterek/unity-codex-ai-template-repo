# Update Plan — Analyze → Revise → Review → Save Pipeline

Updates or extends an existing `docs/` plan file based on new findings or
feature gaps. Never rewrites existing content — only appends.

## Usage

```
/update-plan <plan file> <what needs to change>
/update-plan docs/PLAN_audio_system.md add spatial audio and mixer group support
```

If no argument is given, ask: "Which plan file and what needs to be added or
changed?"

## Pipeline

```
[1] ANALYZE → [2] REVISE → [3] REVIEW → [4] SAVE → [5] IMPLEMENT (optional)
```

---

## Inputs To Read

Before starting, read:

- The plan file specified by the user.
- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- Run `git log --oneline -10` to understand recent changes.

---

## Step 1 — Analyze

Analyze the existing plan and relevant source files:

1. What is already implemented (match plan tasks to actual code).
2. What is missing or broken (gaps between plan and code).
3. Concrete technical findings the revision needs (method signatures, field
   names, patterns).

Output format:

```
### Already Implemented
- List tasks/steps from the plan confirmed in code

### Gaps Found
- Gap: [description] — File: [path] — Why it matters: [reason]

### Technical Notes
- Findings the revision needs (method signatures, constraints, gotchas)
```

If no gaps found → inform the user: "Plan is already up to date. No changes
needed." and stop.

---

## Step 2 — Revise Plan

Update the plan file:

1. Add a revision note at the top: `> **v{N+1} — <date>:** [summary of changes]`
2. Update the status table if any phases changed.
3. Add new Task sections at the bottom (`Task N+1`, `Task N+2`, etc.) with:
   - Exact file paths.
   - Numbered steps with `[ ]` checkboxes.
   - Code snippets showing method signatures and key logic.
   - Clear acceptance criteria.
4. Keep existing tasks and content untouched — only append.

Output the FULL updated plan file content. Do NOT truncate existing content.

---

## Step 3 — Review

Review the updated plan:

1. Do new tasks stay within the intended boundaries?
2. Are all referenced file paths real paths in the project?
3. Do steps have clear acceptance criteria?
4. Do new tasks overlap with already-implemented work?
5. Is the revision note present and correctly formatted?

If issues found → revise and re-review (max 3 passes). After 3 failed passes →
ask `skip` (save as-is) or `stop`.

---

## Step 4 — Save

Write the updated content to the plan file.

Print: `Plan updated: [plan file path]`

---

## Step 5 — Implement (Optional)

Ask: "Plan saved. Implement now? (yes / no)"

If **no** → stop.

If **yes**:

1. Read the plan file.
2. Identify all tasks NOT marked BLOCKED and NOT already checked off.
3. Implement them in order, following all project rules.
4. After each task: mark checkboxes as `[x]` in the plan file.
5. Run compile check after all tasks.

After implementation → review the result and commit:
- Commit message: `feat: <short description in English>`

---

## Completion

Print:

```
## Plan Updated
File: [plan file path]
Changes: [one-line summary]
Review: PASS
Commit: [hash] — [message]   (only if implemented)
```

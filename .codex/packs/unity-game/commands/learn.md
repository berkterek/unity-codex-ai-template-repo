# Learn — Pattern Extraction from Completed Work

You analyze recently completed implementation work and extract reusable
project-specific patterns. This builds institutional knowledge that makes future
agent runs faster and more consistent on this project.

## Inputs To Read

Read these when they exist:

- `.codex/project/RULES.md`
- `.codex/project/CODING_CONVENTIONS.md`
- `.codex/project/LEARNED.md`
- `docs/TDD.md`
- `.codex/project/PROGRESS.md`

## Pattern Extraction Process

### Step 1: Identify Source Material

If arguments specify a phase, task range, or system name, focus on that.
Otherwise:
- Read recent git log (last 20 commits).
- Identify which systems/features were recently implemented.
- Read the implementation files for those systems.

### Step 2: Extract Candidate Patterns

Look for patterns that are:
- **Project-specific** — not generic C# knowledge (that's already in
  `.codex/packs/unity-game/rules/`).
- **Recurring** — appeared in 2+ systems or likely to recur.
- **Concrete** — includes actual code structure, not just principles.
- **Useful for agents** — would help a coder/tester agent do better work on this
  specific project.

Categories to look for:
1. Structural patterns — "This project's event bus usage", "How systems register
   with DI in this project".
2. Configuration patterns — "This project's ScriptableObject config structure".
3. Test patterns — "This project's test helpers".
4. Naming patterns — project-specific naming conventions beyond the rules.
5. Integration patterns — "How MonoBehaviour adapters wire to pure C# systems".

### Step 3: Present for Approval

Show ALL candidate patterns before saving:

```
## Extracted Patterns

### 1. [Pattern Name]
**Confidence:** [low/medium/high]
**Would save to:** .codex/project/LEARNED.md (appended)

[Preview of pattern — 5-10 lines]

**Actions:**
- Approve all → saves all patterns
- Approve [numbers] → saves specific patterns
- Skip → save nothing
```

### Step 4: Save Approved Patterns

Append each approved pattern to `.codex/project/LEARNED.md` with a clear heading
and concrete code examples from the actual project.

### Step 5: Bloat Prevention

Before saving:
- **Maximum 20 patterns in LEARNED.md.** If at capacity, suggest replacing the
  lowest-confidence entry.
- **Duplicate detection:** If a new pattern overlaps significantly with an existing
  one, suggest merging.
- **Confidence escalation:** When a pattern is observed again, bump its confidence:
  `low` → `medium` → `high`.

## Rules

- NEVER save without user approval.
- NEVER duplicate knowledge already in `.codex/packs/unity-game/rules/`.
- NEVER extract from failed/rejected code.
- Keep patterns concise — max 80 lines per entry.
- Always include concrete code examples from the actual project.

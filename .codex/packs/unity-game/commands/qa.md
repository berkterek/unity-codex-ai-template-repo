# /qa — Quality Assurance Pipeline

> Apply `.codex/packs/unity-game/guides/guardrails.md` rules throughout.


Runs a four-stage quality check on the current codebase state: executable guardrails → compile + test green → silent failure audit → phase validation. Use after any implementation work to confirm the project is clean before proceeding.

## Usage

```
/qa
/qa docs/modules/01-core-loop/tasks.md
/qa --phase 2
/qa --files Assets/_GameFolders/Scripts/Games/Concretes/Audio/
```

| Argument | Effect |
|----------|--------|
| *(none)* | Audit all recently changed files, validate most recently completed phase |
| `--phase N` | Validate a specific phase/checkpoint from the active module `tasks.md` |
| `--files <path>` | Scope silent failure hunt to specific files or folder |

---

## Plugin Preflight

Check which of these plugins are available in the skill list:

| Plugin | Used in | Fallback |
|--------|---------|---------|
| `superpowers:verification-before-completion` | Final Report — evidence gate before declaring CLEAN | Skip verification gate |

Print availability status before proceeding:
```
Plugins: superpowers:verification-before-completion [✓/✗]
```

---

## Pipeline

```
[Stage 0] Guardrails → [Stage 1] Ralph → [Stage 2] Silent Failure Hunt → [Stage 3] Validate → [Report]
```

---

## Stage 0 — Executable Guardrails

Run:

```bash
bash .codex/guardrails/run.sh --changed
```

- `PASS` → no `BLOCK` findings; proceed to Stage 1.
- `FAIL` → stop and print all `BLOCK` findings. Do not proceed until fixed.
- `WARN` findings → include in the QA report and proceed.

Print: `✓ Stage 0 — Guardrails: no blocks.` or `✗ Stage 0 — Guardrails: [N] blocks.`

---

## Stage 1 — Ralph (Compile + Tests)

Spawn a **unity-verifier** subagent to compile and run all tests.

If failures found → spawn **unity-fixer** subagent to fix each issue, then re-verify. Repeat up to **3 passes**.

- `PASS` → proceed to Stage 2.
- `FAIL after 3 passes` → stop. Print all remaining failures. Ask: `Fix these issues manually and re-run /qa, or type "skip" to continue anyway.`
  - `skip` → proceed with warning
  - *(anything else)* → abort

Print: `✓ Stage 1 — Ralph: compile and tests green.` or `⚠ Stage 1 — Ralph: [N] issues remain.`

---

## Stage 2 — Silent Failure Hunt

Determine scope:
- If `--files <path>` given → audit those files only
- Otherwise → audit all files modified in the most recent git commits since the last phase commit (use `git diff --name-only HEAD~5` as a heuristic, filter to `.cs` files)

Spawn a **unity-linter** subagent with this prompt:

```
Audit the following C# files for silent failure patterns:

FILES: $TARGET_FILES

Check for:
1. catch blocks that swallow exceptions without logging or rethrowing
2. async void outside Unity lifecycle methods (Awake, Start, OnEnable, OnDisable, OnDestroy)
3. IEventBus subscriptions (Subscribe<T>) without a matching Unsubscribe<T> in Dispose/OnDisable
4. UniTask.Forget() calls without an onException error handler
5. Empty catch blocks: catch { } or catch (Exception) { }

For each finding:
- [file:line] — [pattern type] — [description] — [suggested fix]

If nothing found: CLEAN
```

Print all findings or `✓ Stage 2 — Silent failures: CLEAN.`

---

## Stage 3 — Validate

Determine what to validate:
- If a `tasks.md` path is given → validate that module plan
- If `--phase N` given → validate phase/checkpoint N in the active module
- Otherwise → validate the most recently completed checkpoint from `docs/PROGRESS.md`

If no module `tasks.md`, legacy `WORKFLOW.md`, or `PROGRESS.md` exists → skip this stage and note: `Stage 3 skipped — no plan found.`

Spawn a native Codex subagent suitable for read-only verification, or perform
the verification locally if subagents are unavailable, with this prompt:

```
You are a strict QA gate. Validate module phase/checkpoint [N] — [Name].

Read:
- docs/modules/<module>/tasks.md — task definitions and acceptance criteria for this module
- docs/PROGRESS.md — reported completion status

Checks:
1. All output files listed in tasks.md for this phase/checkpoint exist at the specified paths
2. Files are not empty or placeholder stubs
3. Every acceptance criterion is met — read the actual code to verify, do not assume

Output format:
PASS — all [N] criteria met.

FAIL:
- [P{phase}.T{task}] [criterion text] — [what is missing or wrong]
(list every failure)
```

Print result: `✓ Stage 3 — Validate: PASS` or `⚠ Stage 3 — Validate: FAIL — [N] criteria unmet.`

---

## Final Report

```
## QA Report
─────────────────────────────────────
Stage 1 — Ralph:          ✓ green  |  ⚠ [N issues]
Stage 2 — Silent failures: ✓ CLEAN  |  ⚠ [N findings]
Stage 3 — Validate:        ✓ PASS   |  ⚠ FAIL ([N criteria])
─────────────────────────────────────
Overall: CLEAN ✓  |  ISSUES FOUND ⚠
```

**If `superpowers:verification-before-completion` is available AND overall status is CLEAN:** Invoke it before reporting done. Confirm all three stages passed with evidence.

If **CLEAN** → print: `Project is clean. Safe to proceed.`

If **ISSUES FOUND** → list all issues grouped by stage. Ask:
```
Issues found. Options:
  fix   — spawn unity-fixer/unity-coder to address findings automatically
  list  — show full issue details
  skip  — accept current state and proceed
```

- `fix` → spawn **unity-coder** subagent with all findings as a fix list, then re-run `/qa`
- `list` → print full details for each finding
- `skip` → exit with warning logged to `docs/PROGRESS.md`

$ARGUMENTS

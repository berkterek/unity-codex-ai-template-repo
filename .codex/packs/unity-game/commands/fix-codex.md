# Fix Codex — Codex-Driven Fix Pipeline

Pipeline: Codex Analysis → Human Gate → Codex Implementation → Codex Review → Committer

## Usage

```
/fix-codex <bug description>
/fix-codex --files GameManager.cs,LevelController.cs "items not dropping"
```

If no argument is given, ask: "Describe the bug. Include any error messages, stack traces, and reproduction steps."

## When to use

| Command | Use when |
|---------|----------|
| `/fix` | Stack trace clearly points to root cause, files are small (<500 lines) |
| `/fix-deep` | Logic bug, intermittent issue, root cause unclear |
| `/fix-codex` | Legacy/large codebase (2000+ line files), stuck after `/fix` or `/fix-deep`, or 30+ minutes in a loop |

> **Why fix-codex is different:** The analysis pass is intentionally isolated
> from implementation so the fix follows evidence instead of an early
> hypothesis.

## Step 1 — Codex Analysis Pass

The implementation pass must do **zero pre-analysis** before the dedicated
analysis pass completes — no file reads, no hypothesis formation.

Run the analysis locally or spawn a fresh native Codex subagent with this prompt:

```
TASK: Analysis only — do NOT fix yet.

BUG: <user's full description>
REPRODUCTION: <how it is triggered>
FILES (if specified): <list from --files argument, or "discover yourself">

Read the codebase directly. Trace the execution path from the symptom backward to the root cause.
Do NOT form a hypothesis first — read the code literally and follow the data/call flow.

Report:
1. ROOT CAUSE: exact file + line number + what is wrong
2. WHY: why this causes the reported symptom
3. AFFECTED SCOPE: what else might be affected
4. FIX APPROACH: what should change (do not implement yet)
```

## Step 2 — Human Gate

```
CODEX ANALYSIS
==============
Root Cause: <file:line — what is wrong>
Why it causes the symptom: <execution trace>
Affected scope: <what else may be impacted>
Proposed fix: <what should change>

Proceed? (go / redirect)
```

## Step 3 — Codex Implementation

Run the implementation locally or spawn a fresh native Codex subagent:

```
TASK: Implement the fix based on your previous analysis.

ROOT CAUSE CONFIRMED: <root cause from Step 1>
FIX APPROACH CONFIRMED: <fix approach from Step 1>

PROJECT RULES (non-negotiable):
- VContainer DI — no singletons, no FindObjectOfType
- UniTask — no coroutines, no async Task
- New Input System — no Input.GetKey / Input.GetAxis
- IEventBus for cross-module events, C# event for intra-module, UnityEvent forbidden
- [SerializeField] for component references — not GetComponent in Awake
- Sealed classes by default
- No LINQ in gameplay code
- Unity null check: == null, not is null or ?.
```

## Step 4 — Codex Review

Review the changed files:
1. **CORRECT LOCATION?** Fix at root cause, not symptom
2. **COMPLETE?** Edge cases covered?
3. **ARCHITECTURE:** Any rule violations?
4. **VERDICT:** APPROVED / NEEDS REVISION

If NEEDS REVISION: loop back to Step 3 with revision notes. Max 2 revision loops.

## Step 5 — Committer

Commit message format:
```
fix(<scope>): <short description of root cause resolved>

Root cause: <one sentence>
```

## Output Format

```
ROOT CAUSE: <file:line — what was wrong>
FIX: <what changed and why>
CODEX REVIEW: APPROVED
COMMIT: <hash> — <message>
```

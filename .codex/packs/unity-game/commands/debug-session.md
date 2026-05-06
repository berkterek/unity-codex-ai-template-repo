# Debug Session — Structured Bug Investigation

Starts a structured debugging session following the debugger agent protocol.

## Usage

```
/debug-session
/debug-session NullReferenceException in EnemySpawner when wave starts
```

---

## Inputs To Read

Before starting, read:

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/agents/debugger.md`
- `.codex/packs/unity-game/rules/architecture.md`

---

## Initialization

Ask the developer:

1. **Symptom** — Exact error message or unexpected behavior?
2. **Reproduction** — When does it happen? Always or intermittent?
3. **Recent changes** — What changed before this appeared?
4. **Stack trace** — Paste it if available.

Do not proceed until you have at least the symptom and reproduction condition.

---

## Process

### Step 1 — Understand the Symptom

Read the stack trace or behavior description. Identify:
- Which file and line is the immediate failure point?
- Which system/module is involved? (VContainer, ECS, UniTask, Input, etc.)

### Step 2 — Reproduce Mentally

Trace the code path that leads to the symptom. Read the relevant files:
- Service registration in installer.
- Constructor/inject chain.
- Where the failing method is called from.

### Step 3 — State Root Cause

Before touching any code, write:

```
ROOT CAUSE: [one sentence]
EVIDENCE: [specific lines or patterns that confirm it]
```

### Step 4 — Fix

Apply the minimal change. Verify:
- No new singletons introduced.
- No coroutines introduced.
- No direct Unity API in service classes.
- VContainer registrations are correct.

### Step 5 — Verify Plan

Describe to the developer exactly how to confirm the fix works.

---

## Common Patterns to Check First

| Symptom | Likely Cause |
|---------|-------------|
| `VContainerException: Unable to find type` | Missing `.As<IInterface>()` or wrong scope |
| `NullReferenceException` on Unity object | Object destroyed, or Inject called after Awake |
| `OperationCanceledException` in UniTask | CancellationToken fired — often not a bug |
| ECS system not executing | Wrong `[UpdateInGroup]`, archetype mismatch |
| Input not working | `OnEnable()` missing `.Enable()` call |
| `InvalidOperationException` in ECS job | Structural change without ECB |

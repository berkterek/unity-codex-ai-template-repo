# Scene Setup — C# Scripts + Unity Editor Wiring Pipeline

Sets up a new scene or prefab: coder writes the C# scripts, unity-setup wires everything in the Unity Editor via MCP, reviewer checks, committer commits.

**Scene hierarchy standard:** All scenes follow six standard containers (`[Setup]`, `[Services]`, `[UI]`, `[Environment]`, `[Characters]`, `[VFX]`) created first, every GO placed in the correct container, every GO is a prefab instance.

## Usage

```
/scene-setup <description>
/scene-setup set up the GameScene with BayManager, FlowEngine, and 5 bay prefabs
```

If no argument is given, ask: "What needs to be set up in the scene?"

---

## Step 0 — MCP Preflight

Check MCP connection state:

- **State 1** (connected) → continue to complexity scoring
- **State 2** (disconnected) → stop; offer to run code-only (skip Step 1b, list manual wiring steps instead)
- **State 3** (not installed) → skip Step 1b entirely; after coder completes, print manual wiring checklist

---

## Step 0b — Review Mode & Complexity Scoring

Read `production/review-mode.txt` (default: `lean` if file missing):

| Mode | Effect |
|------|--------|
| `solo` | No reviewer or unity-developer — unity-coder/unity-coder-lite → unity-setup → committer only. |
| `lean` | Standard pipeline. |
| `full` | Standard pipeline + unity-developer second reviewer always active. |

Print the active mode before proceeding.

Score the task complexity on a 0.0–1.0 scale:

| Score | Label | Signals | Coder Agent |
|-------|-------|---------|-------------|
| 0.0–0.3 | **Simple** | Single MonoBehaviour, no new interfaces, no DI wiring | **unity-coder-lite** |
| 0.4–0.6 | **Medium** | 2–4 scripts, new interface, or LifetimeScope installer | **unity-coder** |
| 0.7–1.0 | **Complex** | New module, cross-system events, ECS, or Addressables | **unity-coder** + unity-developer review |

Scene setup always targets Unity/Mixed code — `coder` agent is never used here.

**Scoring signals:**
- Creates a new module folder? +0.3
- Adds or modifies IEventBus events? +0.2
- Touches ECS systems or Addressables? +0.3
- Modifies AppScope, AppModules, ConfigCatalog, InputService, or a static Module? +0.2
- Single MonoBehaviour with no dependencies? −0.3

**Print before proceeding:**
```
Complexity: [score] — [Label]
Rationale: [one sentence]
Coder Agent: [unity-coder-lite | unity-coder]
Review Mode: [solo | lean | full]
```

**For Complex tasks (score ≥ 0.7):** fire **ARCHITECTURE_GATE** from `.codex/packs/unity-game/guides/director-gates.md`. Show the proposed module/prefab structure and wait for `go`.

### SCOPE_GATE

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: scene setup description, complexity score, expected scripts and Unity assets.
Wait for `go` before spawning any agents.

After receiving `go`:
```bash
mkdir -p .codex/state && echo '{"gate":"SCOPE_GATE","pipeline":"scene-setup","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}' > .codex/state/gate-cleared
```

For **Complex** tasks (score ≥ 0.7) in `lean` or `full` mode: after reviewer APPROVED, spawn a **unity-developer** subagent review pass before the committer.

---

## Pipeline

```
[1a] CODER (C# scripts)
[1b] UNITY-SETUP (scene/prefab wiring via MCP)  ← runs after coder
[2]  REVIEWER ⟲ (loop until APPROVED, max 3 passes)
[2.5] UNITY-VERIFIER (bounded compile + scene/prefab integrity check)
[3]  COMMITTER
```

---

## Inputs To Read

Before starting, read:

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/guides/unity-mcp.md`
- `.codex/packs/unity-game/guides/guardrails.md`

---

## Step 1a — Coder

Spawn the coder agent determined in Step 0b (**unity-coder-lite** for Simple, **unity-coder** for Medium/Complex) with this prompt:

```
You are a senior C# Unity developer. Write the C# scripts needed for the following Unity scene setup.

## Scene Setup Task
$SETUP_DESCRIPTION

## Project Rules
- Read .codex/project/RULES.md before writing any code
- Follow all rules in .codex/packs/unity-game/rules/
- No singletons — VContainer only (register in scene LifetimeScope installer)
- No coroutines — UniTask only
- MonoBehaviour components must use [Inject] public void Construct(...)
- sealed classes by default

## Scope
Write ONLY C# script files (.cs). Do NOT modify scenes or prefabs — that is handled separately.

## When Done
List every .cs file you created with a one-line summary.
Report: DONE or BLOCKED with reason.
```

If BLOCKED → stop and show the user.

---

## Step 1b — Unity Setup

Spawn a **unity-setup** subagent with this prompt:

```
You are a Unity scene architect. Wire up the scene and prefabs for the following task.

## Scene Setup Task
$SETUP_DESCRIPTION

## C# Scripts Already Created
$CODER_OUTPUT

## Your Responsibilities
- Use Unity MCP tools to create/modify GameObjects, add components, set references
- Create prefabs as needed
- Attach the new C# MonoBehaviour components to appropriate GameObjects
- Set up the scene LifetimeScope installer with the new VContainer registrations
- Do NOT edit .unity or .prefab files as raw text — use MCP tools only

## When Done
List every scene/prefab/asset you created or modified.
Report: DONE or BLOCKED with reason.
```

If BLOCKED → stop and show the user.

---

## Step 2 — Reviewer (skip in `solo` mode)

Reviewer priority — try in order:
1. Spawn native Codex subagent `unity-reviewer` when subagents are available and authorized.
2. If subagents are unavailable or not authorized, review locally using the same criteria and report the gap.

```
Review this Unity scene setup implementation.

## Task
$SETUP_DESCRIPTION

## C# Files Created
$CODER_OUTPUT

## Unity Assets Modified
$UNITY_SETUP_OUTPUT

## Review Criteria (C# only — Unity assets cannot be reviewed as text)
1. Architecture — VContainer DI, [Inject] Construct pattern on MonoBehaviours
2. Naming — PascalCase types, _camelCase private fields
3. No Unity API in service/domain classes
4. UniTask — no async void, CancellationToken on every async method
5. Unity null safety — no ?. or is null on UnityEngine objects

APPROVED or CHANGES NEEDED with file:line issues.
```

### Review Loop (max 3 passes)

On CHANGES NEEDED → spawn a coder subagent to fix every listed issue:

```
You are a senior C# Unity developer. Fix the following review issues.

## Original Scene Setup Task
$SETUP_DESCRIPTION

## Review Feedback (fix ALL of these)
$REVIEWER_FEEDBACK

## Rules
- Fix only what the reviewer flagged — do not refactor anything else
- Only modify .cs files — do not touch scene or prefab files
- Read .codex/project/RULES.md before making changes

## When Done
List every file you changed with a one-line summary.
Report: DONE or BLOCKED with reason.
```

After coder fixes → re-run reviewer (same priority order). After 3 failed passes → ask: `skip` or `stop`.

**In `full` mode or Complex score:** after standard reviewer passes, spawn **unity-developer** for a second review pass.

---

## Step 2.5 — Unity Verifier (bounded check)

Spawn a **unity-verifier** subagent (max 3 internal iterations):

```
You are a Unity verification agent. Run a final bounded check on this scene/prefab setup.

## Scene Setup Task
$SETUP_DESCRIPTION

## Files Changed
$CODER_OUTPUT
$UNITY_SETUP_OUTPUT

## Your Task (max 3 internal iterations)
1. mcp__unityMCP__refresh_unity + wait for compile
2. mcp__unityMCP__read_console type "Error" — check compile errors
3. Verify scene/prefab integrity: prefab instances in scene (no bare GameObjects), root=logic/Body=visual separation, domain folder placement under _GameFolders/Prefabs/<Domain>/
4. Quick scan for Unity-specific issues in C# files (null refs, missing SerializeField, event leaks)
5. If issues found and fixable — fix and re-check
6. If clean → report VERIFIED
7. After 3 iterations still failing → report VERIFY FAILED

VERIFIED — compile clean, prefab structure valid.
VERIFY FAILED: [issue description]
```

If VERIFY FAILED → ask: `skip` or `stop`.

### COMMIT_GATE

Show the COMMIT_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: setup description, all changed .cs and Unity asset files, reviewer verdict, verifier verdict.
Wait for `go` before committing. `stop` → leave files staged, print summary without committing.

---

## Step 3 — Committer

Read `.codex/packs/unity-game/agents/committer.md` for full conventions, then:

- `git status`, `git diff`
- Stage all related `.cs`, `.unity`, `.prefab`, `.asset`, `.meta` files
- Commit message format: `feat: <short description in English>`
- Do NOT push

---

## Completion

Run: `rm -f .codex/state/gate-cleared`

Print:
```
## Scene Setup Complete
Task: [description]
Scripts: [count] .cs files
Unity assets: [count] files
Commit: [hash] — [message]
Reviewer: [local | unity-reviewer] — APPROVED
Verifier: VERIFIED
```

$ARGUMENTS

# Scene Setup — C# Scripts + Unity Editor Wiring Pipeline

Sets up a new scene or prefab: writes the C# scripts, wires everything in the
Unity Editor via MCP, reviews, commits.

## Usage

```
/scene-setup <description>
/scene-setup set up the GameScene with BayManager, FlowEngine, and 5 bay prefabs
```

If no argument is given, ask: "What needs to be set up in the scene?"

## Complexity Scoring

Score the task on a 0.0–1.0 scale:

| Score | Label | Coder Agent |
|-------|-------|-------------|
| 0.0–0.3 | Simple | `unity-coder-lite` |
| 0.4–0.6 | Medium | `unity-coder` |
| 0.7–1.0 | Complex | `unity-coder` + `unity-developer` second review |

Signals: new module folder +0.3, IEventBus events +0.2, ECS/Addressables +0.3, AppScope/Installer +0.2, single MonoBehaviour −0.3.

Print: `Complexity: [score] — [Label]`

**For Complex tasks:** fire ARCHITECTURE_GATE from `.codex/packs/unity-game/guides/director-gates.md`. Show proposed module/prefab structure and wait for `go`.

### Director Gate — SCOPE_GATE

Show the SCOPE_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: scene setup description, complexity score, expected scripts and Unity assets.
Wait for `go` before spawning any agents.

---

## Pipeline

```
[1a] C# SCRIPTS
[1b] UNITY EDITOR WIRING  ← runs after step 1a
[2]  REVIEW
[2.5] UNITY VERIFIER (bounded check)
[3]  COMMIT
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
- `.codex/packs/unity-game/agents/unity-setup.md`

---

## Step 1a — C# Scripts

Act as the coder agent (`.codex/packs/unity-game/agents/coder.md`):

1. Write the C# scripts needed for this scene setup.
2. MonoBehaviour components must use `[Inject] public void Construct(...)`.
3. Register new services in the scene LifetimeScope installer.
4. Scope: write ONLY `.cs` files. Do NOT modify scenes or prefabs — that is
   handled in Step 1b.
5. List every `.cs` file created with a one-line summary.

If blocked → stop and show the user.

---

## Step 1b — Unity Editor Wiring

Act as the unity-setup agent
(`.codex/packs/unity-game/agents/unity-setup.md`):

1. Use Unity MCP tools to create/modify GameObjects, add components, set
   references.
2. Create prefabs as needed.
3. Attach the new MonoBehaviour components to appropriate GameObjects.
4. Set up the scene LifetimeScope installer with the new VContainer
   registrations.
5. Do NOT edit `.unity` or `.prefab` files as raw text — use MCP tools only.
6. List every scene/prefab/asset created or modified.

If blocked → stop and show the user.

---

## Step 2 — Review

Review C# files against these criteria (Unity assets cannot be reviewed as
text):

1. Architecture — VContainer DI, `[Inject] Construct` pattern on
   MonoBehaviours.
2. Naming — PascalCase types, `_camelCase` private fields.
3. No Unity API in service/domain classes.
4. UniTask — no `async void`, CancellationToken on every async method.
5. Unity null safety — no `?.` or `is null` on UnityEngine objects.

If issues found → fix C# files and re-review (max 3 passes). After 3 failed
passes → show remaining issues, ask `skip` or `stop`.

---

## Step 2.5 — Unity Verifier (bounded check)

Spawn a `unity-verifier` subagent (max 3 internal iterations):
1. Compile check via `refresh_unity` + `read_console`.
2. Verify prefab structure: root=logic, Body=visual, correct `_GameFolders/Prefabs/<Domain>/` location.
3. Quick scan for Unity-specific issues.

If cannot fix → surface blockers before committing.

### Director Gate — COMMIT_GATE

Show the COMMIT_GATE from `.codex/packs/unity-game/guides/director-gates.md`.
Pass: setup description, changed files, reviewer verdict.
Wait for `go` before committing.

---

## Step 3 — Commit

Act as the committer agent (`.codex/packs/unity-game/agents/committer.md`):

1. `git status && git diff`
2. Stage all related `.cs`, `.unity`, `.prefab`, `.asset`, `.meta` files.
3. Commit message format: `feat: <short description in English>`.
4. Do NOT push.

---

## Completion

Print:

```
## Scene Setup Complete
Task: [description]
Scripts: [count] .cs files
Unity assets: [count] files
Commit: [hash] — [message]
Review: PASS
```

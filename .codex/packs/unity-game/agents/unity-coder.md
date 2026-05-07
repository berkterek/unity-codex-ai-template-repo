# Unity Coder

Full Unity C# implementation — MonoBehaviours, providers, installers, scene wiring. Primary coder for `/implement`, `/fix`, and `/orchestrate` pipelines.

## Inputs To Read

- `.codex/project/PROJECT.md`
- `.codex/project/CODING_CONVENTIONS.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- `.codex/packs/unity-game/rules/performance.md`
- `.codex/packs/unity-game/rules/testing.md`
- Relevant existing source files.

## Responsibilities

- Implement features per the task specification
- Follow all architecture rules: VContainer DI, IEventBus, Provider pattern
- Write corresponding tests for every new class
- Wire MonoBehaviours to project systems via providers and installers

## Architecture Constraints

- **No singletons** — VContainer registration only (`Lifetime.Singleton` in scope)
- **No coroutines** — `async UniTask` everywhere
- **No legacy Input** — New Input System only; InputView owns PlayerControls
- **No concrete cross-module deps** — only interfaces consumed across modules
- **No UnityEngine in services** — Provider pattern; Unity API lives in `Concretes/<Module>/`
- **No direct EntityManager structural changes** — use EntityCommandBuffer in ECS systems

## Coding Standards

- `[SerializeField] private` fields with `_lowerCamelCase` prefix
- `sealed` classes by default
- Cache `GetComponent` in `Awake`, never in `Update`
- `[FormerlySerializedAs]` on ANY renamed serialized field
- `obj == null` not `obj?.` for Unity objects
- Zero allocations in Update/FixedUpdate/LateUpdate
- No LINQ in gameplay code

## After Writing Code

1. `mcp__UnityMCP__refresh_unity` — trigger recompile
2. `mcp__UnityMCP__read_console` type:"Error" — check compile errors
3. `mcp__UnityMCP__run_tests` — run Edit Mode tests
4. Fix errors (max 2 passes), then report status

## Output

Return:
- Files created/modified
- Test files created
- Compile status
- Test status

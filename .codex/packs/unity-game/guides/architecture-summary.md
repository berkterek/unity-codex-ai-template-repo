## Key Architecture Rules

- **No singletons** — VContainer only.
- **No service locator** — each class declares only its own dependencies.
- **No coroutines** — UniTask everywhere. Use `async UniTask`, not `async void`.
- **No legacy Input** — New Input System only. `InputService` is pure C# and `ITickable`; per-prefab routing uses pure C# `InputHandler`.
- **No concrete cross-module dependencies** — consume interfaces across modules.
- **No UnityEngine in services** — Unity API lives in Providers or Mono Shells.
- **No direct EntityManager structural changes** — use `EntityCommandBuffer`.
- **No MonoBehaviour without justification** — MonoBehaviour must need serialized refs, Unity callbacks, Unity API boundary, or Canvas UI.
- **No `new *Service()` or `new *Provider()`** — VContainer constructs these.
- **No `*Handler : MonoBehaviour`** — handlers are pure C#.
- **No `*Module : ScriptableObject`** — modules are static classes.
- **Tests are mandatory where logic exists** — NSubstitute + AAA, mock interfaces only.

## 4-Tier Runtime Architecture

| Tier | Name | Type | Role |
|------|------|------|------|
| 1 | Mono Shell | `MonoBehaviour` Controller/View | Holds serialized refs, forwards Unity lifecycle to handlers/services, zero business logic |
| 2 | Handler | Pure C# | Prefab-local behavior, driven by shell, never referenced across modules |
| 3 | Service / EntryPoint | Pure C# | Cross-module logic, VContainer registration, `ITickable` when frame updates are needed |
| 4 | Provider | `MonoBehaviour` | Unity API boundary for services |

Suffix rules:

- `*View` -> UI/Canvas shell
- `*Controller` -> gameplay shell
- `*Provider` -> Unity API wrapper
- `*Handler` -> pure C# local behavior
- `*Service` -> pure C# module service

## Static Module Pattern

```text
[Domain]Module.Install(builder, config)
    -> AppModules.Install(builder, catalog)
    -> AppScope.Configure()
```

- `ConfigCatalog` aggregates all module config assets.
- `EventBusModule` is first in `AppModules`.
- New module equals one static module class plus one `AppModules` line and one
  `ConfigCatalog` field/property/check.
- `AppScope.cs` should not change for new modules.

## Building A Game From Scratch

| Phase | Commands | What Happens |
|-------|----------|--------------|
| 1 — Idea & Design | `/game-idea`, `/architect` | GDD -> TDD with review |
| 2 — Planning | `/roadmap`, `/plan-module`, `/dry-run` | Roadmap plus per-module `spec/design/tasks` |
| 3 — Project Setup | `/setup-project` | Folders, asmdefs, base classes, config catalog, graph option |
| 4 — Implementation | `/orchestrate <tasks.md>`, `/continue` | Execute module tasks with checkbox resume |
| 5 — Quality | `/validate`, `/review-code`, `/ralph`, `/performance-audit` | Compile, tests, review, hot path audit |
| 6 — Documentation | `/learn`, `/catch-up`, `/adr`, `/smart-commit` | Extract patterns, record decisions, commit |

For incremental feature work on an existing game, use `/implement <description>`.

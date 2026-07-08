# Setup Checklist

After running `/setup-project`, most scene/wiring work is handled automatically via MCP. Only a few steps truly require manual action.

## MCP-Automated (done by /setup-project when MCP is connected)

These are NOT manual — `/setup-project` Step 5d handles them via `manage_scene`, `manage_gameobject`, `manage_components`, and `manage_build`:

- Scene creation: Bootstrap.unity, Menu.unity, Game.unity
- AppScope GameObject + component attachment in Bootstrap scene
- ConfigCatalog ScriptableObject creation and wiring to AppScope
- Build Settings scene order (Bootstrap at index 0)

## Truly Manual (cannot be automated)

- [ ] **NSubstitute DLL** — Download from [NuGet](https://www.nuget.org/packages/NSubstitute): click "Download package", rename `.nupkg` to `.zip`, extract, take `NSubstitute.dll` from the `lib/` folder, place in `Assets/Plugins/NSubstitute/`
- [ ] **New Input System — Project Settings** — After package install: Edit → Project Settings → Player → Active Input Handling → "Input System Package (New)" (Unity restarts; this cannot be set via MCP)
- [ ] **Input Actions file** — Create `Assets/_GameFolders/Input/[ProjectName]Controls.inputactions`, enable "Generate C# Class" in Inspector
- [ ] **Guardrail read check** — Confirm agents read `AGENTS.md`, `guardrails.md`, `PROJECT.md`, and `RULES.md` at session start.
- [ ] **Reviewer gate** — Before commit, run `/review-code` or the `unity-reviewer` flow required by `guardrails.md`.
- [ ] **Test scene check** — If PlayMode scene tests are generated, verify each referenced scene exists under `Assets/_Scenes/TestScenes/`.

# Testing Infrastructure

When `testing: true` in `.codex/project/FEATURES.json`, `/setup-project` generates the following. If testing was enabled after initial setup, re-run `/setup-project` to generate missing pieces.

## What Gets Generated

| Artifact | Path | Notes |
|----------|------|-------|
| Edit Mode test assembly | `Scripts/Tests/[Project]EditModeTest/[Project]EditModeTest.asmdef` | NSubstitute refs included if DLL present |
| Play Mode test assembly | `Scripts/Tests/[Project]PlayModeTest/[Project]PlayModeTest.asmdef` | All platforms, NSubstitute refs included if DLL present |
| Edit Mode sample test | `Scripts/Tests/[Project]EditModeTest/SampleEditModeTests.cs` | AAA pattern, IEventBus mock example |
| Play Mode sample test | `Scripts/Tests/[Project]PlayModeTest/SamplePlayModeTests.cs` | UnityTest + yield return pattern |

## NSubstitute Dependency

NSubstitute cannot be installed via Package Manager — it requires a manual DLL drop:

1. Download from [nuget.org/packages/NSubstitute](https://www.nuget.org/packages/NSubstitute) → "Download package"
2. Rename `.nupkg` → `.zip`, extract, copy `NSubstitute.dll` from `lib/netstandard2.0/`
3. Place at `Assets/Plugins/NSubstitute/NSubstitute.dll`
4. Re-run `/setup-project` — it will regenerate `.asmdef` files with `precompiledReferences` and `overrideReferences: true`

Without NSubstitute.dll, test asmdefs are generated without mock support. `Substitute.For<T>()` will not compile.

## Test Type Decision

Every class goes through `test-type-router` before a test is written. Some classes are always `NoTest` — no test file is generated for them:

| Class type | Decision |
|-----------|----------|
| `LifetimeScope` subclass | NoTest — DI wiring tested via integration |
| `ScriptableObject` | NoTest — data container, no logic |
| `IComponentData` struct | NoTest — data only |
| `Baker<T>` | NoTest — bake-time only |
| Pure C# service | EditMode |
| MonoBehaviour (no lifecycle deps) | EditMode or PlayMode-Programmatic |
| MonoBehaviour (lifecycle matters) | PlayMode-Programmatic or PlayMode-Scene |
| ECS System | PlayMode-ECS (isolated World) |

## PlayMode Scene Tests

PlayMode-Scene tests require a real Unity scene. Each test scene lives in `Assets/_Scenes/TestScenes/` and must:
- Contain exactly one `TestBootstrap` prefab
- Be added to Build Settings
- Have a matching `[Feature]TestScope.cs` + `[Feature]TestInstaller.cs`

Before committing PlayMode scene tests, verify referenced scene paths manually or through MCP scene queries.

---

# Project-Specific Setup

When first adding this template to a new project, run `/setup-project`. It:

1. **Detects existing state** — checks folder structure and `manifest.json`, compares against `.codex/project/FEATURES.json` if it exists, reports conflicts and offers sync-only mode
2. **Asks feature questions** — Addressables (yes/no), Testing (yes/no), ECS (yes/no) — with detected signals as defaults
3. **Writes `.codex/project/FEATURES.json`** — commands read this to skip disabled features
4. **Generates** assembly definitions, base framework classes (`IEventBus`, `EventBus`, `EventBusAccessor`, `ConfigCatalog`, `AppModules`, `SceneModules`, `AppScope`, `GameScope`), and test templates (if Testing=yes + NSubstitute present)
5. **Updates `AGENTS.md` / project overlay docs** — records enabled/disabled features when needed

Then follow the checklist above. **Note:** never text-edit `.unity`, `.prefab`, or `.asset` files. Use MCP tools (`manage_scene`, `manage_gameobject`, `manage_components`) to create and wire scenes through the Unity Editor.

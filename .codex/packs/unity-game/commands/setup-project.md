# Setup Project — New Unity Project Initializer

> Apply `.codex/packs/unity-game/guides/guardrails.md` rules throughout.

Sets up a new Unity project using this template. Asks questions about the
project, then generates all project-specific boilerplate.

## What This Command Does

The template provides rules and commands that work for any Unity project. But
every project needs its own:
- Assembly definition files (with correct project name)
- Base framework classes (IEventBus, EventBus, EventBusAccessor, AppScope,
  GameScope, AppModules, SceneModules, ConfigCatalog)
- NSubstitute test assembly setup
- Sample test templates

---

## Step 0 — Detect Existing State (always runs first)

Before asking any questions, run these Bash commands to detect current project state:

```bash
[ -f ".codex/project/FEATURES.json" ] && echo "FEATURES_JSON=yes" || echo "FEATURES_JSON=no"
[ -d "Assets/_GameFolders/Scripts/Games/Ecs" ] && echo "ECS_DIR=yes" || echo "ECS_DIR=no"
[ -d "Assets/_GameFolders/Scripts/Tests" ] && echo "TESTS_DIR=yes" || echo "TESTS_DIR=no"
grep -q "com.unity.addressables" Packages/manifest.json 2>/dev/null && echo "ADDRESSABLES_PKG=yes" || echo "ADDRESSABLES_PKG=no"
[ -f ".codex/project/FEATURES.json" ] && cat .codex/project/FEATURES.json || echo "{}"
```

#### Decision Tree

**A — FEATURES.json does NOT exist**
→ Fresh setup. Proceed to Step 1 normally.
→ Pre-fill answers from detected signals as defaults.

**B — FEATURES.json EXISTS and matches detected state**
→ Print: "Project already configured. Features: addressables=[x], testing=[x], ecs=[x]"
→ Ask: "Re-run setup to regenerate files, or sync settings only?"
→ If sync: run Steps 5b + 5c only, then stop.
→ If regenerate: continue from Step 1.

**C — FEATURES.json EXISTS but CONFLICTS with detected state**
→ Print a conflict table showing declared vs detected values.
→ If fix: update FEATURES.json, run Steps 5b + 5c, stop.
→ If skip: continue to Step 1 for full re-setup.

**D — FEATURES.json does NOT exist but partial setup detected**
→ Print detected state as suggested defaults, proceed to Step 1 with defaults.

---

## Step 1 — Gather Info

Ask the developer ALL of these questions before doing anything else:

1. **Project name** (e.g. `SpaceTroopers`) — used for assembly names
2. **Unity version** (e.g. `6000.0.x`)
3. **Scenes**: Default is Bootstrap + Menu + Game. Any additions?
4. **Does the project use ECS DOTS?** (yes/no) — adds `Games/Ecs/` folder, ECS asmdef, bridge files
5. **Does the project use Addressables?** (yes/no) — if no, Addressables-specific rules and skills are skipped
6. **Does the project use Testing / NSubstitute?** (yes/no) — if no, test folders, asmdefs, and templates are all skipped
7. **Packages installed?**
   - VContainer (required)
   - UniTask (required)
   - New Input System (required)
   - **NSubstitute DLL** — only if Testing=yes. Placed at `Assets/Plugins/NSubstitute/NSubstitute.dll`?
   - TextMeshPro
   - DOTween
   - Other?

Collect all answers before proceeding. Do not ask one by one.

---

## Step 1b — Package Gate (NON-NEGOTIABLE)

#### Gate A — Runtime packages (blocks Steps 3 + 4)

| Package | Required |
|---------|----------|
| VContainer | YES |
| UniTask | YES |
| New Input System | YES |

**If ANY Gate A package is missing:**
1. Print a warning listing absent packages.
2. Run **only Step 2** (folder structure only — no .asmdef, no C# files).
3. Print the Manual Setup Checklist (Step 7).
4. **STOP. Tell the developer: "Install the missing packages, then run `/setup-project` again."**

**Only continue to Steps 3 + 4 when all Gate A packages are confirmed installed.**

#### Gate B — NSubstitute (blocks Step 5)

**If Testing=no:** Skip Gate B entirely. No test folders, test asmdefs, or templates.

**If Testing=yes and NSubstitute DLL is NOT confirmed present:**
- Generate test `.asmdef` files WITHOUT `precompiledReferences` and WITHOUT `overrideReferences: true`.
- Skip Step 5.
- Note in checklist: "After placing NSubstitute.dll, re-run `/setup-project` to generate test templates."

**If Testing=yes and NSubstitute DLL IS confirmed present:**
- Generate test `.asmdef` files with full NSubstitute references.
- Run Step 5 normally.

---

## Step 1c — Write FEATURES.json

After collecting all answers, write `.codex/project/FEATURES.json`:

```bash
cat > .codex/project/FEATURES.json << 'EOF'
{
  "addressables": <true|false>,
  "testing": <true|false>,
  "ecs": <true|false>,
  "graph": <true|false>
}
EOF
```

Replace `<true|false>` with actual answers. This file is read by agents and
commands to skip irrelevant rules and choose graph-backed pre-scans.

---

## Step 2 — Generate Folder Structure

Always run Step 2 regardless of gate status. Create folders (empty `.gitkeep` files where needed):

```
Assets/
├── _Scenes/                        ← create manually in Unity Editor
│   ├── Bootstrap.unity
│   ├── Menu.unity
│   └── Game.unity
├── _Framework/
│   ├── Events/                     ← FrameworkEvents.asmdef
│   ├── Installers/                 ← IInstaller.cs only if needed by legacy projects
│   ├── Logging/                    ← FrameworkLogging.asmdef
│   └── SaveLoadSystems/            ← FrameworkSaveLoadSystems.asmdef
├── Plugins/
│   └── NSubstitute/                ← place NSubstitute.dll here manually
└── _GameFolders/
    ├── Arts/
    ├── Prefabs/
    │   ├── Enemies/
    │   ├── UI/
    │   ├── VFX/
    │   └── Environment/
    ├── Configs/
    ├── Input/                      ← .inputactions file goes here
    └── Scripts/
        ├── Games/                  ← [ProjectName]Games.asmdef
        │   ├── Abstracts/
        │   ├── Concretes/
        │   │   └── Infrastructure/ ← AppScope, GameScope, AppModules, SceneModules, ConfigCatalog
        │   └── Ecs/                ← only if ECS=yes
        │       ├── Authorings/
        │       ├── Components/
        │       └── Systems/
        ├── Editors/                ← [ProjectName]Editor.asmdef
        └── Tests/                  ← only if Testing=yes
            ├── [ProjectName]EditModeTest/
            └── [ProjectName]PlayModeTest/
```

New projects use static `[Domain]Module.Install(...)` classes rather than
`ModuleInstaller : ScriptableObject` assets. `ConfigCatalog` is the only
ScriptableObject aggregator for module configs.

---

## Step 3 — Generate Assembly Definition Files

**Gate A must pass before this step.**

Replace `[ProjectName]` with the actual project name.

#### `_Framework/Events/FrameworkEvents.asmdef`
```json
{
    "name": "FrameworkEvents",
    "rootNamespace": "Framework.Events",
    "references": [],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": true
}
```

#### `_Framework/Logging/FrameworkLogging.asmdef`
```json
{
    "name": "FrameworkLogging",
    "rootNamespace": "Framework.Logging",
    "references": [],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": true
}
```

#### `_Framework/SaveLoadSystems/FrameworkSaveLoadSystems.asmdef`
```json
{
    "name": "FrameworkSaveLoadSystems",
    "rootNamespace": "Framework.SaveLoadSystems",
    "references": [],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": [],
    "noEngineReferences": true
}
```

#### `_GameFolders/Scripts/Games/[ProjectName]Games.asmdef`
```json
{
    "name": "[ProjectName]Games",
    "rootNamespace": "Game",
    "references": [
        "FrameworkEvents",
        "FrameworkLogging",
        "FrameworkSaveLoadSystems",
        "VContainer",
        "UniTask",
        "Unity.InputSystem"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": []
}
```

> If ECS=yes, add `"Unity.Entities"` and `"Unity.Transforms"` to the `references` array.

#### `_GameFolders/Scripts/Editors/[ProjectName]Editor.asmdef`
```json
{
    "name": "[ProjectName]Editor",
    "rootNamespace": "Game.Editor",
    "references": [
        "[ProjectName]Games"
    ],
    "includePlatforms": [
        "Editor"
    ],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": []
}
```

#### `_GameFolders/Scripts/Tests/[ProjectName]EditModeTest/[ProjectName]EditModeTest.asmdef`

**With NSubstitute (Gate B passed):**
```json
{
    "name": "[ProjectName]EditModeTest",
    "rootNamespace": "Game.EditModeTest",
    "references": [
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "[ProjectName]Games",
        "FrameworkEvents"
    ],
    "includePlatforms": ["Editor"],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": true,
    "precompiledReferences": [
        "nunit.framework.dll",
        "NSubstitute.dll"
    ],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"],
    "versionDefines": []
}
```

**Without NSubstitute (Gate B not passed):**
```json
{
    "name": "[ProjectName]EditModeTest",
    "rootNamespace": "Game.EditModeTest",
    "references": [
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "[ProjectName]Games",
        "FrameworkEvents"
    ],
    "includePlatforms": ["Editor"],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"],
    "versionDefines": []
}
```

#### `_GameFolders/Scripts/Tests/[ProjectName]PlayModeTest/[ProjectName]PlayModeTest.asmdef`

**With NSubstitute (Gate B passed):**
```json
{
    "name": "[ProjectName]PlayModeTest",
    "rootNamespace": "Game.PlayModeTest",
    "references": [
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "[ProjectName]Games",
        "FrameworkEvents"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": true,
    "precompiledReferences": [
        "nunit.framework.dll",
        "NSubstitute.dll"
    ],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"],
    "versionDefines": []
}
```

**Without NSubstitute:**
```json
{
    "name": "[ProjectName]PlayModeTest",
    "rootNamespace": "Game.PlayModeTest",
    "references": [
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "[ProjectName]Games",
        "FrameworkEvents"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": false,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"],
    "versionDefines": []
}
```

#### ECS asmdef (only if ECS=yes)

#### `_GameFolders/Scripts/Games/Ecs/[ProjectName]Ecs.asmdef`
```json
{
    "name": "[ProjectName]Ecs",
    "rootNamespace": "Game.Ecs",
    "references": [
        "FrameworkEvents",
        "[ProjectName]Games",
        "Unity.Entities",
        "Unity.Transforms",
        "Unity.Burst",
        "Unity.Collections",
        "Unity.Mathematics"
    ],
    "includePlatforms": [],
    "excludePlatforms": [],
    "allowUnsafeCode": true,
    "overrideReferences": false,
    "precompiledReferences": [],
    "autoReferenced": true,
    "defineConstraints": [],
    "versionDefines": []
}
```

---

## Step 4 — Generate Base Framework Files

**Gate A must pass before this step.**

#### `_Framework/Events/IEventBus.cs`
```csharp
namespace Framework.Events
{
    public interface IEventBus
    {
        void Publish<T>(T eventData) where T : struct, IEvent;
        void Subscribe<T>(System.Action<T> handler) where T : struct, IEvent;
        void Unsubscribe<T>(System.Action<T> handler) where T : struct, IEvent;
    }

    public interface IEvent { }
}
```

#### `_Framework/Events/EventBus.cs`
```csharp
using System;
using System.Collections.Generic;
using VContainer.Unity;

namespace Framework.Events
{
    public sealed class EventBus : IEventBus, IInitializable, IDisposable
    {
        #region Fields

        private readonly Dictionary<Type, List<Delegate>> _handlers = new();

        #endregion

        #region Lifecycle

        public void Initialize() { }

        public void Dispose()
        {
            _handlers.Clear();
        }

        #endregion

        #region Public Methods

        public void Publish<T>(T eventData) where T : struct, IEvent
        {
            var type = typeof(T);
            if (!_handlers.TryGetValue(type, out var list)) return;
            for (int i = list.Count - 1; i >= 0; i--)
            {
                if (list[i] is Action<T> handler)
                    handler(eventData);
            }
        }

        public void Subscribe<T>(Action<T> handler) where T : struct, IEvent
        {
            var type = typeof(T);
            if (!_handlers.ContainsKey(type))
                _handlers[type] = new List<Delegate>();
            _handlers[type].Add(handler);
        }

        public void Unsubscribe<T>(Action<T> handler) where T : struct, IEvent
        {
            var type = typeof(T);
            if (_handlers.TryGetValue(type, out var list))
                list.Remove(handler);
        }

        #endregion
    }
}
```

#### `_Framework/Events/EventBusAccessor.cs`
```csharp
using System;

namespace Framework.Events
{
    public static class EventBusAccessor
    {
        private static IEventBus _instance;

        public static IEventBus Instance => _instance
            ?? throw new InvalidOperationException(
                "EventBusAccessor not initialized. Call Initialize() inside AppScope.RegisterBuildCallback.");

        public static void Initialize(IEventBus bus) => _instance = bus;
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/ConfigCatalog.cs`
```csharp
using System.Collections.Generic;
using UnityEngine;

namespace Game.Concretes.Infrastructure
{
    [CreateAssetMenu(menuName = "Game/Infrastructure/Config Catalog", fileName = "ConfigCatalog")]
    public sealed class ConfigCatalog : ScriptableObject
    {
        public bool Validate()
        {
            var missing = new List<string>();

            // Add module config checks here:
            // if (_audio == null) missing.Add(nameof(_audio));

            if (missing.Count == 0)
            {
                return true;
            }

            Debug.LogError($"[ConfigCatalog] Missing configs: {string.Join(", ", missing)}", this);
            return false;
        }
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/EventBusModule.cs`
```csharp
using Framework.Events;
using VContainer;

namespace Game.Concretes.Infrastructure
{
    public static class EventBusModule
    {
        public static void Install(IContainerBuilder builder)
        {
            builder.Register<EventBus>(Lifetime.Singleton).AsImplementedInterfaces();
        }
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/AppModules.cs`
```csharp
using VContainer;

namespace Game.Concretes.Infrastructure
{
    public static class AppModules
    {
        public static void Install(IContainerBuilder builder, ConfigCatalog configs)
        {
            EventBusModule.Install(builder);
        }
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/SceneModules.cs`
```csharp
using VContainer;

namespace Game.Concretes.Infrastructure
{
    public static class SceneModules
    {
        public static void Install(IContainerBuilder builder)
        {
            // Register scene-lifetime pure C# services here.
        }
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/AppScope.cs`
```csharp
using Framework.Events;
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace Game.Concretes.Infrastructure
{
    public sealed class AppScope : LifetimeScope
    {
        #region Fields

        [SerializeField] private ConfigCatalog _configs;

        #endregion

        #region Lifecycle

        protected override void Configure(IContainerBuilder builder)
        {
            if (_configs == null)
            {
                Debug.LogError("[AppScope] ConfigCatalog missing.", this);
                return;
            }

            if (!_configs.Validate())
            {
                return;
            }

            builder.RegisterInstance(_configs);
            AppModules.Install(builder, _configs);

            builder.RegisterBuildCallback(container =>
            {
                EventBusAccessor.Initialize(container.Resolve<IEventBus>());
            });
        }

        #endregion
    }
}
```

#### `_GameFolders/Scripts/Games/Concretes/Infrastructure/GameScope.cs`
```csharp
using VContainer;
using VContainer.Unity;

namespace Game.Concretes.Infrastructure
{
    public sealed class GameScope : LifetimeScope
    {
        protected override void Configure(IContainerBuilder builder)
        {
            SceneModules.Install(builder);
        }
    }
}
```

---

## Step 5 — Generate Test Templates

**Gate A and Gate B must both pass before this step.**

#### `_GameFolders/Scripts/Tests/[ProjectName]EditModeTest/SampleEditModeTests.cs`
```csharp
using Framework.Events;
using NSubstitute;
using NUnit.Framework;

namespace Game.EditModeTest
{
    public class SampleEditModeTests
    {
        [Test]
        public void SampleMethod_WhenConditionMet_ReturnsExpectedResult()
        {
            // Arrange
            var eventBus = Substitute.For<IEventBus>();

            // Act
            eventBus.Publish(new SampleEvent());

            // Assert
            eventBus.Received(1).Publish(Arg.Any<SampleEvent>());
        }

        private struct SampleEvent : IEvent { }
    }
}
```

#### `_GameFolders/Scripts/Tests/[ProjectName]PlayModeTest/SamplePlayModeTests.cs`
```csharp
using System.Collections;
using NUnit.Framework;
using UnityEngine.TestTools;

namespace Game.PlayModeTest
{
    public class SamplePlayModeTests
    {
        [UnityTest]
        public IEnumerator SamplePlayTest_WhenSceneLoaded_ObjectExists()
        {
            // Arrange
            yield return null;

            // Act
            // Perform actions on MonoBehaviours or services

            // Assert
            Assert.Pass("Replace this with a real assertion.");
        }
    }
}
```

---

## Step 5b — Write Project Features Header to .codex/project/PROJECT.md

After all answers are collected, prepend a features summary to `.codex/project/PROJECT.md` using Bash:

```bash
python3 - << 'PYEOF'
import json

with open('.codex/project/FEATURES.json') as f:
    features = json.load(f)

lines = ["## Project Features\n\n"]
lines.append("Configured during `/setup-project`. Agents skip rules for disabled features.\n\n")
lines.append("| Feature | Status |\n")
lines.append("|---------|--------|\n")
lines.append(f"| Addressables | {'**enabled**' if features.get('addressables') else '~~disabled~~ — skip Addressables rules and skills'} |\n")
lines.append(f"| Testing / NSubstitute | {'**enabled**' if features.get('testing') else '~~disabled~~ — skip testing rules, test agents, test commands'} |\n")
lines.append(f"| ECS DOTS | {'**enabled**' if features.get('ecs') else '~~disabled~~ — skip ecs-dots rules and ECS guidance'} |\n")
lines.append("\n---\n\n")

header = "".join(lines)

with open('.codex/project/PROJECT.md', 'r') as f:
    existing = f.read()

if "## Project Features" not in existing:
    with open('.codex/project/PROJECT.md', 'w') as f:
        f.write(header + existing)
    print("Project Features section added to PROJECT.md")
else:
    import re
    updated = re.sub(r'## Project Features\n.*?---\n\n', header, existing, flags=re.DOTALL)
    with open('.codex/project/PROJECT.md', 'w') as f:
        f.write(updated)
    print("Project Features section updated in PROJECT.md")
PYEOF
```

---

## Step 5c — MCP Scene & Wiring Setup

Run this step ONLY if MCP is connected.

MCP can create scenes, add GameObjects, attach and configure components, and wire prefab references directly in the Unity Editor.

#### Create Scenes

```python
manage_scene(action="create", name="Bootstrap", template="empty", path="Assets/_Scenes/Bootstrap.unity")
manage_scene(action="create", name="Menu", template="empty", path="Assets/_Scenes/Menu.unity")
manage_scene(action="create", name="Game", template="3d_basic", path="Assets/_Scenes/Game.unity")
```

#### Set Up AppScope in Bootstrap Scene

Wait for compilation to finish after Step 4 files are generated, then:

```python
manage_scene(action="load", path="Assets/_Scenes/Bootstrap.unity")
manage_gameobject(action="create", name="AppScope")
manage_gameobject(action="modify", target="AppScope",
    components_to_add=["Game.Concretes.Infrastructure.AppScope"])
```

#### Create ConfigCatalog Asset and Wire It

```python
manage_scriptable_object(
    action="create",
    path="Assets/_GameFolders/Configs",
    name="ConfigCatalog",
    type_name="Game.Concretes.Infrastructure.ConfigCatalog"
)
manage_components(
    action="set_property",
    target="AppScope",
    component_type="Game.Concretes.Infrastructure.AppScope",
    property="_configs",
    value="Assets/_GameFolders/Configs/ConfigCatalog.asset"
)
```

#### Configure Build Settings

```python
manage_build(action="scenes", scenes='[
  {"path": "Assets/_Scenes/Bootstrap.unity", "enabled": true},
  {"path": "Assets/_Scenes/Menu.unity", "enabled": true},
  {"path": "Assets/_Scenes/Game.unity", "enabled": true}
]')
```

---

## Step 6 — Update Project Context Files

After generating all files, update:

- `.codex/project/PROJECT.md` — project name, Unity version, stack
- `.codex/project/STRUCTURE.md` — folder layout
- `.codex/project/TOOLING.md` — environment and commands
- `.codex/project/CODING_CONVENTIONS.md` — project-specific decisions

---

## Step 7 — Print Manual Setup Checklist

End with this checklist:

```
## Manual Setup Required

### New Input System — Project Settings
1. Edit → Project Settings → Player → Active Input Handling → Input System Package (New)
   (Unity will restart — cannot be set via MCP)
2. Create Assets/_GameFolders/Input/[ProjectName]Controls.inputactions
3. Select asset → enable "Generate C# Class" in Inspector → Apply

### NSubstitute (only if Testing=yes)
NSubstitute cannot be installed via Package Manager.
1. Download from https://www.nuget.org/packages/NSubstitute
2. Extract NSubstitute.dll from the netstandard2.0 lib/ folder
3. Place at: Assets/Plugins/NSubstitute/NSubstitute.dll
4. Re-run /setup-project to generate test templates with NSubstitute references.

### VContainer
Install via Package Manager: https://github.com/hadashiA/VContainer

### UniTask
Install via Package Manager: https://github.com/Cysharp/UniTask
```

If MCP was NOT connected during Step 5c, also add:

```
### Scenes (MCP unavailable — create manually in Unity Editor)
File → New Scene → Save As:
- Assets/_Scenes/Bootstrap.unity (Build index 0)
- Assets/_Scenes/Menu.unity
- Assets/_Scenes/Game.unity

### AppScope Scene Setup (MCP unavailable)
1. Open Bootstrap.unity
2. Create empty GameObject "AppScope"
3. Add AppScope component
4. Right-click Assets/_GameFolders/Configs → Create → Game/Infrastructure/Config Catalog
5. Name it ConfigCatalog, drag onto AppScope._configs field in Inspector

### Build Settings (MCP unavailable)
File → Build Settings → Add Open Scenes — Bootstrap at index 0.
```

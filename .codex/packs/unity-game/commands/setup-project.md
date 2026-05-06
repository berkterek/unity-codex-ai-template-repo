# Setup Project — New Unity Project Initializer

Sets up a new Unity project using this template. Asks questions about the
project, then generates all project-specific boilerplate.

## What This Command Does

The template provides rules and commands that work for any Unity project. But
every project needs its own:
- Assembly definition files (with correct project name).
- Base framework classes (IEventBus, ModuleInstaller, AppScope).
- NSubstitute test assembly setup.
- Sample test templates.

---

## Step 1 — Gather Info

Ask the developer:
1. **Project name** (e.g. `SpaceTroopers`) — used for assembly names.
2. **Unity version** (e.g. `6000.0.x`).
3. **Scenes** — default is Bootstrap + Menu + Game. Any additions?
4. **Does the project use ECS DOTS?** (yes/no) — adds `Games/Ecs/` folder and
   ECS assembly refs.
5. **Third-party packages installed?**
   - VContainer (required)
   - UniTask (required)
   - New Input System (required)
   - TextMeshPro
   - DOTween
   - Other?

---

## Step 2 — Generate Folder Structure

Create these folders:

```
Assets/
├── _Scenes/
│   ├── Bootstrap.unity       (placeholder — created manually)
│   ├── Menu.unity
│   └── Game.unity
├── _Framework/
│   ├── Events/
│   ├── Logging/
│   └── SaveLoadSystems/
└── _GameFolders/
    ├── Arts/
    ├── Prefabs/
    ├── Configs/
    ├── Plugins/
    │   └── NSubstitute/      (NSubstitute.dll placed here manually)
    └── Scripts/
        ├── Games/
        │   ├── Abstracts/
        │   ├── Concretes/
        │   └── Ecs/          (only if ECS enabled)
        ├── Editors/
        └── Tests/
            ├── [ProjectName]Tests/
            └── [ProjectName]PlayTests/
```

---

## Step 3 — Generate Assembly Definition Files

Create `.asmdef` files with the project name substituted:

**`[ProjectName]Games.asmdef`** — runtime, references VContainer + UniTask +
Input System.

**`[ProjectName]Editor.asmdef`** — editor-only.

**`[ProjectName]Tests.asmdef`** — Edit Mode with NSubstitute:

```json
{
    "name": "[ProjectName]Tests",
    "references": [
        "UnityEngine.TestRunner",
        "UnityEditor.TestRunner",
        "[ProjectName]Games"
    ],
    "includePlatforms": ["Editor"],
    "overrideReferences": true,
    "precompiledReferences": [
        "nunit.framework.dll",
        "NSubstitute.dll"
    ],
    "autoReferenced": false,
    "defineConstraints": ["UNITY_INCLUDE_TESTS"]
}
```

**`[ProjectName]PlayTests.asmdef`** — Play Mode with NSubstitute (same
structure, no `includePlatforms` filter).

---

## Step 4 — Generate Base Framework Files

**`_Framework/Events/IEventBus.cs`**

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

**`_GameFolders/Scripts/Games/Abstracts/ModuleInstaller.cs`**

```csharp
using VContainer;
using UnityEngine;

namespace Game.Abstracts
{
    public abstract class ModuleInstaller : ScriptableObject
    {
        public abstract void Install(IContainerBuilder builder);
    }
}
```

**`_GameFolders/Scripts/Games/Concretes/Infrastructure/AppScope.cs`** —
Bootstrap scene scope.

**`_GameFolders/Scripts/Games/Concretes/Infrastructure/AppInstaller.cs`** —
Composite installer that iterates `ModuleInstaller[]`.

---

## Step 5 — Generate Test Templates

Generate `SampleEditModeTests.cs` and `SamplePlayModeTests.cs` showing the
AAA pattern with NSubstitute.

---

## Step 6 — Update Project Files

After generating all files, update the project context files:

- `.codex/project/PROJECT.md` — fill in project name, Unity version, stack.
- `.codex/project/STRUCTURE.md` — fill in folder layout.
- `.codex/project/TOOLING.md` — fill in environment and commands.
- `.codex/project/CODING_CONVENTIONS.md` — add any project-specific decisions.

---

## Step 7 — Print Manual Setup Checklist

End with this checklist:

```
## Manual Setup Required

### NSubstitute (REQUIRED for tests)
1. Download NSubstitute.dll from https://github.com/nsubstitute/NSubstitute/releases
   (use the netstandard2.0 build)
2. Place at Assets/_GameFolders/Plugins/NSubstitute/NSubstitute.dll

### VContainer
Install via Package Manager:
https://github.com/hadashiA/VContainer

### UniTask
Install via Package Manager:
https://github.com/Cysharp/UniTask

### New Input System
1. Install via Package Manager: com.unity.inputsystem
2. Edit > Project Settings > Player > Active Input Handling
   > Input System Package (New)
3. Create Assets/Input/[ProjectName]Controls.inputactions
4. Enable "Generate C# Class" in the .inputactions inspector

### AppScope Scene Setup
1. Open Bootstrap scene
2. Create empty GameObject "AppScope"
3. Add AppScope component
4. Create AppInstaller.asset > Assets/Configs/
5. Assign to AppScope._appInstaller
6. Set Bootstrap as Build Index 0 in Build Settings
```

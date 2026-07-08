# New Module — Static Module Generator

Generate the standard static module structure for a new service/system and wire
it into the project through `AppModules.cs` and `ConfigCatalog.cs`.

## Inputs To Read

- `AGENTS.md`
- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/project/CODING_CONVENTIONS.md`
- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/packs/unity-game/rules/bootstrap-pattern.md`

Read these project files before proposing edits when they exist:

- `Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure/AppModules.cs`
- `Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure/ConfigCatalog.cs`

## What You Generate

For a module named `[X]`:

```text
Assets/_GameFolders/Scripts/Games/Abstracts/[X]/
└── I[X]Service.cs

Assets/_GameFolders/Scripts/Games/Concretes/[X]/
├── [X]Service.cs
├── [X]Configuration.cs
├── [X]Module.cs
└── [X]Events.cs
```

Optional when Unity API access is needed:

```text
Assets/_GameFolders/Scripts/Games/Abstracts/[X]/
└── I[X]Provider.cs

Assets/_GameFolders/Scripts/Games/Concretes/[X]/
└── Basic[X]Provider.cs
```

Plus edits:

- `AppModules.cs`: add `[X]Module.Install(builder, configs.[X]);`
- `ConfigCatalog.cs`: add serialized config field, public property, and
  `Validate()` null check.

## Process

### Step 1 — Gather Requirements

Ask all questions at once:

1. Module name
2. Main operations exposed by the service
3. Pure C# or Unity provider needed
4. Events published/subscribed
5. Config fields required

### Step 2 — Read Infrastructure

Read `AppModules.cs` and `ConfigCatalog.cs`. If they do not exist, report that
`/setup-project` must create the infrastructure first, or include them in the
generation if this is a fresh project setup.

### Step 3 — Architecture Gate

Show:

```markdown
## ARCHITECTURE_GATE — New Module: [X]

Files:
- I[X]Service.cs
- [X]Service.cs
- [X]Configuration.cs
- [X]Module.cs
- [X]Events.cs
- I[X]Provider.cs / Basic[X]Provider.cs (if needed)

Wiring:
- AppModules.cs: [X]Module.Install(builder, configs.[X]);
- ConfigCatalog.cs: _[x] field, [X] property, Validate() null check

Type `go` to generate.
```

Do not write files until the user says `go`.

### Step 4 — Generate Files

Generate in this order:

1. `I[X]Service.cs`
2. `I[X]Provider.cs` when needed
3. `[X]Service.cs`
4. `[X]Configuration.cs`
5. `[X]Module.cs`
6. `[X]Events.cs`
7. `Basic[X]Provider.cs` when needed
8. `AppModules.cs`
9. `ConfigCatalog.cs`

### Step 5 — Verify

Run:

```bash
bash .codex/guardrails/run.sh --files <changed files>
```

If Unity MCP is connected, refresh and check console compilation errors.

## Code Rules

| Rule | Detail |
|------|--------|
| `[X]Module` is static | `public static class [X]Module`; never `ScriptableObject`, never `MonoBehaviour` |
| Install signature | `public static void Install(IContainerBuilder builder, [X]Configuration config)` |
| Null guard | `Debug.LogError(...)` + `return`; never throw during container install |
| Registration | `.AsImplementedInterfaces()` for services and entry points |
| EventBus first | `EventBusModule.Install(builder)` remains first in `AppModules.Install(...)` |
| AppScope stable | Do not edit `AppScope.cs` for new modules |
| Service purity | Service has no `using UnityEngine`; Unity API goes through Provider |
| Events file | Module events live in `[X]Events.cs` |

## Templates

### I[X]Service.cs

```csharp
namespace Game.Abstracts.[X]
{
    public interface I[X]Service
    {
    }
}
```

### [X]Service.cs

```csharp
using System;
using Game.Abstracts.[X];
using VContainer.Unity;

namespace Game.Concretes.[X]
{
    public sealed class [X]Service : I[X]Service, IInitializable, IDisposable
    {
        #region Fields

        private readonly [X]Configuration _config;

        #endregion

        #region Constructor

        public [X]Service([X]Configuration config)
        {
            _config = config;
        }

        #endregion

        #region Lifecycle

        public void Initialize()
        {
        }

        public void Dispose()
        {
        }

        #endregion
    }
}
```

### [X]Configuration.cs

```csharp
using UnityEngine;

namespace Game.Concretes.[X]
{
    [CreateAssetMenu(menuName = "Game/[X] Configuration", fileName = "[X]Configuration")]
    public sealed class [X]Configuration : ScriptableObject
    {
    }
}
```

### [X]Module.cs

```csharp
using UnityEngine;
using VContainer;

namespace Game.Concretes.[X]
{
    public static class [X]Module
    {
        public static void Install(IContainerBuilder builder, [X]Configuration config)
        {
            if (config == null)
            {
                Debug.LogError("[[X]Module] [X]Configuration missing.");
                return;
            }

            builder.RegisterInstance(config);
            builder.Register<[X]Service>(Lifetime.Singleton).AsImplementedInterfaces();
        }
    }
}
```

### [X]Events.cs

```csharp
using Framework.Events;

namespace Game.Concretes.[X]
{
    // public readonly struct [X]ChangedEvent : IEvent { }
}
```

## Portability Checklist Output

After generating, print:

```text
## Module Portability Checklist: [X]

[ ] [X]Module is static, not ScriptableObject or MonoBehaviour
[ ] Service has no UnityEngine import
[ ] Cross-module dependencies are interfaces only
[ ] Config null guard uses Debug.LogError + return
[ ] Events live in [X]Events.cs
[ ] Provider, if any, is the only Unity API boundary
[ ] Public methods are declared on the interface
[ ] AppModules.cs updated after EventBusModule
[ ] ConfigCatalog.cs updated with field, property, Validate() check

Editor action required:
1. Create [X]Configuration asset under Assets/_GameFolders/Configs/
2. Assign it in the ConfigCatalog asset
```

$ARGUMENTS

# Bootstrap & Installer Pattern (NON-NEGOTIABLE)

## Layer Structure

```
IInstaller (interface)          ← Framework layer
    ↑
ModuleInstaller (abstract SO)   ← Framework layer — ScriptableObject + IInstaller
    ↑
[Module]Installer (sealed SO)   ← Game layer — registers a single module's dependencies
    ↑
AppInstaller (sealed SO)        ← Game layer — lists modules, calls them in order
    ↑
AppScope (LifetimeScope)        ← Bootstrap scene — calls AppInstaller
```

## IInstaller

```csharp
// _Framework/Installers/IInstaller.cs
namespace Framework.Installers
{
    public interface IInstaller
    {
        void Install(IContainerBuilder builder);
    }
}
```

## ModuleInstaller

```csharp
// _Framework/Installers/ModuleInstaller.cs
using UnityEngine;
using VContainer;

namespace Framework.Installers
{
    public abstract class ModuleInstaller : ScriptableObject, IInstaller
    {
        public abstract void Install(IContainerBuilder builder);
    }
}
```

Lives under `_Framework/Installers/` — contains `ScriptableObject` so must NOT go in `Games/Abstracts/`.

## AppInstaller

```csharp
[CreateAssetMenu(menuName = "Game/Infrastructure/App Installer", fileName = "AppInstaller")]
public sealed class AppInstaller : ScriptableObject, IInstaller
{
    [SerializeField] private List<ModuleInstaller> _modules = new();

    public void Install(IContainerBuilder builder)
    {
        foreach (var module in _modules)
        {
            if (module == null) continue;
            module.Install(builder);
        }
    }
}
```

- Only iterates the list — never registers anything directly
- `EventBusInstaller` is always the **first** element
- Null modules silently skipped

## [Module]Installer

```csharp
[CreateAssetMenu(menuName = "Game/Installers/Audio", fileName = "AudioInstaller")]
public sealed class AudioInstaller : ModuleInstaller
{
    [SerializeField] private AudioConfiguration _config;

    public override void Install(IContainerBuilder builder)
    {
        if (_config == null)
        {
            Debug.LogError("[AudioInstaller] AudioConfiguration is missing.", this);
            return;
        }

        builder.RegisterInstance(_config);
        builder.Register<AudioService>(Lifetime.Singleton).AsImplementedInterfaces();
    }
}
```

- `Debug.LogError` + `return` on null config — never `throw`
- `.AsImplementedInterfaces()` — covers lifecycle interfaces automatically
- Registers only its own module's dependencies

## EventBusInstaller (required, always first)

```csharp
[CreateAssetMenu(menuName = "Game/Installers/EventBus", fileName = "EventBusInstaller")]
public sealed class EventBusInstaller : ModuleInstaller
{
    public override void Install(IContainerBuilder builder)
    {
        builder.Register<EventBus>(Lifetime.Singleton).AsImplementedInterfaces();
    }
}
```

## AppScope

```csharp
public sealed class AppScope : LifetimeScope
{
    [SerializeField] private AppInstaller     _appInstaller;
    [SerializeField] private AppConfiguration _appConfiguration;

    protected override void Configure(IContainerBuilder builder)
    {
        if (_appConfiguration == null) { Debug.LogError("[AppScope] AppConfiguration missing."); return; }
        if (_appInstaller == null) { Debug.LogError("[AppScope] AppInstaller missing."); return; }

        builder.RegisterInstance(_appConfiguration);
        builder.RegisterComponentInHierarchy<UIRoot>();
        builder.RegisterComponentInHierarchy<AudioRoot>();
        _appInstaller.Install(builder);
    }
}
```

**`AppScope.cs` NEVER changes.** To add a new module, add it to `AppInstaller.asset`.

## GameScope

Registers scene-specific dependencies (MonoBehaviours present in the scene):

```csharp
public sealed class GameScope : LifetimeScope
{
    [SerializeField] private PlayerProvider _playerProvider;

    protected override void Configure(IContainerBuilder builder)
    {
        if (_playerProvider == null) { Debug.LogError("[GameScope] PlayerProvider missing."); return; }
        builder.RegisterComponent(_playerProvider);
    }
}
```

- Only `builder.RegisterComponent(...)` — never `builder.Register<T>(...)`
- `[SerializeField]` fields populated on **scene instance**, not prefab

## New Module Addition Flow

1. Write `[Module]Installer.cs` — derive from `ModuleInstaller`, add `[CreateAssetMenu]`
2. Create the asset in Unity: `Assets → Create → Game/Installers/[ModuleName]`
3. Assign config ScriptableObject in Inspector
4. Open `AppInstaller.asset` → add to `_modules` list
5. **Do not touch** `AppScope.cs`

## Common Mistakes

| Mistake | Solution |
|---------|----------|
| EventBus registered directly in AppScope | Create EventBusInstaller, add first in AppInstaller list |
| AppScope modified for new module | Add to AppInstaller.asset — AppScope.cs never changes |
| ModuleInstaller placed in GameFolders/Abstracts/ | Must live under _Framework/Installers/ |
| `throw` in null guard | Use `return` + `Debug.LogError` |
| `.As<IEventBus>()` instead of `.AsImplementedInterfaces()` | Use AsImplementedInterfaces — covers lifecycle too |
| AppInstaller._modules declared as array | Use `List<ModuleInstaller>` for Inspector reordering |

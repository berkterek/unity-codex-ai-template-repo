# Bootstrap & Static Module Pattern

The project uses code-first static module installation. Do not use a
`ModuleInstaller : ScriptableObject` chain for new work.

## Layer Structure

```text
ConfigCatalog : ScriptableObject       <- aggregates all module config assets
    |
[Domain]Module.Install(builder, config) <- static class per module
    |
AppModules.Install(builder, catalog)    <- single module wiring point
    |
AppScope.Configure()                    <- validates catalog and calls AppModules
```

## ConfigCatalog

`ConfigCatalog` is the only drag-drop point for module configuration assets.

```csharp
using System.Collections.Generic;
using UnityEngine;

namespace Game.Concretes.Infrastructure
{
    [CreateAssetMenu(menuName = "Game/Infrastructure/Config Catalog", fileName = "ConfigCatalog")]
    public sealed class ConfigCatalog : ScriptableObject
    {
        [SerializeField] private AudioConfiguration _audio;

        public AudioConfiguration Audio => _audio;

        public bool Validate()
        {
            var missing = new List<string>();
            if (_audio == null) missing.Add(nameof(_audio));

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

Rules:

- Config fields are private `[SerializeField]`.
- Public properties expose config read-only.
- `Validate()` reports missing configs and returns `false`.
- Do not scatter config references across scene prefabs.

## Static Module

Each module owns one static installer class:

```csharp
using UnityEngine;
using VContainer;

namespace Game.Concretes.Audio
{
    public static class AudioModule
    {
        public static void Install(IContainerBuilder builder, AudioConfiguration config)
        {
            if (config == null)
            {
                Debug.LogError("[AudioModule] AudioConfiguration missing.");
                return;
            }

            builder.RegisterInstance(config);
            builder.Register<AudioService>(Lifetime.Singleton).AsImplementedInterfaces();
        }
    }
}
```

Rules:

- Module classes are `public static class [Domain]Module`.
- They do not inherit `ScriptableObject` or `MonoBehaviour`.
- Install signature is `Install(IContainerBuilder builder, [Domain]Configuration config)`.
- Null guard uses `Debug.LogError` + `return`, never `throw`.
- Use `.AsImplementedInterfaces()` for services and entry points.
- Register providers separately with `RegisterComponentInHierarchy` or scene scope
  wiring when a Unity API boundary is required.

## AppModules

`AppModules` is the only place where global modules are ordered.

```csharp
using VContainer;

namespace Game.Concretes.Infrastructure
{
    public static class AppModules
    {
        public static void Install(IContainerBuilder builder, ConfigCatalog configs)
        {
            EventBusModule.Install(builder);
            AudioModule.Install(builder, configs.Audio);
        }
    }
}
```

Rules:

- `EventBusModule.Install(builder)` is first.
- New modules add one line here.
- Do not register module services directly in `AppScope`.

## AppScope

`AppScope` validates config and delegates.

```csharp
using UnityEngine;
using VContainer;
using VContainer.Unity;

namespace Game.Concretes.Infrastructure
{
    public sealed class AppScope : LifetimeScope
    {
        [SerializeField] private ConfigCatalog _configs;

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
        }
    }
}
```

Rules:

- `AppScope.cs` should not change when adding a module.
- Global pure C# services install through `AppModules`.
- Scene objects install through scene scopes or provider registration.

## SceneModules And GameScope

Scene-lifetime pure C# services use `SceneModules`; scene MonoBehaviours use
`GameScope`.

```csharp
public static class SceneModules
{
    public static void Install(IContainerBuilder builder)
    {
        // Scene-local pure C# services only.
    }
}
```

```csharp
public sealed class GameScope : LifetimeScope
{
    [SerializeField] private PlayerProvider _playerProvider;

    protected override void Configure(IContainerBuilder builder)
    {
        builder.RegisterComponent(_playerProvider).AsImplementedInterfaces();
        SceneModules.Install(builder);
    }
}
```

Rules:

- `GameScope` registers scene component instances only.
- Do not put inline pure C# `builder.Register<T>()` calls in `GameScope`;
  place them in `SceneModules`.

## New Module Flow

1. Create `I[Domain]Service`.
2. Create `[Domain]Service`.
3. Create `[Domain]Configuration`.
4. Create static `[Domain]Module`.
5. Create `[Domain]Events` when needed.
6. Add config to `ConfigCatalog`.
7. Add one line to `AppModules.Install`.
8. Create and assign the config asset in Unity.

## Forbidden Patterns

| Forbidden | Use Instead |
|-----------|-------------|
| `ModuleInstaller : ScriptableObject` for new modules | static `[Domain]Module.Install(...)` |
| Editing `AppScope.cs` for every module | one line in `AppModules.cs` |
| Module config fields on random prefabs | `ConfigCatalog` |
| `throw` in install null guard | `Debug.LogError` + `return` |
| Direct service registration in `GameScope` | `SceneModules` or module installer |

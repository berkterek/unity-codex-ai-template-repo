# VContainer Guide

VContainer is the only dependency injection mechanism. Do not use singletons,
service locators, or `FindObjectOfType` dependency lookup.

## Bootstrap Shape

```text
AppScope
  -> ConfigCatalog
  -> AppModules.Install(builder, configs)
  -> static [Domain]Module.Install(builder, config)
```

Scene-specific scopes use:

```text
GameScope
  -> RegisterComponent(scene provider/controller instances)
  -> SceneModules.Install(builder)
```

## Global Modules

```csharp
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
```

`AppModules` owns ordering:

```csharp
public static class AppModules
{
    public static void Install(IContainerBuilder builder, ConfigCatalog configs)
    {
        EventBusModule.Install(builder);
        AudioModule.Install(builder, configs.Audio);
    }
}
```

## Registration Rules

- Services register through static modules.
- Providers/controllers/views register as scene components.
- Use `.AsImplementedInterfaces()` unless a narrower binding is required.
- Use `RegisterEntryPoint<T>().AsImplementedInterfaces()` for `IInitializable`,
  `ITickable`, `IDisposable` services.
- Do not instantiate services/providers with `new`.
- Do not edit `AppScope.cs` for new modules.

## Common Failures

| Symptom | Check |
|---------|-------|
| Service cannot resolve | Module line exists in `AppModules.Install` |
| Config is null | Config assigned in `ConfigCatalog` asset |
| Input fires twice | `InputService` registered once with `RegisterEntryPoint` |
| Provider missing | Scene component registered in scope or component hierarchy |

# Project VContainer Setup Usage

This project uses static module wiring:

```text
ConfigCatalog -> AppModules -> static [Domain]Module -> AppScope
```

## AppScope

`AppScope` holds a `ConfigCatalog` reference, validates it, registers it, and
calls `AppModules.Install(builder, configs)`.

Do not edit `AppScope.cs` when adding a normal module.

## New Module

1. Create `[Domain]Configuration`.
2. Create static `[Domain]Module.Install(IContainerBuilder builder, [Domain]Configuration config)`.
3. Add config field/property/null-check to `ConfigCatalog`.
4. Add `[Domain]Module.Install(builder, configs.[Domain]);` to `AppModules`.

## Input

Register input once:

```csharp
builder.RegisterEntryPoint<InputService>().AsImplementedInterfaces();
```

Do not register `InputView`.

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Service not resolving | Module line exists in `AppModules.Install` |
| Config null | Config assigned in `ConfigCatalog` asset |
| Provider not resolving | Scene component registered in a LifetimeScope |

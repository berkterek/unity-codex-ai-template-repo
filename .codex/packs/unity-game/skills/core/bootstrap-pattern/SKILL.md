---
name: bootstrap-pattern
description: "Use for project bootstrap wiring — ConfigCatalog, static Modules, AppModules, AppScope, GameScope."
---

# Bootstrap Pattern — Static Modules

Read `.codex/packs/unity-game/rules/bootstrap-pattern.md` as the source of
truth.

## Summary

```text
ConfigCatalog -> [Domain]Module.Install(builder, config) -> AppModules -> AppScope
```

- `ConfigCatalog` aggregates module config assets.
- `[Domain]Module` is a static class.
- `AppModules.Install(builder, configs)` orders global modules.
- `EventBusModule` is first.
- `AppScope` validates `ConfigCatalog` and delegates; it does not change for
  normal module additions.
- `GameScope` registers scene component instances and calls `SceneModules`.

## New Module Flow

1. Add `I[Domain]Service`.
2. Add `[Domain]Service`.
3. Add `[Domain]Configuration`.
4. Add static `[Domain]Module`.
5. Add `[Domain]Events` when needed.
6. Add config field/property/null-check to `ConfigCatalog`.
7. Add one line to `AppModules.Install`.

## Forbidden

- `ModuleInstaller : ScriptableObject` for new modules
- `AppInstaller.asset` module lists for new modules
- Editing `AppScope.cs` for every new module
- Throwing from module install null guards

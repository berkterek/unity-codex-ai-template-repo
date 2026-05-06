# VContainer — Setup and Usage Guide

VContainer is a fast, zero-allocation dependency injection container for Unity.
It replaces singletons, static accessors, and `FindObjectOfType` with explicit
constructor injection wired at scope boundaries.

---

## Scope Hierarchy

```
AppScope (Bootstrap scene — DontDestroyOnLoad)
├── MenuScope  (Menu scene — child of AppScope)
└── GameScope  (Game scene — child of AppScope)
```

- Bootstrap scene (Build index 0) loads once and never unloads.
- `AppScope` registers global services (Audio, EventBus, SaveLoad, etc.).
- Child scopes resolve from parent — `GameScope` can use `IAudioService`
  registered in `AppScope`.
- Sibling scopes are isolated — `MenuScope` cannot access `GameScope`
  registrations.
- A scope disposes all its registrations when the scene unloads.

---

## AppScope Pattern

`AppScope.cs` never changes. Add new modules by creating a `ModuleInstaller`
asset and dragging it into `AppInstaller.asset`.

```csharp
public sealed class AppScope : LifetimeScope
{
    [SerializeField] private AppInstaller     _appInstaller;
    [SerializeField] private AppConfiguration _appConfiguration;

    [Header("Scene Infrastructure")]
    [SerializeField] private UIRoot    _uiRoot;
    [SerializeField] private AudioRoot _audioRoot;

    protected override void Configure(IContainerBuilder builder)
    {
        builder.RegisterInstance(_appConfiguration);
        builder.RegisterComponent(_uiRoot);
        builder.RegisterComponent(_audioRoot);
        _appInstaller.Install(builder);
    }
}
```

---

## Registration Patterns

### Pure C# Service (most common)

```csharp
// Register implementation, resolve via interface
builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();

// WRONG — resolves as concrete, breaks interface-first architecture
builder.Register<AudioService>(Lifetime.Singleton);
```

### MonoBehaviour / Component

```csharp
builder.RegisterComponent(_audioRoot);                         // from Inspector
builder.RegisterComponentInHierarchy<InputView>();            // find in scene
builder.RegisterComponentInNewPrefab(prefab, Lifetime.Scoped); // from prefab
```

### ScriptableObject Config

```csharp
builder.RegisterInstance(_appConfiguration);
```

### Factory

```csharp
builder.RegisterFactory<EnemyService>(container =>
    new EnemyService(
        container.Resolve<IEventBus>(),
        container.Resolve<IPoolService>()));
```

---

## Lifetime Options

| Lifetime | Instances | When to use |
|----------|-----------|-------------|
| `Singleton` | 1 per scope | Services used across the whole scene/app |
| `Scoped` | 1 per scope | Same as Singleton inside one scope |
| `Transient` | New instance per resolve | Stateless helpers, factories |

In practice: use `Singleton` for services. `Transient` only when multiple
independent instances are needed.

---

## ModuleInstaller Pattern

Each module has its own `ModuleInstaller` ScriptableObject. `AppScope` never
lists modules directly.

```csharp
[CreateAssetMenu(menuName = "Installers/AudioInstaller")]
public sealed class AudioInstaller : ModuleInstaller
{
    [SerializeField] private AudioConfiguration _config;

    public override void Install(IContainerBuilder builder)
    {
        if (_config == null)
            throw new InvalidOperationException(
                $"{nameof(AudioInstaller)}: _config is not assigned.");

        builder.RegisterInstance(_config);
        builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
    }
}
```

**Adding a new module:**
1. Create `[Module]Installer.asset` via `Assets > Create > Installers > ...`
2. Assign the config ScriptableObject in the Inspector.
3. Open `AppInstaller.asset` → drag the new installer into the Modules list.
4. `AppScope.cs` does not change.

---

## Injection Methods

### Constructor Injection (preferred for pure C# classes)

```csharp
public sealed class ScoreService : IScoreService
{
    private readonly IEventBus          _eventBus;
    private readonly ScoreConfiguration _config;

    public ScoreService(IEventBus eventBus, ScoreConfiguration config)
    {
        _eventBus = eventBus;
        _config   = config;
    }
}
```

VContainer resolves constructor parameters automatically — no attributes needed.

### Method Injection (for MonoBehaviours)

```csharp
public sealed class PlayerView : MonoBehaviour
{
    private IPlayerService _playerService;

    [Inject]
    public void Construct(IPlayerService playerService)
    {
        _playerService = playerService;
    }
}
```

Register the MonoBehaviour:

```csharp
builder.RegisterComponentInHierarchy<PlayerView>();
```

### IInitializable / IDisposable Lifecycle

```csharp
public sealed class AudioService : IAudioService, IInitializable, IDisposable
{
    public void Initialize()
    {
        _eventBus.Subscribe<MuteChangedEvent>(OnMuteChanged);
    }

    public void Dispose()
    {
        _eventBus.Unsubscribe<MuteChangedEvent>(OnMuteChanged);
    }
}
```

Register lifecycle interfaces:

```csharp
builder.Register<AudioService>(Lifetime.Singleton)
    .As<IAudioService>()
    .AsImplementedInterfaces();
```

---

## Child Scope Setup

```csharp
public sealed class GameScope : LifetimeScope
{
    [SerializeField] private GameInstaller _gameInstaller;

    protected override void Configure(IContainerBuilder builder)
    {
        _gameInstaller.Install(builder);
    }
}
```

Set `Parent` in the Inspector to `AppScope` so the child scope inherits global
registrations.

---

## No GameContext / Service Locator (NON-NEGOTIABLE)

```csharp
// BAD — hides real dependencies, every class gets everything
public class GameContext
{
    public IPlayerService Player { get; }
    public IScoreService  Score  { get; }
    public IAudioService  Audio  { get; }
}

// GOOD — each class declares only what it actually needs
public sealed class ScoreView : MonoBehaviour
{
    [Inject]
    public void Construct(IScoreService score) { }
}
```

---

## Diagnosing DI Failures

### `VContainerException: Unable to find type registration`

1. Check the relevant `ModuleInstaller.Install()` has `builder.Register<T>()`.
2. Check the installer asset is in `AppInstaller.asset → Modules` list.
3. Check the scope asking for the dependency can see the scope that registered
   it (parent/child relationship).

### `[Inject] method never called` on a MonoBehaviour

The MonoBehaviour is not registered:

```csharp
builder.RegisterComponentInHierarchy<MyMonoBehaviour>();
```

### `IInitializable.Initialize()` never called

Not registered with `IInitializable`:

```csharp
builder.Register<MyService>(Lifetime.Singleton)
    .As<IMyService>()
    .AsImplementedInterfaces();
```

### Circular dependency

A → B → A: extract the shared concern into a third service C, or use
`IEventBus` for the communication instead of a direct reference.

### `RegisterBuildCallback` — post-build initialization

```csharp
builder.RegisterBuildCallback(container =>
{
    EventBusAccessor.Initialize(container.Resolve<IEventBus>());
});
```

---

## Rules (Non-Negotiable)

| Rule | Why |
|------|-----|
| Always register as interface: `.As<IService>()` | Callers depend on contracts, not implementations |
| No `FindObjectOfType` / `GetComponent` for services | Breaks DI — use constructor injection |
| No static mutable state / singletons | VContainer manages lifetime |
| One `LifetimeScope` per scene | Mixing scopes causes double-registration |
| `AppScope` never changes | New modules added via installer assets only |
| Unsubscribe events in `Dispose()`, not `OnDestroy()` | VContainer disposes before Unity destroys |

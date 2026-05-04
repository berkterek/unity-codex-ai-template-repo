# Architecture Rules

## Core Principle: Dependency Direction

```
Views/Providers → Services → Models/Interfaces
       ↓               ↓
   IEventBus  (decoupled cross-system communication)
```

- Services depend on interfaces, never concrete types.
- MonoBehaviours (Views/Providers) depend on services via VContainer injection.
- Models/data classes depend on nothing.
- Cross-service communication goes through IEventBus, never direct references.
- Assembly definitions enforce direction at compile time.

---

## Layer Structure

```
_Framework/          ← No Unity dependency. Pure C# infrastructure.
  Events/            ← IEventBus, IEvent
  Logging/
  SaveLoadSystems/

_GameFolders/        ← Depends on _Framework. All game-specific code.
  Scripts/
    Games/
      Abstracts/     ← abstract classes, interfaces
      Concretes/     ← concrete implementations
      Ecs/           ← ECS DOTS systems, components, authorings
    Tests/
```

`_Framework` never references `_GameFolders`. `_GameFolders` may reference
`_Framework`.

---

## Module Structure (NON-NEGOTIABLE)

Every service/system lives in its own folder and contains exactly these files:

```
Audio/
├── IAudioService.cs       ← The only public API contract
├── AudioService.cs        ← sealed implementation
├── AudioConfiguration.cs  ← ScriptableObject config
├── AudioInstaller.cs      ← VContainer registration
└── AudioEvents.cs         ← IEvent structs for this module (if any)
```

Provider implementations live **outside** the module folder:

```
_GameFolders/Scripts/Games/Concretes/Audio/
├── BasicAudioProvider.cs  ← IAudioProvider impl (Unity API here)
└── AudioRoot.cs           ← MonoBehaviour, scene object
```

---

## VContainer for Dependency Injection

VContainer is the **only** wiring mechanism. No singletons, no static access, no
`FindObjectOfType`, no service locator.

### Scene Scope Hierarchy

```
AppScope (Bootstrap scene — DontDestroyOnLoad, persistent root)
├── MenuScope  (Menu scene — child of AppScope)
└── GameScope  (Game scene — child of AppScope)
```

- Bootstrap scene opens once (Build index 0), never returns.
- `AppScope` registers all global services (Audio, EventBus, SaveLoad…).
- `MenuScope` / `GameScope` register scene-local dependencies.
- A scope cannot access sibling scope services — only parent scope.

### ModuleInstaller Pattern

```csharp
public class AudioInstaller : ModuleInstaller
{
    [SerializeField] private AudioConfiguration _config;

    public override void Install(IContainerBuilder builder)
    {
        if (_config == null)
            throw new InvalidOperationException($"{nameof(AudioInstaller)}: _config is not assigned.");

        builder.RegisterInstance(_config);
        builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();
    }
}
```

### Interface-First Registration

```csharp
// GOOD
builder.Register<AudioService>(Lifetime.Singleton).As<IAudioService>();

// BAD — concrete dependency
builder.Register<AudioService>(Lifetime.Singleton);
```

---

## IEvent System for Communication

`IEventBus` is the **only** cross-system communication channel. No C# static
events, no UnityEvents, no direct cross-module calls.

```csharp
public struct LevelStartedEvent : IEvent { }

public struct CoinsChangedEvent : IEvent
{
    public readonly int NewAmount;
    public CoinsChangedEvent(int amount) => NewAmount = amount;
}
```

Subscribe in `Initialize()`, unsubscribe in `Dispose()`.

---

## Provider Pattern

Domain services never touch Unity API. Unity calls stay at the provider boundary:

```csharp
// Domain service — pure C#, no UnityEngine import
public sealed class AudioService : IAudioService
{
    private readonly IAudioProvider _provider;
    public AudioService(IAudioProvider provider) => _provider = provider;
    public void PlaySound(string id) => _provider.Play(id);
}
```

---

## Input System Architecture (NON-NEGOTIABLE)

Input is a View-layer concern. InputView reads raw input and calls Services.
Services never touch Unity Input directly.

```csharp
public sealed class InputView : MonoBehaviour
{
    private PlayerControls _controls;
    private IPlayerService _playerService;

    private void Awake() => _controls = new PlayerControls();

    [Inject]
    public void Construct(IPlayerService playerService) => _playerService = playerService;

    private void OnEnable()
    {
        _controls.Player.Enable();
        _controls.Player.Jump.performed += OnJump;
    }

    private void OnDisable()
    {
        _controls.Player.Jump.performed -= OnJump;
        _controls.Player.Disable();
    }

    private void Update() =>
        _playerService.SetMoveInput(_controls.Player.Move.ReadValue<Vector2>());

    private void OnJump(InputAction.CallbackContext ctx) => _playerService.Jump();
}
```

---

## ScriptableObjects for Config

All configuration data as ScriptableObjects. Runtime mutable state stays in
service/model classes.

---

## No Singletons

VContainer replaces all singleton patterns.

- App-wide → register in `AppScope`.
- Per-scene → register in `MenuScope` / `GameScope`.
- No `Instance`, no `static` mutable state, no `FindObjectOfType`.

---

## EventBusAccessor — ECS ↔ Mono Static Bridge (APPROVED EXCEPTION)

ECS systems (`ISystem`, `SystemBase`) cannot receive VContainer injection. The only
approved static accessor is `EventBusAccessor` in `_Framework/Events/`.

```csharp
public static class EventBusAccessor
{
    private static IEventBus _instance;
    public static IEventBus Instance => _instance
        ?? throw new InvalidOperationException("EventBusAccessor not initialized.");

    public static void Initialize(IEventBus bus) => _instance = bus;
}
```

Only `EventBusAccessor` is an approved static accessor — no new ones without
explicit design decision.

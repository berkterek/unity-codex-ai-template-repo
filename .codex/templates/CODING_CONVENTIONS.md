# Coding Conventions Template

This is a fillable template for project-specific coding conventions. It is not a
base `.codex` rule. Copy it into `project/CODING_CONVENTIONS.md` and fill it
according to the project's technology choices.

---

## Project Decisions

Fill this table at the start of the project.

| Karar | Seçim |
|-------|-------|
| Project name | `[PROJECT_NAME]` |
| Root namespace | `[ROOT_NAMESPACE]` |
| Runtime source root | `[RUNTIME_SOURCE_ROOT]` |
| Editor source root | `[EDITOR_SOURCE_ROOT]` |
| Test source root | `[TEST_SOURCE_ROOT]` |
| Main language/runtime | `[C# / Unity / .NET / other]` |
| DI strategy | `[VContainer / Microsoft DI / manual injection / none]` |
| Async strategy | `[UniTask / Task / coroutines / none]` |
| Event strategy | `[C# events / message bus / UnityEvent / custom event bus]` |
| Test framework | `[NUnit / xUnit / Unity Test Framework / other]` |
| Mocking policy | `[hand-written fakes / NSubstitute / Moq / none]` |
| Module structure | `[feature folders / layer folders / package folders]` |
| ECS/DOTS enabled | `[yes / no]` |

---

## Naming Conventions

### Types

```csharp
public class AudioService { }           // PascalCase
public interface IAudioService { }      // I + PascalCase
public struct PurchaseResult { }        // PascalCase
public enum ProductType { Consumable }  // PascalCase members
```

Rules:
- Classes, structs, interfaces, records, enums: `PascalCase`.
- Interfaces: `I` + `PascalCase`.
- Enum members: `PascalCase`.
- Use clear domain names; avoid vague names such as `Manager`, `Helper`, `Data`
  unless the project explicitly accepts them.

### Methods And Properties

```csharp
public void PlaySound(string id) { }
public bool IsPlaying { get; private set; }
public int Order => 100;
```

Rules:
- Methods: `PascalCase`.
- Properties: `PascalCase`.
- Public API should communicate intent without comments.

### Fields

```csharp
private IAudioService _audioService;
private bool _isInitialized;
private readonly IEventBus _eventBus;
private const int MAX_RETRY_COUNT = 3;
```

Rules:
- Private/protected fields: `_camelCase`.
- Private readonly fields: `_camelCase`.
- Constants: `SCREAMING_SNAKE_CASE`.
- Public fields are avoided by default.
- Public fields are allowed only when the project explicitly permits them for
  serializable DTO/config assets.

### Locals And Parameters

```csharp
var audioService = new AudioService();
public void Initialize(IAudioService audioService) { }
```

Rules:
- Locals: `camelCase`.
- Parameters: `camelCase`.
- Prefer names that describe role, not type repetition.

### Events

Choose one event policy per project and keep it consistent.

```csharp
public event Action OnLevelCompleted;
public event Action<int> OnScoreChanged;

public readonly struct LevelStartedEvent : IEvent { }
public readonly struct LevelWonEvent : IEvent { }
```

Rules:
- C# events: `PascalCase`, usually `On` prefix if that is the project style.
- Event/message structs: past-tense domain event + `Event` or `Message`
  suffix, e.g. `LevelStartedEvent`, `CoinsChangedMessage`.
- Avoid command-style event names such as `StartLevelEvent`.

---

## Namespace Policy

Pick one mapping rule and apply it consistently.

### Option A: Folder-Based Namespace

```text
Assets/Scripts/Framework/Events -> Framework.Events
Assets/Scripts/Game/Systems     -> Game.Systems
```

### Option B: Root Namespace + Feature

```text
Assets/Scripts/Audio -> [ROOT_NAMESPACE].Audio
Assets/Scripts/Store -> [ROOT_NAMESPACE].Store
```

Rules:
- Namespace follows the chosen project folder policy.
- Third-party libraries keep their own namespaces.
- Do not mix multiple namespace policies in one project.

---

## Script Structure

### One Primary Type Per File

```text
AudioService.cs       -> public sealed class AudioService
IAudioService.cs      -> public interface IAudioService
AudioConfiguration.cs -> public sealed class AudioConfiguration
```

Rules:
- One primary type per file.
- File name must match the primary type.
- Exceptions must be documented here, e.g. UI panel data types or generated code.

### Member Order

Use one order per project. Recommended:

```csharp
public sealed class ExampleService
{
    // Constants
    // Static readonly fields
    // Serialized/config fields
    // Private fields
    // Properties
    // Constructor
    // Lifecycle methods
    // Public methods
    // Private methods
}
```

### Region Policy

Pick one:
- `none`: no `#region`, rely on short classes.
- `large-files-only`: regions allowed for large Unity/Editor classes.
- `required`: specific project folders require standard regions.

If regions are required, use a fixed order:

```csharp
#region Fields
#endregion

#region Constructor
#endregion

#region Lifecycle
#endregion

#region Public Methods
#endregion

#region Private Methods
#endregion
```

---

## Null Checks

Rules:
- Plain C# objects may use standard C# null features:

```csharp
_eventBus?.Publish(new LevelStartedEvent(level));
_buttonStyle ??= CreateButtonStyle();
if (_provider == null) return;
```

- Unity `UnityEngine.Object` references must use Unity null checks:

```csharp
if (_target == null) return;
```

- Do not use `?.` or `is null` on Unity objects, because destroyed Unity objects
  can bypass normal C# reference checks.

---

## Async Policy

Fill this section according to the project.

### If Using UniTask

```csharp
public async UniTask InitializeAsync(CancellationToken cancellationToken)
{
    await UniTask.Delay(1000, cancellationToken: cancellationToken);
}
```

Rules:
- Runtime async methods return `UniTask` or `UniTask<T>`.
- Fire-and-forget calls must use `.Forget()`.
- `async void` is forbidden except platform-required event handlers.
- Every async operation accepts or owns a `CancellationToken`.

### If Using Task

```csharp
public async Task InitializeAsync(CancellationToken cancellationToken)
{
    await Task.Delay(1000, cancellationToken);
}
```

Rules:
- Do not block async calls with `.Result` or `.Wait()`.
- Cancellation is part of the public async contract.

---

## Dependency Injection

Choose the DI strategy per project.

Rules:
- Composition root owns object graph construction.
- Runtime services use constructor injection.
- Service locator and global mutable singletons are disallowed unless explicitly
  approved as a project exception.
- Consumers depend on interfaces when the dependency crosses module boundaries.
- Do not inject a large `GameContext`/`AppContext` object that exposes unrelated
  dependencies.

```csharp
public sealed class StoreService : IStoreService
{
    private readonly ICurrencyService _currencyService;
    private readonly IEventBus _eventBus;

    public StoreService(ICurrencyService currencyService, IEventBus eventBus)
    {
        _currencyService = currencyService;
        _eventBus = eventBus;
    }
}
```

---

## Event Subscription Lifecycle

Document the lifecycle for each class type.

| Class type | Subscribe | Unsubscribe |
|------------|-----------|-------------|
| Plain C# service | `[Initialize/constructor]` | `[Dispose]` |
| DI-managed component | `[DI lifecycle]` | `[DI lifecycle/Dispose]` |
| Unity active/passive view | `OnEnable` | `OnDisable` |
| Manually owned object | owner-controlled | owner-controlled |

Rules:
- Every subscription must have a matching unsubscribe/dispose path.
- Event handlers should be private unless an external API requires otherwise.

---

## Layer And Module Dependencies

Define allowed dependencies up front.

```text
[App/Game layer]       -> may depend on [Framework/Core]
[Framework/Core layer] -> depends on nothing project-specific
[Feature A]            -> may depend on [Feature B] only through interfaces
```

Rules:
- Framework/core code must not reference game-specific concepts.
- Modules communicate through interfaces/events/messages, not concrete classes.
- Cross-module concrete dependencies are not allowed.

---

## Portable Module Template

Use this when the project wants copy-paste portable modules.

```text
FeatureName/
├── IFeatureNameService.cs
├── FeatureNameService.cs
├── FeatureNameConfiguration.cs
├── FeatureNameInstaller.cs
└── FeatureNameEvents.cs
```

Rules:
- Interface is the public API.
- Service implementation is sealed unless inheritance is explicitly designed.
- Configuration is asset/file/env based according to project platform.
- Installer/registration is the only setup point.
- Provider/adapters that touch platform APIs live at the boundary, not in pure
  domain services.

---

## Defensive Programming

### Fail Fast For Required Configuration

```csharp
if (_config == null)
{
    throw new InvalidOperationException($"{nameof(StoreInstaller)}: config is not assigned.");
}
```

### Prefer Guard Clauses

```csharp
public void OnPointerDown(Vector2 position)
{
    if (!_isEnabled) return;
    if (_isBlocked) return;

    ProcessInput(position);
}
```

### Use Try/Finally For Guaranteed Cleanup

```csharp
ShowLoading();
try
{
    await PurchaseAsync(productId, cancellationToken);
}
finally
{
    HideLoading();
}
```

---

## Testing Conventions

Fill this section per project.

| Decision | Choice |
|----------|--------|
| Unit test framework | `[NUnit/xUnit/etc.]` |
| Integration test framework | `[UnityTest/PlayMode/etc.]` |
| Mocking | `[hand-written fakes/NSubstitute/Moq/etc.]` |
| Test location | `[TEST_SOURCE_ROOT]` |

Rules:
- Test file name: `[TestedClass]Tests.cs`.
- Test method name: `MethodName_WhenCondition_ExpectedBehavior`.
- Tests use Arrange / Act / Assert comments when the project requires them.
- Mock interfaces, not concrete classes, unless explicitly approved.
- Each test owns its setup and cleanup.

```csharp
[Test]
public void TakeDamage_WhenDamageExceedsHealth_SetsHealthToZero()
{
    // Arrange
    var eventBus = Substitute.For<IEventBus>();
    var enemy = new Enemy(health: 10, eventBus);

    // Act
    enemy.TakeDamage(999);

    // Assert
    Assert.That(enemy.Health, Is.EqualTo(0));
}
```

---

## Unity Overlay

Use this section only for Unity projects.

### Serialized Fields

Rules:
- Inspector references are private `[SerializeField]` unless the project
  explicitly permits public config fields.
- Runtime state and cached references are private non-serialized fields.
- Renamed serialized fields require `[FormerlySerializedAs]`.

```csharp
[SerializeField] private AudioRoot _audioRoot;
private bool _isInitialized;
```

### MonoBehaviour Creation

Pick one policy:
- `pool-only`: no runtime `Instantiate`; all runtime objects come from pools.
- `prefab-instantiate-allowed`: runtime `Instantiate` is allowed only from prefabs.
- `free`: standard Unity object creation is allowed.

Document the selected policy here:

```text
Runtime object policy: [pool-only / prefab-instantiate-allowed / free]
```

### Prefab Hierarchy

Recommended:
- Root GameObject owns controller/script components.
- Renderer/visual components live on child GameObjects.

```text
TowerController (root)
└── Body
    └── MeshRenderer
```

### Editor Code

Rules:
- Editor-only scripts live in `Editor/` folders or editor-only assemblies.
- Runtime assemblies cannot reference `UnityEditor`.
- If editor API is unavoidable in a runtime folder, guard it with
  `#if UNITY_EDITOR`.

---

## ECS/DOTS Overlay

Use this section only when Unity ECS/DOTS is enabled.

Rules:
- Entities are created from prefabs/authoring, not arbitrary empty entities,
  unless a project exception says otherwise.
- Each authoring type has a matching baker.
- ECS data naming is explicit and consistent:

| Type | Style | Example |
|------|-------|---------|
| Data component | PascalCase descriptive name | `HealthData` |
| Tag component | PascalCase + `Tag` | `EnemyTag` |
| Cleanup data | PascalCase + `CleanupData` | `EnemyCleanupData` |
| Managed reference | PascalCase + `Reference` | `EnemyVisualReference` |
| System | PascalCase + `System` | `EnemyMoveSystem` |
| Bridge system | PascalCase + `BridgeSystem` | `InputBridgeSystem` |

- Structural changes use `EntityCommandBuffer`.
- Burst `ISystem` hot paths use jobs where required by the selected Entities
  package version.
- Every system declares update order with `[UpdateInGroup]`,
  `[UpdateBefore]`, or `[UpdateAfter]` when ordering matters.

---

## Summary Table

| Item | Style |
|------|-------|
| Class/struct/enum | `PascalCase` |
| Interface | `I` + `PascalCase` |
| Method/property | `PascalCase` |
| Private field | `_camelCase` |
| Local/parameter | `camelCase` |
| Constant | `SCREAMING_SNAKE_CASE` |
| Test class | `[ClassName]Tests` |
| Test method | `MethodName_WhenCondition_ExpectedBehavior` |
| Event/message | past-tense + `Event` or `Message` suffix |
| File name | primary type name |


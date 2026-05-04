# C# Style — Unity Conventions

## Naming Summary

| Construct | Style | Example |
|-----------|-------|---------|
| Class, struct, enum | PascalCase | `AudioService`, `ProductType` |
| Interface | `I` + PascalCase | `IAudioService` |
| Method, property | PascalCase | `PlaySound()`, `IsPlaying` |
| Private / protected field | `_` + camelCase | `_audioService` |
| Public field (`[Serializable]` data only) | PascalCase | `SfxVolume` |
| Local variable, parameter | camelCase | `currentLevel` |
| Constant | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| `static readonly` | PascalCase | `JumpHash` |
| IEvent implementation | PascalCase + past tense + `Event` | `LevelStartedEvent` |
| ScriptableObject | PascalCase + descriptive suffix | `AudioConfiguration` |
| Installer | PascalCase + `Installer` suffix | `AudioInstaller` |
| Namespace | `<Layer>.<Module>` | `Framework.Events` |
| Test class | PascalCase + `Tests` suffix | `EnemySpawnerTests` |
| Test method | `MethodName_WhenCondition_ExpectedBehavior` | `TakeDamage_WhenZeroHealth_RaisesEvent` |
| ECS data component | PascalCase, no suffix | `HealthData` |
| ECS tag component | PascalCase + `Tag` suffix | `EnemyEntityTag` |
| ECS cleanup component | PascalCase + `CleanupData` suffix | `EnemyCleanupData` |
| ECS managed reference | PascalCase + `Reference` suffix (class) | `EnemyVisualReference` |
| ECS Authoring | PascalCase + `Authoring` suffix | `EnemyAuthoring` |

---

## Namespace Convention

Format: `<Layer>.<Module>` — underscore prefix on folder names is dropped.

| Folder | Namespace |
|--------|-----------|
| `_Framework/Events/` | `Framework.Events` |
| `_GameFolders/Scripts/Games/` | `Game` |
| `_GameFolders/Scripts/Games/Abstracts/` | `Game.Abstracts` |
| `_GameFolders/Scripts/Games/Concretes/` | `Game.Concretes` |
| `_GameFolders/Scripts/Games/Ecs/` | `Game.Ecs` |

---

## Encapsulation (NON-NEGOTIABLE)

Everything is `private` unless there is a concrete caller that requires otherwise.

- Fields: `private` by default. `[SerializeField]` only when a designer actually
  tweaks the value in Inspector.
- Methods: `public` only when another class actually calls it today.
- `sealed` by default — only unseal when inheritance is explicitly designed.

---

## Script Structure — #region (Required in `_GameFolders/Scripts/`)

Every `.cs` file under `_GameFolders/Scripts/` must use `#region` tags in this
order: `Fields`, `Constructor`, `Lifecycle`, `Public Methods`, `Private Methods`.

Exception: interface files, single-member structs/enums, and helper classes with
fewer than 3 methods do not require `#region`.

---

## Null Check Rules

```csharp
// Plain C# objects — standard C# null operators are fine
_eventBus?.Publish(new LevelStartedEvent());
if (_provider == null) return;

// Unity objects (MonoBehaviour, ScriptableObject, etc.) — MUST use == null
// Unity overrides == to detect destroyed objects; ?. and is null bypass this
if (_target == null) return;      // CORRECT
if (_target is null) return;      // WRONG — misses destroyed objects
_target?.TakeDamage(10);          // WRONG — calls method on destroyed objects
```

---

## Async Rules

### UniTask — No coroutines

```csharp
// GOOD
public async UniTask InitializeAsync(CancellationToken ct)
{
    await UniTask.Delay(1000, cancellationToken: ct);
}

// BAD — coroutine
IEnumerator Initialize() { yield return new WaitForSeconds(1f); }
```

Exception — Test Assemblies: `[UnityTest]` requires `IEnumerator` by Unity's test
runner.

### Fire-and-forget

```csharp
// GOOD
InitializeAsync(ct).Forget();

// BAD
async void Initialize() { }
```

### CancellationToken

Every async method takes a `CancellationToken`. Bind to lifecycle:

```csharp
public class StoreService : IInitializable, IDisposable
{
    private CancellationTokenSource _cts;

    public void Initialize()
    {
        _cts = new CancellationTokenSource();
        SetupAsync(_cts.Token).Forget();
    }

    public void Dispose()
    {
        _cts?.Cancel();
        _cts?.Dispose();
    }
}
```

---

## Control Flow

- Braces always, even for single-line `if`/`for`/`while`.
- Early return over deep nesting (guard clauses).
- `for` over `foreach` in hot paths (Update, FixedUpdate).
- No magic strings — use `nameof()`, `Animator.StringToHash()`,
  `Shader.PropertyToID()`.
- No LINQ in gameplay code.
- `CompareTag("tag")` not `tag == "tag"`.

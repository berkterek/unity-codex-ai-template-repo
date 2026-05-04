# Addressables Rules

## Core Rule: No Resources.Load (NON-NEGOTIABLE)

`Resources.Load` and `Resources.LoadAsync` are **forbidden**. All runtime asset
loading goes through Addressables.

```csharp
// BAD
var prefab = Resources.Load<GameObject>("Enemies/Dragon");

// GOOD
var prefab = await Addressables.LoadAssetAsync<GameObject>("Enemies/Dragon")
    .ToUniTask(cancellationToken: ct);
```

---

## Async Loading — UniTask Only

Never use `Addressables.LoadAssetAsync(...).Task` directly with `await`.

```csharp
// GOOD
var prefab = await Addressables.LoadAssetAsync<GameObject>(address)
    .ToUniTask(cancellationToken: ct);

// BAD — raw Task, no cancellation support
var prefab = await Addressables.LoadAssetAsync<GameObject>(address).Task;
```

---

## Address Management

Never hardcode address strings inline. Centralize in a static class:

```csharp
public static class AssetAddresses
{
    public const string EnemyDragon  = "Enemies/Dragon";
    public const string AudioBgMusic = "Audio/BgMusic";
}
```

---

## Handle Lifecycle — Release Is Mandatory

Every `LoadAssetAsync` handle must be released. Unreleased handles = memory leak.

```csharp
public sealed class EnemySpawnerProvider : IDisposable
{
    private AsyncOperationHandle<GameObject> _handle;

    public async UniTask LoadAsync(CancellationToken ct)
    {
        _handle = Addressables.LoadAssetAsync<GameObject>(AssetAddresses.EnemyDragon);
        await _handle.ToUniTask(cancellationToken: ct);
    }

    public void Dispose()
    {
        if (_handle.IsValid())
            Addressables.Release(_handle);
    }
}
```

Rules:
- Store handle as a field when the asset will be used over time.
- Release in `Dispose()` or when the owning scope ends.
- `Addressables.InstantiateAsync` → release with `Addressables.ReleaseInstance`,
  not `Destroy`.
- Check `handle.IsValid()` before releasing.

---

## Instantiation

```csharp
// GOOD
var instance = await Addressables.InstantiateAsync(address, parent).ToUniTask(ct);
Addressables.ReleaseInstance(instance); // NOT Destroy(instance)
```

---

## Forbidden Patterns

| Forbidden | Use Instead |
|-----------|------------|
| `Resources.Load<T>` | `Addressables.LoadAssetAsync<T>` |
| Hardcoded address strings | `AssetAddresses` constants class |
| `Destroy` on Addressables instance | `Addressables.ReleaseInstance` |
| Loading without releasing | Store handle, release in `Dispose` |
| Raw `.Task` on handles | `.ToUniTask(cancellationToken: ct)` |

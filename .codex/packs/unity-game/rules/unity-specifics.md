# Unity-Specific Rules

## Editor vs Runtime

```csharp
// Runtime code — NEVER use UnityEditor unguarded
#if UNITY_EDITOR
using UnityEditor;
#endif
```

- Code in `Editor/` folder: editor-only, excluded from builds automatically.
- Code outside `Editor/`: must guard any `UnityEditor` usage with
  `#if UNITY_EDITOR`.

---

## The `?.` Operator Trap

```csharp
// DANGEROUS — bypasses Unity's destroyed-object detection
_target?.TakeDamage(10);  // Calls TakeDamage on destroyed objects!

// SAFE
if (_target != null) { _target.TakeDamage(10); }
```

Unity overrides `==` to return `true` when comparing destroyed objects to `null`.
The `?.` operator uses C# reference equality, which does NOT detect destroyed
objects. This is the #1 most subtle Unity bug.

---

## Lifecycle Order

```
Awake()       → called once when object is created (even if disabled)
OnEnable()    → called when object becomes active
Start()       → called once before first Update (only if enabled)
FixedUpdate() → physics tick (0.02s default)
Update()      → every frame
LateUpdate()  → every frame, after all Updates
OnDisable()   → called when object becomes inactive
OnDestroy()   → called when object is destroyed
```

- Don't depend on Awake order across objects — use `[DefaultExecutionOrder]` or
  explicit init.
- `OnDisable` is called before `OnDestroy` — unsubscribe events in `OnDisable`.
- `Start` is NOT called if the object is never enabled.

---

## Threading

Unity API is main-thread only. Background threads cannot access `Transform`,
`GameObject`, `Component`, call `Instantiate`/`Destroy`, or access `Time`, `Input`,
`Physics`.

```csharp
// Return to main thread with UniTask:
await UniTask.SwitchToMainThread();
```

---

## No Coroutines — Use UniTask

Do not use `StartCoroutine` / `IEnumerator` / `yield return`.

Coroutine problems that UniTask solves:
- Coroutines stop silently when `gameObject.SetActive(false)`.
- No cancellation, error handling, or return values.
- Allocate on the heap.

Always pass `CancellationToken`. In Views:
`this.GetCancellationTokenOnDestroy()`. In Systems: own a
`CancellationTokenSource` and cancel in `Dispose()`.

---

## Time

- `Time.deltaTime` in `Update` and `LateUpdate`.
- `Time.fixedDeltaTime` in `FixedUpdate`.
- `Time.unscaledDeltaTime` for pause-independent logic (UI animations, etc.).

---

## Component Attributes

```csharp
[RequireComponent(typeof(Rigidbody))]   // Auto-adds, prevents removal
[DisallowMultipleComponent]              // Prevents duplicate components
[DefaultExecutionOrder(-100)]            // Runs before default scripts
```

---

## .meta Files

- NEVER edit manually.
- ALWAYS commit alongside their asset.
- Missing .meta = Unity regenerates GUID = all references break.

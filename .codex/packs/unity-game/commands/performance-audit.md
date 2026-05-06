# Performance Audit — Hot Path and Allocation Checker

Audits specific files or a folder for performance violations. Reports findings
with line numbers and concrete fixes. Does not auto-fix — reports first, then
waits for approval.

## Usage

```
/performance-audit <file or folder>
/performance-audit Assets/_GameFolders/Scripts/Games/Concretes/Enemy/
/performance-audit EnemyView.cs
```

If no argument is given, ask:
1. Which file(s) or folder to audit?
2. Is this a targeted audit (specific complaint) or a broad sweep?

Read every target file before reporting.

---

## Inputs To Read

Before starting, read:

- `.codex/packs/unity-game/rules/performance.md`
- `.codex/packs/unity-game/rules/unity-specifics.md`

---

## What You Check

### Allocation in Hot Paths (Update / FixedUpdate / LateUpdate)

Flag any allocation inside these methods:
- `new List<T>()`, `new T[]`, `new T()` for reference types
- `new WaitForSeconds(...)`, `new WaitUntil(...)`
- String concatenation (`+` on strings)
- LINQ: `.Where`, `.Select`, `.Any`, `.ToList`, `.ToArray`
- `foreach` on non-List collections (allocates enumerator)
- Lambda captures that allocate closure objects
- `string.Format` with non-cached format

### Caching Violations

Flag these called in Update/FixedUpdate/LateUpdate instead of cached in Awake:
- `GetComponent<T>()`
- `Camera.main`
- `Animator.StringToHash(...)` — must be `static readonly int`
- `Shader.PropertyToID(...)` — must be `static readonly int`
- `FindObjectOfType<T>()`

### Physics

Flag:
- `Physics.RaycastAll` — use `RaycastNonAlloc`
- `Physics.OverlapSphere` — use `OverlapSphereNonAlloc`
- `Physics.SphereCastAll` — use `SphereCastNonAlloc`
- Physics calls in Update — should be FixedUpdate

### Rendering

Flag:
- `renderer.material` access — clones the material, breaks batching
- Use `renderer.sharedMaterial` for read-only
- Use `MaterialPropertyBlock` for per-instance changes

### Debug

Flag:
- `Debug.Log(...)` not wrapped in `#if UNITY_EDITOR` or
  `[Conditional("UNITY_EDITOR")]`

---

## Report Format

```
FILE: Assets/_GameFolders/Scripts/Games/Concretes/Enemy/EnemyView.cs

CRITICAL — allocation in hot path:
  Line 34: new WaitForSeconds(1f) inside Update
  Fix: cache as _waitForSeconds = new WaitForSeconds(1f) in Awake

MEDIUM — caching violation:
  Line 67: GetComponent<Renderer>() inside Update
  Fix: cache in Awake as _renderer = GetComponent<Renderer>()

LOW — physics variant:
  Line 89: Physics.RaycastAll — allocates array every call
  Fix: pre-allocate RaycastHit[] _hitBuffer = new RaycastHit[16],
       use Physics.RaycastNonAlloc

CLEAN: EnemyConfig.cs, EnemyEvents.cs — no issues found
```

After the report, ask: "Apply fixes?" — do not auto-apply.

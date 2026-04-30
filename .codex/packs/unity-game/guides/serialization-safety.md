# Unity Serialization Safety Guide

Unity serialized data is easy to break silently. Use these rules before editing
MonoBehaviours, ScriptableObjects, prefabs, scenes, or serialized assets.

## Field Rename Rule

When renaming a serialized field, preserve existing data with
`FormerlySerializedAs`.

```csharp
using UnityEngine;
using UnityEngine.Serialization;

public sealed class PlayerConfig : ScriptableObject
{
    [FormerlySerializedAs("_moveSpeed")]
    [SerializeField] private float _movementSpeed;
}
```

Do not remove the attribute until the project has intentionally migrated and
resaved affected assets.

## Serialized Field Rules

- Prefer `[SerializeField] private` fields over public mutable fields.
- Keep property setters private unless runtime mutation is intentional.
- Use stable field names for data that lives in prefabs, scenes, or assets.
- Avoid changing serialized field types unless migration is planned.
- Avoid deleting serialized fields until affected assets are checked.

## Polymorphic Data

Use `[SerializeReference]` only when the project needs polymorphic serialized
data and the team accepts the inspector/tooling complexity.

For simple data, prefer ScriptableObjects, plain serializable classes, or
explicit enum-backed configs.

## Unity Null Rule

Unity objects overload null checks. For `UnityEngine.Object` references:

- Use `obj == null` when checking destroyed or missing Unity objects.
- Do not rely on null-conditional operators such as `obj?.Method()` for Unity
  object lifetime checks.

## Asset And Prefab Safety

- Prefer Unity MCP tools for serialized scene, prefab, and asset changes.
- Do not raw-edit `.unity`, `.prefab`, or serialized `.asset` files unless no
  safer route exists.
- After serialized changes, check the Unity console.
- When possible, open or validate the affected prefab, scene, or asset through
  Unity tooling.

## Review Checklist

Before finishing a Unity serialization-sensitive change:

- Renamed serialized fields have `FormerlySerializedAs`.
- Changed serialized field types are intentional and documented.
- Removed fields are safe to remove or migration is documented.
- Prefabs and ScriptableObjects still have valid references.
- Console has no new serialization, missing script, or missing reference
  errors.

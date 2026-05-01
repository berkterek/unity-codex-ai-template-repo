# Unity Guardrails

Use this checklist before and after Unity-specific changes. These are high-cost
failure areas where AI edits often cause project damage.

## Serialized Unity Files

- Do not raw-edit `.unity`, `.prefab`, or serialized `.asset` files unless the
  project explicitly requires it and no Unity tooling route exists.
- Prefer Unity MCP tools for scenes, prefabs, GameObjects, components,
  ScriptableObjects, and project settings.
- After serialized changes, check the Unity console.

## Serialized Field Renames

- Treat serialized field renames as data migration work.
- Add `FormerlySerializedAs` when renaming `[SerializeField]` fields.
- Keep migration attributes until affected assets have intentionally migrated.
- Do not change serialized field types casually.

```csharp
using UnityEngine;
using UnityEngine.Serialization;

public sealed class PlayerConfig : ScriptableObject
{
    [FormerlySerializedAs("_moveSpeed")]
    [SerializeField] private float _movementSpeed;
}
```

## Editor And Runtime Separation

- Do not use `UnityEditor` APIs in runtime assemblies.
- Put editor tooling under an `Editor/` folder or editor-only assembly.
- Runtime code must compile for the project's target platform.

## Input Boundary

- Unity input belongs in views or adapters.
- Core/domain logic should receive actions or commands, not raw input API
  details.
- Prefer the New Input System for new work unless the project overlay says
  otherwise.
- Subscribe and unsubscribe input callbacks in matching lifecycle methods.

## Scene Object Ownership

- Scene objects should not become the source of truth for rules or state.
- MonoBehaviours should render, adapt input, and bridge Unity lifecycle.
- Authoritative logic should live in testable systems where the project allows
  it.

## Asset And Reference Safety

- Preserve prefab references.
- Preserve ScriptableObject references.
- Avoid deleting or moving generated/serialized assets without checking project
  rules.
- Keep `.meta` files with Unity assets when assets are moved or added.

## Verification Checklist

Before finishing Unity work:

- Unity console checked, or inability recorded.
- Relevant scene, prefab, or asset validated.
- Serialized field migrations considered.
- Runtime/editor boundary checked.
- Input boundary checked when input changed.
- PlayMode or EditMode tests run when available and relevant.

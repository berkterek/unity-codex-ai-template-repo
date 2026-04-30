# Unity MCP Guide

Use Unity MCP when working with Unity Editor state: scenes, GameObjects,
components, prefabs, ScriptableObjects, packages, cameras, physics, UI,
graphics, builds, tests, and console verification.

## Default Workflow

1. Inspect project state before assuming Unity version, render pipeline,
   packages, scenes, or target platform.
2. Use Unity MCP tools for Unity-owned serialized data.
3. Prefer batching when performing multiple editor operations.
4. Refresh or compile after script or asset changes when needed.
5. Read the Unity console after meaningful Unity changes.
6. Run relevant EditMode or PlayMode tests when available.
7. Report anything that could not be verified.

## Batch Rule

When doing two or more Unity Editor operations, prefer `batch_execute` when the
available tools support it. This keeps setup work faster and easier to recover.

Good batch candidates:

- Creating several GameObjects.
- Adding several components.
- Configuring a prefab hierarchy.
- Creating multiple assets.
- Running repeated read-only scene inspections.

## MCP vs File Editing

| Operation | Preferred Method |
|-----------|------------------|
| Create or modify GameObjects | Unity MCP |
| Add or configure components | Unity MCP |
| Create or modify scenes | Unity MCP |
| Create or modify prefabs | Unity MCP |
| Create or modify ScriptableObject assets | Unity MCP |
| Read Unity console | Unity MCP |
| Run Unity tests | Unity MCP |
| Write C# scripts | File edit or Unity script tools |
| Edit `.asmdef` files | File edit |
| Edit `.uxml` or `.uss` files | File edit or UI tooling |
| Edit shader/HLSL source | File edit |

Avoid raw text edits to `.unity`, `.prefab`, and serialized `.asset` files
unless the project explicitly requires it and no Unity MCP route is available.

## Console Rule

After writing scripts, creating objects, or changing serialized Unity data:

1. Check the console.
2. Fix compile errors before continuing.
3. Re-check after fixes.
4. Record remaining warnings or explain why they are unrelated.

## Recovery

If a Unity MCP operation fails:

1. Read the console.
2. Inspect the target object, asset, or component.
3. Fix missing references, wrong type names, or invalid asset paths.
4. Retry the smallest failed operation.
5. If MCP remains unavailable, write an editor script or document explicit
   manual Unity Editor steps.

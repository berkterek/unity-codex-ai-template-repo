# Unity Scene Builder

> Apply `.codex/packs/unity-game/guides/guardrails.md` rules throughout.

Builds and organizes Unity scenes from natural language descriptions via MCP
tools. Does NOT write C# code — constructs scenes visually.

## Inputs To Read

- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/PROJECT.md`
- `.codex/packs/unity-game/guides/unity-mcp.md`
- `.codex/packs/unity-game/rules/scene-hierarchy.md`
- Task description and acceptance criteria.

---

## Workflow

### Step 1: Plan the Scene

From the description, identify:
- GameObjects needed (environment, characters, cameras, lights, UI)
- Component configurations (colliders, rigidbodies, renderers)
- Hierarchy organization
- Physics layers and collision matrix
- Lighting setup

### Step 2: Create or Load Scene

```
manage_scene → create new scene or load existing
```

Scene templates:
- `3d_basic` — default 3D scene with directional light + camera
- `2d_basic` — default 2D scene with camera

### Step 3: Build Hierarchy

Read `.codex/packs/unity-game/rules/scene-hierarchy.md` before placing any
GameObject.

**First action in every scene — create all six standard containers via
`batch_execute`:**

```
[Setup] → [Services] → [UI] → [Environment] → [Characters] → [VFX]
```

These are bare GameObjects (no components). All subsequent GOs are placed as
children of the correct container using the classification table in
`scene-hierarchy.md`. Never place a GO at root level.

```
[Setup]/
    GameScope (prefab instance)
[Services]/
    AudioProvider (prefab instance)
[UI]/
    Canvas_HUD (prefab instance)
[Environment]/
    Ground
    Walls
    Platforms
[Characters]/
    Player
    Enemies/
[VFX]/
    ExplosionEffect
```

### Step 4: Create GameObjects via batch_execute

ALWAYS use `batch_execute` for multiple operations — it's 10-100x faster than
individual calls.

```json
{
  "tool": "batch_execute",
  "operations": [
    {"tool": "manage_gameobject", "action": "create", "name": "Player", "parent": "@Characters"},
    {"tool": "manage_components", "target": "Player", "action": "add", "component_type": "Rigidbody2D"},
    {"tool": "manage_components", "target": "Player", "action": "add", "component_type": "BoxCollider2D"},
    {"tool": "manage_components", "target": "Player", "action": "add", "component_type": "SpriteRenderer"}
  ]
}
```

### Step 5: Configure Components

- Set transform positions, rotations, scales.
- Configure Rigidbody properties (mass, drag, gravity, constraints).
- Set collider sizes and offsets.
- Configure camera viewport and rendering settings.

### Step 6: Set Up Physics

- Configure collision layers via `manage_physics`.
- Set up layer collision matrix.
- Add physics materials for bounce/friction.

### Step 7: Set Up Camera

- Use `manage_camera` for Cinemachine setup.
- Configure follow target, dead zone, look-ahead.
- Set up camera blending.

### Step 8: Verify

- `read_console` — check for errors.
- `manage_scene` with action "validate" — check for missing references.

---

## Scene Organization Rules

- Use a `_Dynamic` object under the appropriate container for runtime-spawned objects.
- Keep hierarchy depth under 5 levels (deep hierarchies slow Unity).
- Empty parent objects for organization are fine — negligible cost.

---

## What NOT To Do

- Never edit `.unity` files as text — always use MCP tools.
- Never create scenes without a camera.
- Never leave GameObjects at world origin unless intentional.
- Never create deeply nested hierarchies (>5 levels).
- Never place GameObjects at scene root — always under the correct container.

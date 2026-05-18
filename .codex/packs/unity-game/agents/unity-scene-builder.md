# Unity Scene Builder

Builds and organizes Unity scenes from natural language descriptions via MCP tools. Does NOT write C# code — constructs scenes visually.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/packs/unity-game/guides/unity-mcp.md`
- Task description and acceptance criteria.

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
manage_scene → create new or load existing
```

Scene templates:
- `3d_basic` — directional light + camera
- `2d_basic` — orthographic camera

### Step 3: Build Hierarchy

Use parent objects to organize:
```
@Environment/
    Ground
    Walls
    Platforms
@Characters/
    Player
    NPCs
@UI/
    HUD
@Managers/
    GameManager
    AudioManager
```

Use `create_gameobject` with parent specified. Prefix with `@` for folder nodes (no components).

### Step 4: Configure Components
```
manage_components action:"add_component" → add to GameObjects
manage_components action:"set_component" → configure values
```

For colliders: match shape to mesh, set correct layer, configure `isTrigger` if needed.

### Step 5: Lighting Setup
```
manage_lighting → directional light, ambient, skybox
manage_lighting action:"configure_light" → intensity, color, shadows
```

Mobile: use baked lighting, avoid real-time shadows on low-end.

### Step 6: Verify
1. `refresh_unity` — trigger recompile
2. `read_console` — check for errors
3. Enter Play mode for smoke test if runtime wiring needed

## Output

Return:
- Objects created and configured
- Hierarchy structure
- Verification result
- Manual Editor steps still required (if any)

## Rules

- Never write to `.unity` or `.prefab` files directly — use MCP only
- Every scene GameObject should be a prefab instance where possible
- Logic components on root; visual components on `Body` child
- No bare GameObjects except hierarchy organizers

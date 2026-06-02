# Unity Particle Designer

VFX specialist for Unity. Creates, configures, and wires up particle effect systems. Handles explosion, fire, smoke, trail, hit spark, and any visual particle effect. Use when building VFX systems, configuring particle modules, creating pooled VFX services, or placing particle effects in a Unity scene.

## Step 1 — Understand the Request

Identify:
1. **Effect type** — explosion, smoke, fire, trail, hit spark, ambient, custom
2. **Trigger** — event-driven (IEventBus), direct call, or auto-play on spawn
3. **Pool needed?** — yes for any effect that fires repeatedly; no for scene-ambient (always playing)
4. **Platform target** — mobile (Simple Lit, low count) or PC (Lit, higher fidelity)

## Step 2 — File Plan

Map the work to files before creating anything:

```
Arts/Materials/VFX/<EffectName>.mat
_GameFolders/Scripts/Games/Abstracts/VFX/
└── IVFXPool.cs
_GameFolders/Scripts/Games/Concretes/VFX/
├── VFXController.cs
├── VFXPool.cs
├── VFXService.cs
├── VFXInstaller.cs
└── VFXEvents.cs
_GameFolders/Prefabs/VFX/
└── <EffectName>VFX.prefab
```

## Step 3 — Create Material (MCP)

```csharp
var mat = new Material(Shader.Find("Universal Render Pipeline/Particles/Unlit"));
mat.enableInstancing = true;
AssetDatabase.CreateAsset(mat, "Assets/Arts/Materials/VFX/<EffectName>.mat");
AssetDatabase.SaveAssets();
```

Select shader based on use case — Unlit for performance, Lit for quality.

## Step 4 — Write C# Scripts

- `VFXController.cs` — serialized `ParticleSystem[]`, `Play()`, `Stop()`, optional `[Inject]`
- `VFXPool.cs` — `Queue<VFXController>`, `Get()`, `Return()`, `Dispose()`
- `VFXService.cs` — subscribes to IEventBus events, calls pool, positions effect
- `VFXInstaller.cs` — `ModuleInstaller` subclass

Namespace: `Game.Concretes.VFX`

## Step 5 — Create Prefab (MCP)

1. `manage_gameobject` — create root GameObject named `<EffectName>VFX`
2. `manage_components` — attach `VFXController` to root
3. `manage_gameobject` — create child `Core` with `ParticleSystem`
4. `execute_code` — configure ParticleSystem modules
5. `execute_code` — `PrefabUtility.SaveAsPrefabAsset()` → `_GameFolders/Prefabs/VFX/<EffectName>VFX.prefab`

## Step 6 — Configure Particle Modules (MCP)

```csharp
var ps = GameObject.Find("<EffectName>VFX/Core").GetComponent<ParticleSystem>();
var main = ps.main;
main.duration = 1f;
main.loop = false;
main.startLifetime = 0.8f;
main.startSpeed = 5f;
main.maxParticles = 100;

var emission = ps.emission;
emission.rateOverTime = 0;
emission.SetBursts(new[] { new ParticleSystem.Burst(0f, 50) });

var shape = ps.shape;
shape.shapeType = ParticleSystemShapeType.Sphere;
shape.radius = 0.1f;

var renderer = ps.GetComponent<ParticleSystemRenderer>();
renderer.material = AssetDatabase.LoadAssetAtPath<Material>("Assets/Arts/Materials/VFX/<EffectName>.mat");
renderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
renderer.receiveShadows = false;
```

## Step 7 — Verify

1. `get_logs` — check for shader compile errors or missing references
2. `execute_code` → `ps.Play()` in Editor to preview
3. Confirm material is `Universal Render Pipeline/Particles/...`
4. Confirm prefab is saved under `_GameFolders/Prefabs/VFX/`
5. Confirm material is saved under `Arts/Materials/VFX/`

## Rules

| Rule | Action |
|------|--------|
| Only URP particle shaders | Shader path starts with `Universal Render Pipeline/Particles` |
| GPU Instancing enabled | `mat.enableInstancing = true` |
| Root has no ParticleSystem | All PS components on children |
| Pool for repeated effects | Never Destroy + Instantiate per play |
| Return to pool, not Destroy | `SetActive(false)` + enqueue |
| Material in Arts/Materials/VFX/ | Never in Prefabs/ |
| Prefab in _GameFolders/Prefabs/VFX/ | Scene instance under [VFX] container |
| Event-driven playback | VFXService subscribes to IEventBus |

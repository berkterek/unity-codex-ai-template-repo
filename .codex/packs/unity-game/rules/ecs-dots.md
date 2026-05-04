# ECS DOTS Rules

## 1. Entity Creation Rule

- Every entity is a **prefab**: defined in SubScene as Authoring GO + Baker, or
  instantiated from a prefab at runtime.
- `EntityManager.CreateEntity()` with no source prefab is **forbidden**.

---

## 2. Authoring & Baker Rule

Every entity has an **Authoring** MonoBehaviour and a matching **Baker** class.

- All inspector-configurable components are added through the Baker.
- Runtime-dependent data → added by the relevant **System**, not the Baker.

```csharp
public class EnemyAuthoring : MonoBehaviour
{
    public class Baker : Baker<EnemyAuthoring>
    {
        public override void Bake(EnemyAuthoring authoring)
        {
            var entity = GetEntity(TransformUsageFlags.Dynamic);
            AddComponent(entity, new EnemyEntityTag());
        }
    }
}
```

---

## 3. Component Naming

| Type | Rule | Example |
|------|------|---------|
| `IComponentData` (data) | PascalCase, no suffix | `HealthData`, `MoveSpeed` |
| `IComponentData` (tag) | PascalCase + `Tag` suffix | `EnemyEntityTag` |
| `IEnableableComponent` tag | Same: `Tag` suffix | `PauseStateTag` |
| `ICleanupComponentData` (value) | PascalCase + `CleanupData` suffix | `EnemyCleanupData` |
| Managed `ICleanupComponentData` (reference) | PascalCase + `Reference` suffix — **class** | `EnemyVisualReference` |
| Authoring | PascalCase + `Authoring` suffix | `EnemyAuthoring` |
| `ISystem` (Burst) | PascalCase + `System` suffix | `EnemyMoveSystem` |
| `SystemBase` (bridge) | PascalCase + `BridgeSystem` suffix | `InputBridgeSystem` |

---

## 4. Hybrid ECS ↔ OOP Linking

Use a **managed `ICleanupComponentData` class** to link an entity to its
MonoBehaviour.

```csharp
public class TowerBaseVisualReference : ICleanupComponentData
{
    public TowerBaseProvider Value;
}
```

Communication always goes through a System — the system reads the reference and
calls the MonoBehaviour method.

---

## 5. ScriptableObject → Component Transfer

At runtime, a **System** reads the SO and copies values into entity components.
The entity never holds a SO reference after init.

---

## 6. Mono ↔ ECS Communication Rule

No class talks directly to `ISystem` (preserves Burst compatibility).

| Direction | Chain |
|-----------|-------|
| Mono → ECS | `Mono class` → `SystemBase` → `ISystem` |
| ECS → Mono | `ISystem` → `SystemBase` → `Mono class` |

---

## 7. System Update Order

Every system declares its group explicitly with `[UpdateInGroup]`,
`[UpdateBefore]`, `[UpdateAfter]`.

| Order | Group | Use |
|-------|-------|-----|
| 1 | `InitializationSystemGroup` | First-time config write to entity |
| 2 | `SimulationSystemGroup` — before `TransformSystemGroup` | Movement, velocity, input |
| 3 | `SimulationSystemGroup` — after `TransformSystemGroup` | Position query, range check, attack |
| 4 | `SimulationSystemGroup` — after attack | Damage accept, health check |
| 5 | `LateSimulationSystemGroup` — before `DestroySystem` | Pre-destroy: add `ICleanupComponentData` |
| 6 | `LateSimulationSystemGroup` | Destroy entity |
| 7 | `LateSimulationSystemGroup` — after `DestroySystem` | Cleanup |

---

## 8. ISystem + IJobEntity Rule

`ISystem` (Burst-compiled) cannot use `foreach` directly. Use `IJobEntity` +
`ScheduleParallel`.

```csharp
[BurstCompile]
[UpdateInGroup(typeof(SimulationSystemGroup))]
[UpdateBefore(typeof(TransformSystemGroup))]
public partial struct EnemyMoveSystem : ISystem
{
    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var job = new MoveJob { DeltaTime = SystemAPI.Time.DeltaTime };
        state.Dependency = job.ScheduleParallel(state.Dependency);
    }

    [BurstCompile]
    [WithDisabled(typeof(PauseStateTag))]
    partial struct MoveJob : IJobEntity
    {
        public float DeltaTime;
        void Execute(ref LocalTransform t, in MoveSpeedData speed, in TargetData target)
        {
            var dir = math.normalize(target.Position - t.Position);
            t.Position += DeltaTime * speed.Value * dir;
        }
    }
}
```

---

## 9. Structural Change Rule

Entity creation, destruction, adding/removing components during query iteration
must use `EntityCommandBuffer`.

| Operation | Required method |
|-----------|----------------|
| `AddComponent`, `RemoveComponent`, `Instantiate`, `DestroyEntity` | `EntityCommandBuffer` |
| Enable / disable `IEnableableComponent` | `SystemAPI.SetComponentEnabled` |
| Data update only | Direct write is fine |

Always call `ecb.Playback(EntityManager)` and `ecb.Dispose()`.

---

## 10. Folder Structure

```
_GameFolders/Scripts/Games/Ecs/
├── Authorings/    ← Authoring MonoBehaviours + Baker inner classes
├── Components/    ← IComponentData structs, tag components
└── Systems/       ← ISystem, SystemBase, bridge systems
```

ECS code never goes into `Abstracts/` or `Concretes/`.

# Testing Rules

## Mandatory TDD

Every class under `_GameFolders/Scripts/` must have a corresponding test.
Rule: **write test first, then implementation**.

---

## Test Types

| Type | Assembly | When |
|------|----------|------|
| **Edit Mode** | `[Project]Tests` | Pure C# logic, interface mocking, ECS component tests |
| **Play Mode** | `[Project]PlayTests` | MonoBehaviour lifecycle, ECS World + System integration |

---

## What Requires Tests

| Folder | Test Type | Tool |
|--------|-----------|------|
| `Games/Abstracts/` | Edit Mode | NUnit + NSubstitute |
| `Games/Concretes/` | Edit Mode | NUnit + NSubstitute |
| `Games/Ecs/Systems/` | Play Mode | NUnit + ECS World |
| `Games/Ecs/Components/` | — | Data struct — no test needed |
| `Games/Ecs/Authorings/` | — | Baker bake-time — no test needed |

---

## Assembly Definition Setup

```json
// [Project]Tests.asmdef  (Edit Mode — includePlatforms: ["Editor"])
{
    "name": "[Project]Tests",
    "references": ["UnityEngine.TestRunner", "UnityEditor.TestRunner", "[Project]Games"],
    "overrideReferences": true,
    "precompiledReferences": ["nunit.framework.dll", "NSubstitute.dll"],
    "defineConstraints": ["UNITY_INCLUDE_TESTS"]
}
```

NSubstitute cannot be installed via Package Manager. Place `NSubstitute.dll`
manually in `Assets/Plugins/NSubstitute/` and reference via
`precompiledReferences` with `overrideReferences: true`.

---

## Test File Location and Naming

```
_GameFolders/Scripts/
├── Games/
│   └── Concretes/
│       └── EnemySpawner.cs
└── Tests/
    ├── [Project]Tests/
    │   └── EnemySpawnerTests.cs
    └── [Project]PlayTests/
        └── EnemyMoveSystemTests.cs
```

Rule: `[TestedClass]Tests.cs` — one test file per tested class.

---

## Test Method Naming

```
MethodName_WhenCondition_ExpectedBehavior
```

```csharp
[Test] public void TakeDamage_WhenHealthIsZero_RaisesOnDeathEvent() { }
[Test] public void Spawn_WhenPoolIsEmpty_ThrowsInvalidOperationException() { }
```

---

## AAA Pattern (Mandatory)

```csharp
[Test]
public void TakeDamage_WhenDamageExceedsHealth_SetsHealthToZero()
{
    // Arrange
    var eventBus = Substitute.For<IEventBus>();
    var enemy = new ConcreteEnemy(health: 10, eventBus);

    // Act
    enemy.TakeDamage(999);

    // Assert
    Assert.AreEqual(0, enemy.Health);
}
```

---

## NSubstitute Rules

**Only interfaces are mocked.**

```csharp
// GOOD
var eventBus = Substitute.For<IEventBus>();

// BAD — concrete mock
var service = Substitute.For<EnemySpawner>();
```

### Call Verification

```csharp
eventBus.Received(1).Publish(Arg.Any<EnemyDiedEvent>());
eventBus.DidNotReceive().Publish(Arg.Any<LevelWonEvent>());
```

---

## ECS System Tests (Play Mode)

Create an isolated `World` per test — never use
`World.DefaultGameObjectInjectionWorld`.

```csharp
[UnityTest]
public IEnumerator EnemyMoveSystem_WhenMoveInputSet_UpdatesTranslation()
{
    var world  = World.CreateWorld("TestWorld");
    var system = world.GetOrCreateSystemManaged<EnemyMoveSystem>();
    var entity = world.EntityManager.CreateEntity(
        typeof(EnemyEntityTag), typeof(MoveInput), typeof(LocalTransform));

    world.Update();
    yield return null;

    var transform = world.EntityManager.GetComponentData<LocalTransform>(entity);
    Assert.AreNotEqual(float3.zero, transform.Position);
    world.Dispose();
}
```

---

## Sample Test Templates

Keep `SampleEditModeTests.cs` and `SamplePlayModeTests.cs` in the test assemblies.
Delete Unity's auto-generated scaffold files immediately.

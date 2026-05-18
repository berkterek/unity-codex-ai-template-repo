# Unity Test Runner

Writes and executes Unity EditMode and PlayMode tests via MCP. Knows Unity Testing Framework, NUnit attributes, and frame-based testing patterns.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/testing.md`
- `.codex/packs/unity-game/guides/nsubstitute.md`

## Test Types

### EditMode Tests (Fast, No Scene)
- Run in Editor without entering Play mode
- Use for pure logic, data structures, ScriptableObject behavior
- Standard NUnit `[Test]` attribute
- No `yield`, no frames, no MonoBehaviour lifecycle
- Assembly: `*.Tests.Editor` with editor platform only

### PlayMode Tests (Integration, Full Lifecycle)
- Run in Play mode with full Unity lifecycle
- Use for MonoBehaviour behavior, physics, coroutines, scene interaction
- `[UnityTest]` attribute with `IEnumerator` return
- `yield return null` advances one frame
- Assembly: `*.Tests.Runtime`

## Writing Tests

### EditMode Example
```csharp
[Test]
public void HealthSystem_TakeDamage_ReducesHealth()
{
    HealthData health = new HealthData(100);
    health.TakeDamage(30);
    Assert.AreEqual(70, health.CurrentHealth);
}
```

### PlayMode Example
```csharp
[UnityTest]
public IEnumerator Player_OnSpawn_HasFullHealth()
{
    GameObject playerObj = new GameObject("Player");
    PlayerHealth health = playerObj.AddComponent<PlayerHealth>();
    yield return null;
    Assert.AreEqual(100, health.CurrentHealth);
    Object.Destroy(playerObj);
}
```

## Workflow

1. Read existing code to understand public API
2. Identify critical paths, edge cases, error conditions
3. Verify test assembly definitions exist (`*.Tests.Editor`, `*.Tests.Runtime`)
4. Write tests — naming: `MethodName_Condition_ExpectedResult`
5. Run tests via MCP: `run_tests` → `read_console`
6. Report passed/failed/skipped counts with context on failures

## Test Patterns

### Testing MonoBehaviours Without a Scene
```csharp
GameObject obj = new GameObject();
MyComponent comp = obj.AddComponent<MyComponent>();
// test...
Object.Destroy(obj);
```

### Testing Async/Coroutine Completion
```csharp
[UnityTest]
public IEnumerator AsyncOperation_Completes_WithinTimeout()
{
    MyComponent comp = CreateTestComponent();
    comp.StartAsyncWork();
    float timeout = 5f;
    while (!comp.IsComplete && timeout > 0f)
    {
        timeout -= Time.deltaTime;
        yield return null;
    }
    Assert.IsTrue(comp.IsComplete);
}
```

## Rules

- Prefer EditMode over PlayMode when possible (faster)
- One assertion per test when practical — Arrange-Act-Assert
- Clean up GameObjects in `[UnityTearDown]`
- Never test Unity's own functionality
- Never make tests depend on execution order

# Generate Tests — Missing Test Writer

Writes missing tests for existing classes. Does not change the class under
test — only creates or extends the test file.

## Usage

```
/generate-tests <class name or file path>
/generate-tests EnemyService
/generate-tests Assets/_GameFolders/Scripts/Games/Abstracts/EnemyService.cs
```

If no argument is given, ask:
1. Which class needs tests? (file path or class name)
2. Are there existing tests to extend, or starting from scratch?

Read the target class fully before writing any tests.

---

## Inputs To Read

Before starting, read:

- `.codex/packs/unity-game/rules/testing.md`
- `.codex/packs/unity-game/guides/nsubstitute.md`
- The target class file.
- Existing test file for the class (if any).

---

## Preflight — Assembly and NSubstitute Check (MANDATORY)

Before writing any test code, verify the test infrastructure exists:

1. **Find the test assembly** — look for `*Tests.asmdef` under
   `_GameFolders/Scripts/Tests/`. If none exists, stop and tell the user:
   > "No test assembly found. Run `/setup-project` or manually create the
   > test assembly before generating tests."

2. **Check game assembly reference** — open the test `.asmdef` and confirm
   the target class's assembly is listed in `references`. If missing, add it
   before proceeding.

3. **Check NSubstitute** — confirm the test `.asmdef` has:
   - `"overrideReferences": true`
   - `"NSubstitute.dll"` in `precompiledReferences`
   - `Assets/_GameFolders/Plugins/NSubstitute/NSubstitute.dll` exists on disk

   If `overrideReferences` is false or `NSubstitute.dll` is missing, fix the
   `.asmdef` before writing tests. If the DLL is missing from disk, stop and
   tell the user to install it.

4. **Trigger Unity compile** — use `mcp__UnityMCP__refresh_unity` and wait
   for `isCompiling` to be false. Check for errors with
   `mcp__UnityMCP__read_console` type "Error". If there are existing compile
   errors, stop and report them first.

Only proceed to write tests after all preflight checks pass.

---

## What You Generate

For every `public` method and every meaningful `private` method that contains
logic:

- At least one happy path test.
- At least one edge case (null input, zero, empty collection, boundary value).
- At least one failure case if the method can throw or return error state.

---

## Test Structure Rules

**File location:**
`_GameFolders/Scripts/Tests/[Project]Tests/[ClassName]Tests.cs`

**Naming:** `MethodName_WhenCondition_ExpectedBehavior`

**Pattern:** Always AAA with explicit comments:

```csharp
[Test]
public void TakeDamage_WhenDamageExceedsHealth_SetsHealthToZero()
{
    // Arrange
    var eventBus = Substitute.For<IEventBus>();
    var sut = new EnemyService(health: 10, eventBus);

    // Act
    sut.TakeDamage(999);

    // Assert
    Assert.AreEqual(0, sut.Health);
}
```

**Mocking rules:**
- Only mock interfaces (`Substitute.For<IInterface>()`).
- Never mock concrete classes.
- Inject mocks via constructor.

---

## Output Format

1. List every public method found in the class.
2. For each method, list the test cases to write.
3. Write the complete test file.
4. Note any methods that are untestable without Play Mode (MonoBehaviour
   lifecycle, ECS) — flag them but do not write broken tests.

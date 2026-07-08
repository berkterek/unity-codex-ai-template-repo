# Unity Guardrails

Codex has no hook mechanism. This file is the **model-level equivalent** of the
rules that older hook-based workflows enforced automatically. Every agent and command
must internalize this list.

Executable enforcement for the highest-value checks lives at:

```bash
bash .codex/guardrails/run.sh --changed
bash .codex/guardrails/run.sh --staged
bash .codex/guardrails/run.sh --files Assets/Scripts/Foo.cs
```

`BLOCK` findings exit `1`. `WARN` findings exit `0` but must be reported.

Rules have three levels:
- **BLOCK** — never do this; automatic FAIL
- **WARN** — flag it, report to reviewer, then continue
- **GATE** — verify the condition before proceeding

---

## BLOCK — Hard Stop

### Never run git push
The user always pushes manually. Never run `git push`.

### Never text-edit .unity / .prefab / .asset files
These files contain YAML-serialized binary references. Text edits break
references silently. For scene, prefab, and asset changes use **MCP tools only**:
`manage_scene`, `manage_gameobject`, `manage_components`, `manage_build`.

### Never create bare runtime GameObjects
`new GameObject(...)` is forbidden in runtime C#. Every runtime object must come
from a prefab-backed path such as pooled prefab instances or Addressables.

### Never use UnityEvent
`UnityEvent`, `UnityEvent<T>`, `[SerializeField] UnityEvent` — forbidden in
runtime C#. Use `IEventBus`.

### Never assign Time.timeScale directly
`Time.timeScale = 0` or any assignment is forbidden. Pause/resume must go
through `IEventBus + PauseService`.

### Never use static singleton pattern
`static Instance`, `static _instance` — forbidden. VContainer is the only DI
mechanism. Exception: `EventBusAccessor` (approved static bridge for ECS ↔ Mono
communication).

### Never put business logic in MonoBehaviour
MonoBehaviour classes are limited to View or Provider roles. They may read
input, update UI, trigger animation, or wrap Unity APIs, but they must not own
business logic, scoring, state orchestration, event publishing, or service
coordination. Move that work to injected services.

### Never instantiate services or providers directly
`new SomeService()` and `new SomeProvider()` are forbidden in runtime code.
Dependencies must be registered through VContainer and injected by interface.

### Restrict handler construction
`new SomeHandler()` is only allowed inside the owning `*Controller` or `*View`
shell. Handlers are prefab-local pure C# objects and must not be constructed by
unrelated services.

### Never depend on concrete services in constructors
Service constructors must accept interfaces, not concrete service classes. This
keeps modules replaceable, testable, and aligned with DIP.

### Never use UnityEditor namespace without #if UNITY_EDITOR
`using UnityEditor` or any `UnityEditor.*` call in a runtime assembly is
forbidden. Without the `#if UNITY_EDITOR` guard the player build will fail to
compile.

### Never modify critical architecture files without reading dependencies first
`AppScope`, `InputService`, `AppModules`, `ConfigCatalog`, `.asmdef`,
`EventBus` files must not be modified before reading their dependents. Use
`Read` + `Grep` to map the impact area first.

### Never weaken config files to work around code problems
`.asmdef`, `.inputactions`, `ProjectSettings/`, `Packages/manifest.json`, and
`Packages/packages-lock.json` — fix the code, not the config. Test assembly
`.asmdef` files are the narrow exception.

### Never put Unity object inheritance in service/domain files
Files under `_Framework/`, `Games/Abstracts`, `Games/Concretes`,
`Game/Abstracts`, and `Game/Concretes` must not inherit `MonoBehaviour` or
`ScriptableObject` unless they are approved Unity boundary files:
`*Provider`, `*View`, `*Controller`, `*Scope`, `*Configuration`, `*Config`,
`*Catalog`, or `*Definition`.

### Never make handlers MonoBehaviours
`*Handler : MonoBehaviour` is forbidden. Handlers are pure C#.

### Never make modules ScriptableObjects
`*Module : ScriptableObject` is forbidden. Modules are static classes with an
`Install(IContainerBuilder builder, Config config)` method.

### ECS/IEvent enums must use byte backing
Enums inside ECS components or `IEvent` structs must have a `byte` base type:
`enum State : byte`.

---

## WARN — Flag and Continue

### async void
`async void` is forbidden outside Unity lifecycle methods (`Awake`, `Start`,
`OnEnable`, `OnDisable`, `OnDestroy`). Use `async UniTask` + `.Forget()`.
Lifecycle methods are exempt because Unity forces the void return type.

### GetComponent in Awake
`GetComponent<T>()`, `GetComponentInChildren<T>()` should not be called in
`Awake`. Components on the same GameObject or its children should be assigned
via `[SerializeField]` in the Inspector — zero runtime cost, dependency visible
at edit time.

### Input System violations
- Legacy API forbidden: `Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.mousePosition`
- `InputAction` must be enabled/disabled in `OnEnable`/`OnDisable`
- Every `+=` subscription must have a matching `-=` unsubscription
- Reading input in `FixedUpdate` is forbidden — use `Update`
- Systems must be input-agnostic: expose `SetMoveInput(Vector2)`, `Jump()`, etc.

### Namespace format
`Layer.Module` format required: `Framework.Events`, `Game.Abstracts`,
`Game.Concretes`, `Game.Ecs`. Single-segment namespaces trigger a warning.

### Naming convention violations
- Types, methods, properties: `PascalCase`
- Private fields: `_camelCase`
- Parameters, locals: `camelCase`
- Interfaces: `I` prefix
- IEvent structs: `Event` suffix (e.g. `LevelStartedEvent`)

### SOLID/OOP violations
- A class responsibility that needs `and` to describe should be split.
- Long MonoBehaviours above ~100 lines usually indicate mixed View/Provider/service responsibilities.
- Type-check `if`/`else if` chains for behavior should become polymorphism.

### Hot path expensive calls
Inside `Update`, `FixedUpdate`, `LateUpdate`, `Tick`, `FixedTick`, `LateTick`:
- `GetComponent`, `Camera.main`, `FindObjectOfType`, `FindObjectsOfType`
- `tag == "..."` (use `CompareTag`)
- `SendMessage`, `BroadcastMessage`
- Uncached `transform` property access

### LINQ in hot paths
Do not use LINQ inside `Update` / `FixedUpdate` / `LateUpdate` — it allocates.

### Runtime Destroy
`Destroy(...)` outside Pool, Manager, or Spawner files should be flagged. If an
object is pool-managed, call the pool return path instead.

### Null propagation on Unity objects
Do not use `?.` or `??` on `MonoBehaviour`, `Component`, or `ScriptableObject`.
Unity overrides `== null` to detect destroyed objects; C# reference equality
will call methods on a destroyed object — the most common subtle Unity bug.

### UnityEngine import in pure C# services
`using UnityEngine` is forbidden in `_Framework/`, `Game/Abstracts/`,
`Game/Concretes/` pure service/domain files. Boundary exceptions:
`*Provider`, `*View`, `*Controller`, `*Scope`, `*Configuration`, `*Config`,
`*Catalog`, `*Definition`, and event payload files when Unity value types are
intentional.

### ECS structural changes inside a query loop
`EntityManager.AddComponent`, `RemoveComponent`, `DestroyEntity`, `Instantiate`
are forbidden inside a query loop. Use `EntityCommandBuffer`.

### UniTask missing CancellationToken
`async UniTask` methods must accept a `CancellationToken` parameter. Exempt:
override methods, Unity lifecycle wrappers, private helpers under 5 lines.

### Unused code
Unused private members, unused `using` directives, unused parameters — flag
and report to the reviewer.

### File name / class name mismatch
C# file name must match the primary class or struct name. Mandatory for
MonoBehaviour and ScriptableObject; apply the same rule to all other types.

### SerializeField rename without FormerlySerializedAs
When renaming a `[SerializeField]` field, add `[FormerlySerializedAs("oldName")]`.
Without it every configured value in every scene and prefab will silently reset
to the default.

### Missing test file
If a logic C# file has no corresponding test file under `Tests/`, warn.

### Missing PlayMode test scene
If a PlayMode test file references a scene, that scene must exist under
`_Scenes/TestScenes/`.

---

## GATE — Verify Before Proceeding

### Director Gate
Pipeline agents (coder, tester, committer) must not be spawned until the
Director Gate has been shown and the user has typed `go`. The pipeline does not
start without the gate.

### Reviewer order
The reviewer in this project is `unity-reviewer`. Call `unity-reviewer` to
review code when subagents are authorized; otherwise perform and report local
review. Review is required before every commit.

### Gate cleared state
Check `.codex/project/PROGRESS.md` or task notes to verify that the current
pipeline phase has been completed before moving to the next.

---

## Verification Checklist (After Every C# Write)

- [ ] Unity console checked (MCP: `read_console` errors)
- [ ] No compilation errors (`refresh_unity` + `read_console`)
- [ ] `FormerlySerializedAs` added if a SerializeField was renamed
- [ ] Runtime/editor boundary preserved
- [ ] Input boundary preserved (if input was touched)
- [ ] No singletons or static mutable state
- [ ] No allocations in hot paths
- [ ] Test file exists or NoTest decision recorded

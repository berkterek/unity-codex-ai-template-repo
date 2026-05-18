# Unity Guardrails

Codex has no hook mechanism. This file is the **model-level equivalent** of all
rules that Claude Code enforces automatically via hooks. Every agent and command
must internalize this list.

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

### Never use UnityEditor namespace without #if UNITY_EDITOR
`using UnityEditor` or any `UnityEditor.*` call in a runtime assembly is
forbidden. Without the `#if UNITY_EDITOR` guard the player build will fail to
compile.

### Never modify critical architecture files without reading dependencies first
`AppScope`, `InputView`, `ModuleInstaller`, `AppInstaller`, `.asmdef`,
`EventBus` files must not be modified before reading their dependents. Use
`Read` + `Grep` to map the impact area first.

### Never weaken config files to work around code problems
`.asmdef`, `settings.json`, `.inputactions`, `ProjectSettings/` — fix the code,
not the config.

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

### Hot path expensive calls
Inside `Update`, `FixedUpdate`, `LateUpdate`, `Tick`, `FixedTick`, `LateTick`:
- `GetComponent`, `Camera.main`, `FindObjectOfType`, `FindObjectsOfType`
- `tag == "..."` (use `CompareTag`)
- `SendMessage`, `BroadcastMessage`
- Uncached `transform` property access

### LINQ in hot paths
Do not use LINQ inside `Update` / `FixedUpdate` / `LateUpdate` — it allocates.

### Runtime Instantiate
`GameObject.Instantiate` at runtime is forbidden. Use an object pool.

### Null propagation on Unity objects
Do not use `?.` or `??` on `MonoBehaviour`, `Component`, or `ScriptableObject`.
Unity overrides `== null` to detect destroyed objects; C# reference equality
will call methods on a destroyed object — the most common subtle Unity bug.

### UnityEngine import in pure C# services
`using UnityEngine` is forbidden in `_Framework/`, `Game/Abstracts/`,
`Game/Concretes/` (except provider classes).

### ECS structural changes inside a query loop
`EntityManager.AddComponent`, `RemoveComponent`, `DestroyEntity`, `Instantiate`
are forbidden inside a query loop. Use `EntityCommandBuffer`.

### ECS enum missing byte base
Enums inside ECS components or `IEvent` structs must have a `byte` base type:
`enum State : byte`.

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
The reviewer in this project is **Claude** (`unity-reviewer`). Call
`unity-reviewer` to review code. Review is required before every commit.

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

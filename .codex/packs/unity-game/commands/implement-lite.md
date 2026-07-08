# Implement Lite — Lightweight Single-Class Implementation

Fast pipeline for simple, single-class additions or changes. No test writer, no reviewer, no verifier.
`/implement` auto-routes here when complexity score < 0.3 — can also be called directly.

## Usage

```
/implement-lite "add _jumpForce [SerializeField] to PlayerController"
/implement-lite "implement IDisposable on AudioService, cancel CancellationTokenSource in Dispose"
/implement-lite "add OnHealthChanged C# event to HealthService"
```

## When to use

| Situation | Command |
|-----------|---------|
| Single class, no new interface, no DI wiring, no events | `/implement-lite` |
| 2–4 classes, new interface, or touches EventBus | `/implement` |
| New module folder, cross-system, ECS, Addressables | `/implement` (full pipeline) |

## Scope Check — Escalate if Any Are True

- Creating a new module folder
- Adding or modifying a new `IEventBus` event
- Modifying `AppScope`, `AppModules`, `ConfigCatalog`, `GameScope`, or any static Module
- Touching more than 2 files

```
This task exceeds /implement-lite scope.
→ Continue with /implement instead? (go / try implement-lite anyway)
```

## Step 1 — Read Target Files

Read only the file(s) directly involved in the task. No codebase scanning.

## Step 2 — unity-coder-lite

Spawn **unity-coder-lite** agent with this prompt:

```
TASK: Single-class targeted implementation.

FILE(S): <file path(s)>
TASK: <user's description>

Implement only what is described. Do not refactor surrounding code.
Do not read files beyond what was provided.

PROJECT RULES (non-negotiable):
- VContainer injection — no singletons, no FindObjectOfType
- UniTask — no coroutines, no async Task
- New Input System — no Input.GetKey / Input.GetAxis
- Unity null check: == null, not is null or ?.
- [SerializeField] for component references — not GetComponent in Awake
- sealed classes by default
- _camelCase private fields, PascalCase types and methods
```

## Step 3 — Compile Check

If MCP is connected → `read_console` to verify no compile errors.
If MCP is not connected → ask user: "Any errors in Unity?"

If errors remain → return to unity-coder-lite (max 2 iterations).
Still failing after 2 iterations:
```
implement-lite could not resolve compile errors.
→ Continue with /implement for a full validator loop? (go / stop)
```

## Step 4 — Committer

Run **committer** agent. Commit message format: `feat(<scope>): <what was added>`

## Output Format

```
IMPLEMENTED: <file(s)>
TASK: <what was asked>
CHANGE: <what was added or modified>
COMPILE: clean
```

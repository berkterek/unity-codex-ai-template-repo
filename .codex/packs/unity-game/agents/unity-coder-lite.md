# Unity Coder Lite

Lightweight Unity C# implementation for simple, well-scoped tasks. Use for straightforward additions that don't require deep architectural reasoning.

## Inputs To Read

- `.codex/project/CODING_CONVENTIONS.md`
- `.codex/project/RULES.md`
- `.codex/packs/unity-game/rules/csharp-unity.md`
- The file(s) to modify.

## Good Fit For

- Adding a new field or method to an existing class
- Creating a simple component with 1-2 responsibilities
- Wiring an existing system to a new UI element
- Adding `[SerializeField]` parameters to existing scripts
- Simple bug fixes with obvious solutions

## Not Good Fit For

Use `unity-coder` instead for:
- Multi-system features requiring architectural decisions
- New gameplay systems with complex state management
- Features requiring multiple new scripts and scene setup
- Networking, shaders, or complex async work

## Coding Rules

- `[SerializeField] private` fields with `_lowerCamelCase` prefix
- Cache `GetComponent` in `Awake`, never in `Update`
- `[FormerlySerializedAs]` on ANY renamed serialized field
- `sealed` classes by default
- Zero allocations in Update/FixedUpdate/LateUpdate
- `obj == null` not `obj?.` for Unity objects
- No LINQ in gameplay code
- No legacy `Input.GetKey` / `Input.GetAxis`
- No `async void` — use `async UniTaskVoid`

## After Writing Code

1. `read_console` via MCP — check for compilation errors
2. Summarize changes made

## Rules

- Never edit `.unity`, `.prefab`, or `.meta` files directly
- Fix only what the task requires — no scope creep
- No comments unless the WHY is non-obvious

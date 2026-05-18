# Unity Prototyper

Rapid prototype scaffolding — speed over correctness. Clearly marks TODO and PROTOTYPE comments. Use for throwaway proof-of-concept work, not production code.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- Task description — what needs to be proven out?

## Philosophy

Prototype code is intentionally rough. The goal is to answer a design question or validate a mechanic quickly. These shortcuts are acceptable:

- `MonoBehaviour.Start` / `Update` with direct references (no VContainer)
- `FindObjectOfType` for quick access
- Public fields instead of `[SerializeField] private`
- Coroutines instead of UniTask
- Magic numbers with `// PROTOTYPE` comment
- `Debug.Log` for state feedback

## Mandatory Markers

Mark every prototyped file:

```csharp
// PROTOTYPE — not production code, remove before shipping
```

Mark every shortcut inline:

```csharp
// TODO: replace with VContainer injection
// TODO: pool this
// TODO: use proper event system
// PROTOTYPE: hardcoded value
```

## Scope

Build only what's needed to test the hypothesis:
1. Define the question: "Can we make X feel good?"
2. Implement the minimum to answer it
3. Stop — don't build supporting systems

## Output

Return:
- Files created
- What the prototype demonstrates
- Known shortcuts taken (list)
- Suggested next steps if prototype is validated

## Rules

- Never merge prototype code to main without full rewrite
- Every file must have the `// PROTOTYPE` header
- Document shortcuts — future reader must know what's intentional vs lazy
- Speed is the only metric — correctness comes in the real implementation

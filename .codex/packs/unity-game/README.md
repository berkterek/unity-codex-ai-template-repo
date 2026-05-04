# Unity Game Pack

Reusable Unity-specific guidance for the Codex workflow template.

This pack should stay small. It contains guidance that is broadly useful for
most Unity projects, not full gameplay implementations or genre recipes.

## Included Agents

Agents are orchestration role templates — the orchestrator spawns them for
specific task types.

| Agent | Purpose |
|-------|---------|
| `agents/unity-setup.md` | Unity Editor, scene, prefab, asset, and runtime setup tasks. |

## Included Commands

Commands are directly invocable prompts — use them as the starting prompt for
a Codex session or as instructions in a task assignment.

| Command | Purpose |
|---------|---------|
| `commands/game-idea.md` | Refines a raw game idea into a production-ready GDD. |
| `commands/architect.md` | Produces a TDD from a GDD following project standards. |
| `commands/add-feature.md` | Incrementally updates pipeline docs for a new feature. |
| `commands/new-module.md` | Generates the standard 5-file module structure. |
| `commands/review-code.md` | Manual code review against architecture and style rules. |
| `commands/clean-slop.md` | Removes AI-generated bloat — dead code, needless abstractions. |
| `commands/refine-gdd.md` | Iterates on an existing GDD. |
| `commands/refine-tdd.md` | Iterates on an existing TDD. |
| `commands/catch-up.md` | Generates a codebase comprehension guide for human developers. |
| `commands/learn.md` | Extracts project-specific patterns from completed work. |
| `commands/debugger.md` | Root cause analysis — runtime exceptions, ECS, VContainer bugs. |
| `commands/migrator.md` | Legacy pattern modernizer (coroutines → UniTask, singletons → VContainer, etc.). |
| `commands/silent-failure-hunter.md` | Audits C# files for silent error patterns. |

## Included Guides

| Guide | Purpose |
|-------|---------|
| `guides/guardrails.md` | Unity high-risk change checklist. |
| `guides/unity-mcp.md` | Unity MCP usage rules and verification loop. |
| `guides/input-system.md` | New Input System default guidance. |
| `guides/serialization-safety.md` | Unity serialized data safety rules. |

## Included Rules

| Rule | Purpose |
|------|---------|
| `rules/architecture.md` | Dependency direction, VContainer, IEventBus, module structure. |
| `rules/csharp-unity.md` | Naming, async, encapsulation, null checks, control flow. |
| `rules/performance.md` | Zero-allocation hot paths, caching, batching, draw calls. |
| `rules/ecs-dots.md` | ECS authoring, component naming, system order, structural changes. |
| `rules/testing.md` | TDD mandate, test types, NSubstitute, ECS play mode tests. |
| `rules/addressables.md` | Asset loading, handle lifecycle, address management. |
| `rules/unity-specifics.md` | Editor/runtime boundary, lifecycle order, threading, .meta files. |

## What Belongs Here

- Unity Editor automation rules.
- Scene, prefab, asset, and component safety.
- Unity MCP workflow.
- Unity serialization safety.
- Unity high-risk change guardrails.
- Default input system policy.
- Generic validation and console-check expectations.

## What Does Not Belong Here

- One project's folder names, scene names, or architecture decisions.
- Full genre implementations such as card games, RPGs, match-3, or tower
  defense.
- Third-party package rules unless the template requires that package by
  default.
- Long code-heavy references that should be optional per project.

Project-specific Unity details belong in `.codex/project/`.

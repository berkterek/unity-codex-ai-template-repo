# Unity Game Pack

Reusable Unity-specific guidance for the Codex workflow template.

This pack should stay small. It contains guidance that is broadly useful for
most Unity projects, not full gameplay implementations or genre recipes.

## Included Guides

| Guide | Purpose |
|-------|---------|
| `agents/unity-setup.md` | Unity Editor, scene, prefab, asset, and runtime setup agent. |
| `guides/guardrails.md` | Unity high-risk change checklist. |
| `guides/unity-mcp.md` | Unity MCP usage rules and verification loop. |
| `guides/input-system.md` | New Input System default guidance. |
| `guides/serialization-safety.md` | Unity serialized data safety rules. |

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

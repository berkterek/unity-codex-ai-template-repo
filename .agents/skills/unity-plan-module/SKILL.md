---
name: unity-plan-module
description: "Use when the user asks to run the repository unity command plan-module, /plan-module, or the Just-In-Time Module Planner workflow."
---

# Plan Module — Just-In-Time Module Planner

This skill is a Codex-native wrapper for the repository command file:

`.codex/packs/unity-game/commands/plan-module.md`

## Workflow

1. Read `AGENTS.md`.
2. Read `.codex/packs/unity-game/guides/guardrails.md`.
3. Read `.codex/project/PROJECT.md` and `.codex/project/RULES.md` when they exist.
4. Read the canonical command file above completely.
5. Execute the command file as the source of truth for this workflow.
6. If the command delegates to agents, prefer native Codex subagents from `.codex/agents/*.toml` and keep write scopes disjoint.

## Inputs

Use the user prompt as the command arguments. If required inputs are missing and
cannot be inferred from repository context, ask one concise question before
proceeding.

## Guardrails

- Never run `git push`.
- Never text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files.
- Use Unity MCP tools for Unity scene, prefab, component, asset, build, and editor operations.
- Do not revert user or other agent changes unless explicitly requested.

## Output

Return the output shape required by the canonical command file. Include created
plan files, verification performed, and blockers or residual risks.

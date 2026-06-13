---
name: unity-plan-workflow
description: "Use when the user asks to run the repository unity command plan-workflow, /plan-workflow, or the Plan Workflow — GDD + TDD → Parallelized Execution Plan workflow."
---

# Plan Workflow — GDD + TDD → Parallelized Execution Plan

This skill is a Codex-native wrapper for the repository command file:

`.codex/packs/unity-game/commands/plan-workflow.md`

## Workflow

1. Read `AGENTS.md`.
2. Read `.codex/packs/unity-game/guides/guardrails.md`.
3. Read `.codex/project/PROJECT.md` and `.codex/project/RULES.md` when they exist.
4. Read the canonical command file above completely.
5. Execute the command file as the source of truth for this workflow.
6. If the command delegates to agents, prefer native Codex subagents from `.codex/agents/*.toml` and keep write scopes disjoint.
7. Run the command-specific verification steps and report any skipped verification explicitly.

## Inputs

Use the user prompt as the command arguments. If required inputs are missing and cannot be inferred from repository context, ask one concise question before proceeding.

## Guardrails

- Never run `git push`.
- Never text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files.
- Use Unity MCP tools for Unity scene, prefab, component, asset, build, and editor operations.
- Do not revert user or other agent changes unless the user explicitly requests it.

## Output

Return the output shape required by the canonical command file. At minimum, include files changed, verification performed, and blockers or residual risks.

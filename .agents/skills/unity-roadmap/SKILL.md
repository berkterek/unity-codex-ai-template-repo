---
name: unity-roadmap
description: "Use when the user asks to run the repository unity command roadmap, /roadmap, or the Module Roadmap Generator workflow."
---

# Roadmap — Module Roadmap Generator

This skill is a Codex-native wrapper for the repository command file:

`.codex/packs/unity-game/commands/roadmap.md`

## Workflow

1. Read `AGENTS.md`.
2. Read `.codex/packs/unity-game/guides/guardrails.md`.
3. Read `.codex/project/PROJECT.md` and `.codex/project/RULES.md` when they exist.
4. Read the canonical command file above completely.
5. Execute the command file as the source of truth for this workflow.

## Inputs

Use the user prompt as the command arguments. If required inputs are missing and
cannot be inferred from repository context, ask one concise question before
proceeding.

## Guardrails

- Never run `git push`.
- Never text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files.
- Do not revert user or other agent changes unless explicitly requested.

## Output

Return the output shape required by the canonical command file. Include files
changed, roadmap gaps, and the recommended next command.

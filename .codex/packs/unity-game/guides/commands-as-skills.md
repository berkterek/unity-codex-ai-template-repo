# Commands As Codex Skills

This repository exposes command workflows as repo-scoped Codex skills under
`.agents/skills/`.

## Why Skills

Codex custom prompts are deprecated for reusable workflows. Skills are the
current Codex format for repo-shared commands and procedures.

The original command files remain canonical:

- Core commands: `.codex/core/commands/*.md`
- Unity commands: `.codex/packs/unity-game/commands/*.md`

Each generated skill is a thin wrapper that tells Codex to read and execute the
matching canonical command file.

## Naming

Core command skills are prefixed with `core-`:

```text
$core-orchestrate
$core-status
$core-validate
```

Unity command skills are prefixed with `unity-`:

```text
$unity-implement
$unity-fix
$unity-review-code
$unity-smart-commit
```

The prefixes avoid collisions for shared command names such as `orchestrate`,
`continue`, `dry-run`, `status`, and `validate`.

## Usage

Explicit invocation:

```text
$unity-implement Add player health regeneration.
```

Natural-language invocation:

```text
Use the unity-implement skill to add player health regeneration.
```

Legacy command-file invocation still works:

```text
Use .codex/packs/unity-game/commands/implement.md and add player health regeneration.
```

## Maintenance

- Edit the canonical command file first.
- Keep generated skill wrappers thin.
- Regenerate wrappers when command files are added, removed, or renamed.
- Restart Codex if skill changes do not appear in the skill picker.

## Guardrails

All command skills require the same project guardrails:

- Read `AGENTS.md`.
- Read `.codex/packs/unity-game/guides/guardrails.md`.
- Do not run `git push`.
- Do not text-edit `.unity`, `.prefab`, `.asset`, or `.meta` files.
- Use Unity MCP tools for Unity scene, prefab, component, asset, build, and
  editor operations.

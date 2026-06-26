# Agent & Command Sprawl Audit

**Scope:** Codex-native Unity template wrappers and canonical command/agent files.
**Mode:** Analysis only. Nothing was deleted, moved, or renamed.
**Date:** 2026-06-26

## Summary

| Metric | Count |
|--------|-------|
| Native Codex subagent wrappers (`.codex/agents/*.toml`) | 34 |
| Canonical role prompts (`.codex/core/agents`, `.codex/packs/unity-game/agents`) | 39 |
| Command markdown files (`.codex/core/commands`, `.codex/packs/unity-game/commands`) | 69 |
| Repo-scoped command skill wrappers (`.agents/skills/*/SKILL.md`) | 68 |

The Claude template audit found no safe removals; the same conclusion applies
to this Codex port. Commands and agents are intentionally user-invokable even
when no pipeline spawns them automatically.

## Codex-Specific Findings

- Native Codex subagents are wrappers. Their long-form behavior lives in the
  Markdown role prompts; update the Markdown first, then the `.toml` wrapper
  only for identity, sandbox, startup reads, or model/tool defaults.
- Command skills in `.agents/skills/` are the discoverable entry point for
  slash-command workflows. When command files are added, renamed, or removed,
  the matching skill wrapper must be updated.
- Duplicate command names such as `continue`, `dry-run`, `orchestrate`,
  `status`, and `validate` are expected because both core and Unity packs
  expose variants.
- Dynamic-only agents such as `unity-build-runner`, `unity-network-dev`,
  `unity-optimizer`, `unity-prototyper`, `unity-scene-builder`,
  `unity-security-reviewer`, `unity-test-runner`, `unity-ui-builder`, and
  `unity-ui-toolkit-builder` should be treated as user-invoked specialists,
  not dead code.

## Recommended Follow-Ups

1. Keep `AGENTS.md`, `README.md`, `.codex/packs/unity-game/guides/commands.md`,
   and `.codex/packs/unity-game/guides/skills-index.md` synchronized after any
   command or skill wrapper change.
2. Add a short boundary note in the agent index for dynamic-only agents so users
   know they are not spawned by default pipelines.
3. Prefer documentation-boundary fixes over deletion unless a command/agent is
   proven unreachable and obsolete across wrappers, indexes, and canonical docs.

No safe-remove actions are recommended from this audit.

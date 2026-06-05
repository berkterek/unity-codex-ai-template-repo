# Codex-Adapted Claude Import Design

## Goal

Import only the useful Unity template improvements from
`/Users/berkterek/Desktop/Github/unity-claude-ai-template-repo` into this Codex
template, adapted to Codex's `.codex/` structure and non-hook workflow.

## Scope

The import is intentionally selective. Claude Code runtime files are not copied
as-is because Codex does not use Claude's hook, plugin, state, or settings
systems.

In scope:

- Convert valuable Claude hook rules into executable Codex guardrail checks.
- Port current graph-builder improvements using `.codex/` paths.
- Add root-level repository hygiene files that are tool-neutral.
- Add a Codex-specific installer script.
- Update documentation to describe the new Codex behavior.

Out of scope:

- `.claude/hooks/` runtime scripts as standalone files.
- `.claude/state/`, `.claude/settings.json`, `.claude-plugin/`, and Claude
  plugin metadata.
- Claude model tiers, Claude settings snippets, or Claude-only hook profile
  mechanics.
- Existing unrelated working-tree changes such as `.DS_Store` and `config.ini`.

## Architecture

Codex keeps one source of truth under `.codex/`. Rules that were automatic
Claude hooks become explicit checks in `.codex/guardrails/run.sh`, with tests in
`.codex/guardrails/test/verify-guardrails.sh`.

Knowledge graph improvements stay in `.codex/graph/graph-builder.sh` and keep
the existing `.codex/project/FEATURES.json` feature source. Documentation is
updated where it already describes guardrails and graph behavior.

Root-level hygiene files are added only when they are tool-neutral and safe for
Unity projects: `.editorconfig`, `.gitattributes`, and `.gitignore`. The
installer is rewritten for Codex instead of copied from Claude.

## Components

### Guardrail Runner

Add checks for the highest-value Claude hook gaps:

- `new GameObject(...)` is a block in runtime C#.
- `Destroy(...)` outside pool/manager/spawner files is a warning.
- `async void` outside Unity lifecycle methods is a warning.
- `async UniTask` method signatures without `CancellationToken` are warnings.
- Unity object `?.` and `is null` patterns are warnings.
- `GetComponent` and `GetComponentInChildren` inside `Awake` are warnings.
- ECS/IEvent enums without `: byte` are blocks.
- Direct config edits to `.asmdef`, `.inputactions`, `Packages/manifest.json`,
  `Packages/packages-lock.json`, and `ProjectSettings/*.asset` are blocks, with
  test assembly `.asmdef` exceptions.
- Service/domain files inheriting `MonoBehaviour` or `ScriptableObject` are
  blocks.

### Graph Builder

Port the Claude graph-builder fixes while preserving Codex paths:

- `--full` invalidates stale MCP cache instead of trusting cache age.
- Retained prefab paths are checked against disk and reported as
  `STALE_PREFAB_PATH` warnings.
- Missing script/null component markers from MCP scene and prefab data are
  surfaced as `MISSING_SCRIPT` warnings.
- Nested Unity project folders continue to come from
  `.codex/project/FEATURES.json`.

### Repository Hygiene

Add Unity-safe defaults:

- `.editorconfig` for UTF-8, LF endings, final newlines, C# four-space indent,
  Unity YAML two-space indent, JSON two-space indent, and Markdown whitespace.
- `.gitattributes` for Unity YAML merge attributes and binary asset handling.
- `.gitignore` for macOS noise, Codex generated graph/cache/state artifacts,
  and local config.

### Installer

Create `install.sh` for this Codex template:

- Validate target directory exists and is a git repo.
- Copy `.codex/`, `.githooks/`, `.github/`, and `AGENTS.md`.
- Refuse to overwrite existing `.codex/` unless `--force` is passed.
- Clear generated graph/cache/state artifacts after copying.
- Print Codex-specific next steps.

## Testing

Run focused shell verification:

- `bash .codex/guardrails/test/verify-guardrails.sh`
- `bash .codex/guardrails/test/verify-integration.sh`
- `bash .codex/graph/test/verify-graphify.sh --json`

If graph verification skips Unity-project checks in template mode, report the
skip explicitly.

## Risks

- Shell heuristics can create false positives. Keep new checks scoped to the
patterns already documented in the Unity rules and add tests for expected
blocks/warnings.
- `--full` graph behavior changes MCP cache use. Preserve existing `--skip-mcp`
behavior so headless/template verification remains usable.
- Root `.gitignore` could hide files unexpectedly. Keep ignores limited to
generated/local artifacts and do not ignore source, docs, or template files.

# Agents Import Manifest

Source directory:
`.claude/agents/`

Generated directories:

- `.codex/core/agents/`
- `.codex/packs/unity-game/agents/`

## Imported Into Core

### `coder.md`

Kept:

- Single-task ownership.
- Do not modify files outside assignment.
- Do not overwrite other agents or user changes.
- Read project context first.
- Self-review before completion.
- Optional mailbox, heartbeat, and checkpoint reporting.

Removed:

- Unity, C#, VContainer, MessagePipe, Input System, TextMeshPro, and
  zero-allocation hot path requirements.
- File path and namespace assumptions.

### `tester.md`

Kept:

- Behavior-focused tests.
- Edge case and error path coverage.
- Deterministic isolated tests.
- Existing project test style first.
- Optional progress reporting.

Removed:

- NUnit-only requirement.
- Unity Test Framework-only structure.
- Hand-written fake requirement as a hard rule.

### `reviewer.md`

Kept:

- PASS/FAIL gate.
- Findings-first review stance.
- Acceptance criteria verification.
- Severity levels.
- Test and residual risk reporting.

Removed:

- Unity compilation/runtime MCP requirements.
- Unity-specific architecture checklist.
- C# 9, VContainer, MessagePipe, Input System, TextMeshPro, sprite atlas checks.

### `committer.md`

Kept:

- Atomic commit grouping.
- Dependency-ordered commit strategy.
- Conventional commit fallback.
- No AI attribution.
- No push.
- Clean working tree target.

Adjusted:

- Commit trailers are no longer mandatory in core. Projects can opt in through
  `.codex/project/TOOLING.md` or `RULES.md`.

## Moved To Unity Pack

### `unity-setup.md`

Moved to `.codex/packs/unity-game/agents/unity-setup.md`.

Reason:

- It assumes Unity Editor, scenes, prefabs, ScriptableObjects, Play Mode,
  Unity MCP, and Unity asset safety.
- It is useful, but not project-agnostic.

### `debugger.md`, `migrator.md`, `silent-failure-hunter.md`

Moved to `.codex/packs/unity-game/commands/` (not agents).

Reason:

- These are directly invocable by the developer, not orchestration role templates.
- In the Codex model, agents are role templates the orchestrator spawns for tasks.
  These three behave as commands: the developer triggers them with a prompt.
- All three assume Unity-specific patterns (UniTask, VContainer, ECS, Addressables)
  so they belong in the unity-game pack.

## Not Imported

- Model routing names from Claude (`haiku`, `sonnet`, `opus`).
- Claude-specific tool names.
- Hardcoded `CLAUDE.md`, `GDD.md`, `TDD.md`, and `WORKFLOW.md` assumptions.
- Unity-specific coding rules.


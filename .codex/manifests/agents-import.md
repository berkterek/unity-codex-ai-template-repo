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

### Unity specialist agents (ported from `.claude/agents/`)

Added to `.codex/packs/unity-game/agents/`:

| Agent | Source | Notes |
|-------|--------|-------|
| `unity-build-runner.md` | `unity-build-runner.md` | YAML frontmatter removed; MCP tool names kept. |
| `unity-coder.md` | `unity-coder.md` | YAML frontmatter removed; full implementation agent for pipelines. |
| `unity-coder-lite.md` | `unity-coder-lite.md` | YAML frontmatter removed; lightweight variant. |
| `unity-critic.md` | `unity-critic.md` | YAML frontmatter removed; adversarial plan reviewer. |
| `unity-developer.md` | `unity-developer.md` | YAML frontmatter removed; 10-point Unity 6 specialist review. |
| `unity-fixer.md` | `unity-fixer.md` | YAML frontmatter removed; MCP-assisted bug fixer. |
| `unity-fixer-lite.md` | `unity-fixer-lite.md` | YAML frontmatter removed; scoped single-defect fix. |
| `unity-git-master.md` | `unity-git-master.md` | YAML frontmatter removed; git-only Bash restriction kept. |
| `unity-linter.md` | `unity-linter.md` | YAML frontmatter removed; haiku-speed read-only validator. |
| `unity-network-dev.md` | `unity-network-dev.md` | YAML frontmatter removed; multi-framework networking. |
| `unity-optimizer.md` | `unity-optimizer.md` | YAML frontmatter removed; MCP profiler workflow. |
| `unity-prototyper.md` | `unity-prototyper.md` | YAML frontmatter removed; PROTOTYPE marker requirement kept. |
| `unity-reviewer.md` | `unity-reviewer.md` | YAML frontmatter removed; read-only constraint kept. |
| `unity-scene-builder.md` | `unity-scene-builder.md` | YAML frontmatter removed; MCP-only scene construction. |
| `unity-scout.md` | `unity-scout.md` | YAML frontmatter removed; read-only exploration. |
| `unity-security-reviewer.md` | `unity-security-reviewer.md` | YAML frontmatter removed; read-only security audit. |
| `unity-shader-dev.md` | `unity-shader-dev.md` | YAML frontmatter removed; mobile-first URP shader rules. |
| `unity-test-runner.md` | `unity-test-runner.md` | YAML frontmatter removed; EditMode/PlayMode test workflow. |
| `unity-ui-builder.md` | `unity-ui-builder.md` | YAML frontmatter removed; UI Toolkit specialist. |
| `unity-verifier.md` | `unity-verifier.md` | YAML frontmatter removed; 3-iteration verify-fix loop. |

Removed from all ported agents:
- YAML frontmatter (`name`, `description`, `model`, `color`, `tools`, `skills`)
- Claude-specific model tier references (`haiku`, `sonnet`, `opus`)
- `.claude/rules/` path references → `.codex/packs/unity-game/rules/`

## Not Imported

- Model routing names from Claude (`haiku`, `sonnet`, `opus`).
- Claude-specific tool names.
- Hardcoded `CLAUDE.md`, `GDD.md`, `TDD.md`, and `WORKFLOW.md` assumptions.
- Unity-specific coding rules.


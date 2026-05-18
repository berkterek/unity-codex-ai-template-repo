# Pipeline Command Reference

Full step-by-step flows for each pipeline command. See CLAUDE.md for the one-line summaries.

> Reviewer priority: Claude → unity-reviewer (falls back to unity-reviewer if Claude is unavailable).

## Implementation Pipelines

### `/implement <task>`
complexity score → test writer → **unity-coder** → **unity-verifier** (compile + tests via MCP) → reviewer priority: **Claude** → unity-reviewer → [unity-developer if score ≥ 0.7] → **silent failure audit** (changed files) → committer

### `/fix <bug>`
complexity score → Step 1: **unity-fixer** + **unity-scout** simultaneously (complexity ≥ 0.4) → test writer → **unity-coder** → **unity-verifier** (compile + tests via MCP) → reviewer priority: **Claude** → unity-reviewer → [unity-developer if score ≥ 0.7] → **silent failure audit** (changed files) → committer

### `/fix-deep <bug>`
complexity score → **evidence-first pipeline**: log intake (file / text / MCP) → hypothesis → debug injection → Step 3: **unity-fixer** + **unity-scout** simultaneously (complexity ≥ 0.4) → **evidence gate** (proven / refuted / inconclusive) → fix only if proven → validator → reviewer → **silent failure audit** (changed files) → committer; refuses to fix if root cause cannot be proven

- Use for: logic bugs, "sometimes happens" issues, wrong values at runtime, NullRef with unclear source
- Use `/fix` when: stack trace clearly points to root cause

### `/scene-setup <description>`
complexity score → **unity-coder-lite** (Simple) / **unity-coder** (Medium/Complex) + unity-setup → **unity-verifier** → **Claude** → unity-reviewer → [unity-developer if score ≥ 0.7] → committer

### `/migrate <pattern> in <scope>`
complexity score → [test guard if Medium/Complex] → **migrator** / **unity-migrator** → reviewer → [unity-developer if score ≥ 0.7] → committer

### `/orchestrate`
complexity score → read WORKFLOW.md → check `parallel_group` annotations → per-task: **coder** (pure C#) / **unity-coder-lite** (Simple Unity) / **unity-coder** (Medium/Complex Unity) → **unity-verifier** → **Claude** → unity-reviewer → [unity-developer if score ≥ 0.7] → committer; tasks with same `parallel_group` run simultaneously (complexity ≥ 0.4); phase gate runs **ralph → silent-failure-hunt → validate** automatically before asking to proceed; emits `VERIFICATION_PASSED` event on success

## Planning Pipelines

### `/create-plan <file> <what>`
researcher → **complexity-aware planner** (opus, assigns `parallel_group` to independent tasks) → reviewer → save → optional implementer (parallel spawn for grouped tasks if complexity ≥ 0.4)

### `/update-plan <file> <change>`
analyzer → planner (opus, updates `parallel_group` annotations) → reviewer → save → optional implementer (parallel spawn for grouped tasks if complexity ≥ 0.4)

## Search Pipeline

### `/search <query>`
complexity score → Phase 1: **Explore** + **unity-scout** simultaneously (complexity ≥ 0.4) → write findings to `.codex/state/search-findings.md` → Phase 2: reviewer validates **completeness** (COMPLETE / INCOMPLETE / REJECT, max 5 iter) → Phase 3: present findings to user → Phase 4: **action router** recommends next command (`/fix`, `/fix-deep`, `/implement`, `/create-plan`, `/update-plan`, or no action) — never executes automatically

## Setup Pipeline

### `/setup-project`
**Step 0:** detect existing state, compare against `project-features.json` (if any), offer sync-only mode on conflict. **Step 1:** ask feature questions (Addressables / Testing / ECS) + package gates. Generates folder structure, .asmdef files, base framework classes, and manual checklist. Writes `.codex/project-features.json`, removes disabled hooks from `settings.json`, adds `## Project Features` header to `CLAUDE.md`.

### `/create-test <FeatureName>`
Unified test generator: runs test-type-router to determine EditMode / PlayMode-ECS / PlayMode-Scene, then generates the full test infrastructure for the chosen type. EditMode → NSubstitute unit test. PlayMode-ECS → isolated World test. PlayMode-Scene → TestScope + TestInstaller + test stub + scene via MCP.

### `/discover [--dry-run|--write] [--only <pkg>]`
Walk `Packages/manifest.json`, summarize each Unity package, and emit per-package skill drafts to `.codex/skills/third-party/<pkg>/`. Small packages produce a single `SKILL.md`; large packages (50+ prefabs) produce a multi-file folder (`SKILL.md`, `api.md`, `prefabs.md`, `integration.md`, `test-strategy.md`, `samples.md`). Supports `--dry-run` (default), `--write`, `--only <pkg>`, `--include-assets-plugins`.

# Commands And Protocols Import Manifest

Source directory:
`.claude/commands/`

Generated directories:

- `.codex/core/commands/`
- `.codex/core/protocols/`

## Imported Into Core Commands

### `orchestrate.md`

Kept:

- Phased workflow execution.
- Parallel task batches.
- Agent prompt construction.
- Review gate and rework loop.
- Phase gate.
- Optional phase commit.
- Progress updates.
- Event journal.
- Mailbox, heartbeat, checkpoint, and orchestrator state.

Removed or generalized:

- Unity game pipeline assumptions.
- `GDD.md`, `TDD.md`, `WORKFLOW.md` as hardcoded prerequisites.
- Claude-specific model names and tool parameters.
- Helm dashboard-specific language.

### `continue.md`

Kept:

- Event replay as primary recovery path.
- Progress file fallback.
- Restart/review handling for interrupted tasks.
- Checkpoint reuse.

Generalized:

- Paths moved from `.claude` and `docs` to `.codex/project` and
  `.codex/runtime`.

### `status.md`

Kept:

- Short dashboard-style report.
- Document presence checks.
- Task counts, blockers, recent events.

Removed:

- Unity asset counting.
- Game Factory stage names.

### `stop.md`

Kept:

- Graceful pause.
- Append pause event.
- Preserve incomplete work and checkpoints.
- Remove only active marker.

### `dry-run.md`

Kept:

- Preview without agent spawning.
- Phase/batch/resource/risk summary.

Removed:

- Claude model routing table.
- Unity setup agent assumptions in core.

### `validate.md`

Kept:

- File existence checks.
- Acceptance criteria verification.
- Cross-file consistency.
- Verification command reporting.
- PASS/FAIL recommendation.

Moved to packs:

- Unity phase-specific checks.
- Unity Test Framework assumptions.
- Pure C#/MonoBehaviour rules.

## New Core Protocols

- `progress.md`: stable human-readable workflow status.
- `event-journal.md`: append-only recovery source.
- `mailbox.md`: agent progress and heartbeat reporting.
- `checkpoint.md`: agent and orchestrator recovery state.

## Added To Unity Pack Commands

The following commands were ported from the source and placed in
`.codex/packs/unity-game/commands/` after being converted to Codex format:

| Command | Notes |
|---------|-------|
| `adr.md` | Architecture Decision Record generator — records decisions with context, options, and consequences. |
| `add-feature.md` | Incremental pipeline update for new features. |
| `architect.md` | TDD creation from GDD. |
| `audio-clip-setup.md` | Guided audio clip import settings and AudioSource wiring via unity-setup + audio-clip-agent. |
| `catch-up.md` | Codebase comprehension guide generator. |
| `caveman.md` | Forced simplification pass — removes premature abstractions and over-engineered code. |
| `check-portability.md` | Checks code for platform-specific assumptions before build target changes. |
| `clean-slop.md` | Dead-code and over-abstraction removal. |
| `context-prime.md` | Loads project context (GDD, TDD, RULES, LEARNED) into working memory. |
| `create-changelog.md` | Generates a structured CHANGELOG entry from recent commits. |
| `create-test.md` | Unified test generator: routes to EditMode / PlayMode-ECS / PlayMode-Scene via test-type-router. |
| `debug-session.md` | Structured debugging session with hypothesis tracking. |
| `debugger.md` | Root cause analysis for Unity runtime bugs. |
| `discover.md` | Walks `Packages/manifest.json` and emits per-package skill drafts. |
| `dump.md` | Fast read-only codebase dump for context loading. |
| `five.md` | Five-minute quick-look summary of recent changes. |
| `fix-deep.md` | Evidence-first bug fix — refuses to fix until root cause is proven. |
| `fix.md` | Standard bug fix pipeline with verify-fix loop. |
| `game-idea.md` | GDD creation — Unity game design pipeline. |
| `generate-tests.md` | Batch test generation for existing untested code. |
| `graphics-setup.md` | URP render pipeline asset configuration and quality tier setup via graphics-setup-agent. |
| `grill-me.md` | Adversarial design review — challenges GDD/TDD assumptions. |
| `implement.md` | Full TDD implementation pipeline with complexity scoring. |
| `instincts.md` | Records developer intuitions and gut-feel notes into LEARNED.md. |
| `learn.md` | Pattern extraction into `.codex/project/LEARNED.md`. |
| `mermaid.md` | Generates Mermaid diagrams from code or descriptions. |
| `migrate.md` | Systematic migration command (routes to unity-migrator for Unity-specific patterns). |
| `migrator.md` | Legacy pattern modernizer (coroutines, singletons, etc.). |
| `new-module.md` | 5-file module generator (VContainer, IEventBus pattern). |
| `performance-audit.md` | Hot path audit — flags allocations and expensive calls in Update loops. |
| `plan-workflow.md` | Generates phased WORKFLOW.md from GDD + TDD. |
| `qa.md` | Quality gate: ralph → silent-failure-hunt → validate in sequence. |
| `ralph.md` | Verify-fix loop — compile + tests until green or max iterations. |
| `refine-gdd.md` | GDD iteration with cascade warnings. |
| `refine-tdd.md` | TDD iteration with impact assessment. |
| `review-code.md` | Manual code review against unity-game pack rules. |
| `scene-setup.md` | Scene construction pipeline via unity-setup + unity-scene-builder. |
| `search.md` | Evidence-gathering search: explores codebase and recommends next action. |
| `setup-project.md` | Folder structure, .asmdefs, base classes, and FEATURES.json generator. |
| `silent-failure-hunter.md` | Silent error audit for C# files. |
| `smart-commit.md` | Semantic git commit with conventional commit format. |
| `unity-scene-update.md` | Updates an existing scene's hierarchy via MCP. |
| `update-plan.md` | Updates an existing plan file with new tasks or re-grouping. |
| `update-scene-hierarchy.md` | Targeted hierarchy update for a single scene object. |

Conversion changes applied:
- `CLAUDE.md` → `.codex/project/RULES.md` / `.codex/project/PROJECT.md`
- `docs/WORKFLOW.md` → `.codex/project/WORKFLOW.md`
- `docs/PROGRESS.md` → `.codex/project/PROGRESS.md`
- `.claude/agents/` → `.codex/core/agents/` / `.codex/packs/unity-game/agents/`
- `.claude/skills/learned/` → `.codex/project/LEARNED.md`
- `$ARGUMENTS` removed (Codex does not use this convention)

## Still Not Imported

| Command | Reason |
|---------|--------|
| `plan-workflow.md` | Was part of original claude repo; equivalent is `orchestrate.md` in core. |
| `build-game.md` | Too project-specific; belongs in `project/TOOLING.md`. |
| `init-project.md` | Covered by `core/README.md` first-time setup instructions. |
| `benchmark.md` | Too platform-specific; not in source repo. |


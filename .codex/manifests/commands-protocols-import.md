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
| `game-idea.md` | GDD creation — Unity game design pipeline. |
| `architect.md` | TDD creation from GDD. |
| `add-feature.md` | Incremental pipeline update for new features. |
| `new-module.md` | 5-file module generator (VContainer, IEventBus pattern). |
| `refine-gdd.md` | GDD iteration with cascade warnings. |
| `refine-tdd.md` | TDD iteration with impact assessment. |
| `review-code.md` | Manual code review against unity-game pack rules. |
| `catch-up.md` | Codebase comprehension guide generator. |
| `clean-slop.md` | Dead-code and over-abstraction removal. |
| `learn.md` | Pattern extraction into `.codex/project/LEARNED.md`. |
| `debugger.md` | Root cause analysis for Unity runtime bugs. |
| `migrator.md` | Legacy pattern modernizer (coroutines, singletons, etc.). |
| `silent-failure-hunter.md` | Silent error audit for C# files. |

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


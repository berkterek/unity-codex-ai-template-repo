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

## Not Imported Yet

The following commands are intentionally deferred:

- `game-idea.md`
- `architect.md`
- `plan-workflow.md`
- `build-game.md`
- `init-project.md`
- `add-feature.md`
- `refine-gdd.md`
- `refine-tdd.md`
- `review-code.md`
- `catch-up.md`
- `clean-slop.md`
- `learn.md`
- `benchmark.md`

Some are reusable, but they need a separate pass to split generic planning from
Unity/game-specific design.


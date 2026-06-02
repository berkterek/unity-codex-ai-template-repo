# Graphify Verify

Single-script test harness for the `.codex/graph/` toolchain.
Shell-only — no Unity Editor, no C# compilation.

## Requirements
- `bash >= 4`, `jq`
- Optional: `fswatch` or `inotifywait` (watch smoke test downgrades to `[SKIP]` if absent)

## Run

```bash
bash .codex/graph/test/verify-graphify.sh          # human-readable
bash .codex/graph/test/verify-graphify.sh --json   # JSON summary
```

## Exit codes
- `0` — only PASS + KNOWN_FAIL (no regressions)
- `1` — at least one real FAIL
- `2` — missing prerequisite (jq absent or graph.json missing/invalid)

## Coverage

| Section | What it tests |
|---------|---------------|
| T3 — Builder flags | `--full`, `--incremental`, `--changed-files`, `--skip-mcp`, `--output`, `--quiet` |
| T4 — Validator rules | R1–R6 (SINGLETON, EVENT_DANGLING, CONCRETE_UNREGISTERED, INTERFACE_MISPLACED, ASMDEF_UNRESOLVED, LAYER_VIOLATION) |
| T5 — Pivot integrity | event count, installer count, scope tree, `.last-build` freshness, implementers (BUG#1), MCP prefab merge (BUG#2) |
| T6 — /knowledge-graph | all 9 subcommands |
| T7 — Triggers | graph-watch syntax and `purge_ghosts` |
| T8 — Known bugs | BUG#1, BUG#2, BUG#3 — auto-promoted to PASS when fixed |

## Sandbox (5 protected files — always restored)
- `.codex/graph/graph.json`
- `.codex/graph/graph.json.bak`
- `.codex/graph/.last-build`
- `.codex/graph/cache/file-hashes.json`
- `.codex/graph/cache/mcp-extract.json`

`trap cleanup EXIT INT TERM` guarantees restoration on success, failure, or Ctrl-C.

## KNOWN_FAIL graduation

When a bug listed in Task 8 of `docs/PLAN_graphify_test_coverage.md` is fixed:
1. Re-run the harness — the test auto-promotes to PASS and prints
   `[REGRESSION_FIXED: BUG#N]` to stderr.
2. Remove the `known_fail "BUG#N…"` branch from the test function.
3. The former KNOWN_FAIL is now a regression guard.

## `--validate-with-codex`

Intentionally skipped — it requires a live Codex review task and is not testable in a
headless shell harness. The harness emits an explicit `[SKIP]` line for this flag.

## When to re-run

After editing any of:
- `graph-builder.sh`
- `graph-validator.sh`
- `extractors/*.sh`
- `graph-watch.sh`

## AGENTS.md note

Add this line under the `## Knowledge Graph` section if you want the harness to
be discoverable from the top-level agent instructions:

> Verify the toolchain with `bash .codex/graph/test/verify-graphify.sh` (exit 0 = clean).

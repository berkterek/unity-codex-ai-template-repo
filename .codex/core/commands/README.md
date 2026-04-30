# Core Commands

These command templates are project-agnostic orchestration workflows. They do
not assume a specific language, framework, product domain, or model provider.

Project-specific document names and verification commands should be declared in:

- `.codex/project/PROJECT.md`
- `.codex/project/TOOLING.md`
- `.codex/project/WORKFLOW.md`
- `.codex/project/PROGRESS.md`

## Commands

| Command | Purpose |
|---------|---------|
| `orchestrate.md` | Execute a phased workflow with agents, review gates, and commits. |
| `continue.md` | Resume interrupted orchestration from events/progress/checkpoints. |
| `status.md` | Report current workflow state. |
| `stop.md` | Gracefully pause active orchestration. |
| `dry-run.md` | Preview the execution plan without changing files. |
| `validate.md` | Validate that a phase is actually complete. |

## Protocols

See `.codex/core/protocols/` for the shared formats these commands use.

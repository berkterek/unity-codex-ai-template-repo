## Context Management

### Context Getting Full? Use /checkpoint

When context reaches ~70-80%, use `/checkpoint` to save progress and fully reset:

```
/checkpoint  →  Codex writes summary to .codex/project/state/checkpoint.md
/clear       →  Context fully freed
Send: "read .codex/project/state/checkpoint.md"  →  Codex resumes from where you left off
```

The checkpoint file is at `.codex/project/state/checkpoint.md` and is deleted after it is read. This is the preferred approach over `/compact` when you need maximum token recovery.

**`/compact` vs `/checkpoint` + `/clear`:**
- `/compact` — shrinks context in-place, you continue immediately, some tokens remain
- `/checkpoint` + `/clear` — full reset, maximum token recovery, resumes via file on next message

### Session Resume

After a context reset or new session:
1. Read checkpoint/progress files if present.
2. Read `AGENTS.md` and `.codex/packs/unity-game/rules/architecture.md`
3. Read the source files for the module being worked on

### Session State Persistence (`.codex/project/state/`)

Structured state can be written by commands and agents across sessions:

| File | Contents |
|------|----------|
| `session.json` | Current branch, phase, modified files, active task, decisions |
| `learnings.jsonl` | Structured learning records accumulated across sessions |
| `instincts/` | Project-specific and global instinct library (confidence-scored patterns) |

- Use `/instincts` to view, evolve, promote, or export instincts

## Review Modes

Control pipeline depth by prefixing any pipeline command:

| Mode | Trigger | Pipeline |
|------|---------|---------|
| **solo** | `/solo /implement …` | unity-coder only — no reviewer, no committer |
| **lean** | `/lean /implement …` | unity-coder → unity-reviewer → committer |
| **full** | `/full /implement …` (default) | unity-coder → Codex → unity-reviewer → committer |

Use `solo` for exploratory spikes, `lean` for low-risk changes, `full` for production features.

## Verification Notes

Codex does not maintain Claude hook logs. Use command output, Unity console
checks, test results, graph validation, and `.codex/project/PROGRESS.md` for
workflow evidence.

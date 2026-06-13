# Update AGENTS.md — Project Config Sync

Synchronizes `AGENTS.md` with the actual project state: rules in `.codex/packs/unity-game/rules/`, commands in `.codex/packs/unity-game/commands/`, and agents in `.codex/packs/unity-game/agents/`.

## Usage

```
/update-agents-md
/update-agents-md --section rules
/update-agents-md --section commands
/update-agents-md --section agents
```

If `--section` is omitted, all sections are synced.

## Step 1 — Read Source of Truth

1. `.codex/packs/unity-game/rules/` → list all `.md` files
2. `.codex/packs/unity-game/commands/` → list all `.md` files
3. `.codex/packs/unity-game/agents/` → list all `.md` files
4. `.codex/core/agents/` → list all `.md` files
5. `AGENTS.md` → read current state

## Step 2 — Diff Each Section

### Rules Section
- File present but not in AGENTS.md → **ADD**
- File in AGENTS.md but deleted from disk → **REMOVE**
- Description changed → **UPDATE**

### Commands Section
- File present but not listed → **ADD** (extract description from file's first paragraph)
- File deleted but still listed → **REMOVE**

### Agents Section
- Agent present but not in AGENTS.md → **ADD** (extract role from agent file's first paragraph)
- Agent deleted but still listed → **REMOVE**

## Step 3 — Show Diff

```
AGENTS.md Sync Report
=====================

Rules:
  + bootstrap-pattern  → VContainer installer hierarchy and module wiring

Commands:
  + implement-lite  → Lightweight single-class implementation pipeline

Agents:
  + lean-planner  → Compact 3-5 task plan, no code skeletons

Legend: + add  - remove  ~ update
```

If zero changes: "AGENTS.md is up to date. No changes needed." — stop.

## Step 4 — Confirm

Ask: **"Apply these changes to AGENTS.md? (yes / no)"**

Wait for explicit confirmation before writing.

## Step 5 — Apply Changes

Update only affected sections. Do not rewrite unrelated content.

- **Rules table** — `| filename.md | one-line description |` sorted alphabetically
- **Commands section** — maintain category groupings, `| /command-name | description |`
- **Agents table** — `| agent-name | role |`

## Step 6 — Report

```
AGENTS.md updated.
  Rules:    +1 added
  Commands: +3 added
  Agents:   +2 added
```

Do NOT commit automatically. Use `/smart-commit` or `/smart-commit-selected`.

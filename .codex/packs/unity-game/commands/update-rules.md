# /update-rules — Project Rules Sync Agent

Synchronizes project context files with the actual state of rules, commands, and agents in the `.codex/` folder.

## Usage

```
/update-rules
/update-rules --section rules
/update-rules --section commands
/update-rules --section agents
```

If `--section` is omitted, all sections are synced.

---

## Step 1 — Read Source of Truth

Read these to build the authoritative state:

1. `.codex/packs/unity-game/rules/` → list all `.md` rule files
2. `.codex/packs/unity-game/commands/` → list all `.md` command files
3. `.codex/packs/unity-game/agents/` → list all `.md` agent files
4. `.codex/core/agents/` → list all `.md` core agent files

Read the current index files:
- `.codex/project/RULES.md` — project rules table
- `README.md` — Commands section and Agent List section
- `AGENTS.md` — Agent directory and Command directory

---

## Step 2 — Diff Each Section

### Rules Section

Compare `.codex/packs/unity-game/rules/*.md` files against the Rules table in `.codex/project/RULES.md`.

- File present but not in table → **ADD**
- File in table but deleted from disk → **REMOVE**
- Description changed → **UPDATE**

### Commands Section

Compare `.codex/packs/unity-game/commands/*.md` files against the Commands section in `README.md` and `AGENTS.md`.

- File present but not listed → **ADD** (extract description from the command file's first paragraph)
- File deleted but still listed → **REMOVE**

### Agents Section

Compare `.codex/packs/unity-game/agents/*.md` and `.codex/core/agents/*.md` files against the Agent List in `README.md` and the Agent Directory in `AGENTS.md`.

- Agent present but not in table → **ADD** (extract role from agent file's first paragraph)
- Agent deleted but still listed → **REMOVE**

---

## Step 3 — Show Diff

Print a clear diff of what will change:

```
Rules Sync Report
=================

Rules (.codex/project/RULES.md):
  + new-rule.md     → one-line description
  - old-rule.md     → removed from disk

Commands (README.md + AGENTS.md):
  + update-rules    → Sync project rules with actual .codex/ folder state
  - old-command     → no longer exists

Agents (README.md + AGENTS.md):
  + tester          → EditMode / PlayMode test authoring

Legend: + add  - remove  ~ update
```

If zero changes across all sections:
```
All index files are up to date. No changes needed.
```
And stop.

---

## Step 4 — Confirm

Ask: **"Apply these changes? (yes / no)"**

Wait for explicit confirmation before writing.

---

## Step 5 — Apply Changes

Update only the affected sections. Do not rewrite unrelated content.

**Rules table** (in `.codex/project/RULES.md`) — each row: `| filename.md | one-line description |`. Sort alphabetically.

**Commands section** (in `README.md` and `AGENTS.md`) — maintain category groupings. Each entry: `| /command-name | description |`. Extract description from the command file's first paragraph.

**Agents tables** (in `README.md` and `AGENTS.md`) — each row: `| agent-name | role |`. Extract role from the agent file's first paragraph.

---

## Step 6 — Report

Print a summary:
```
Sync complete.
  Rules:    +1 added, 0 removed
  Commands: +1 added, 0 removed
  Agents:   +2 added, 0 removed
```

Do NOT commit automatically. The user commits manually.

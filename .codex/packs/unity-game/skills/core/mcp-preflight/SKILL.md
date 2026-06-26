---
name: mcp-preflight
description: "MCP availability + active-instance check for Unity Codex workflows. Run before MCP-backed commands and before any MCP write."
---

# MCP Preflight Check

Run this check at the start of any command that spawns MCP agents (unity-setup, unity-scene-builder, unity-verifier, graphics-setup-agent, audio-clip-agent, etc.).

---

## How to Run the Check

Call `manage_editor` with `action: "telemetry_ping"`.

---

## States

### State 1 — MCP Connected ✅
**Signal:** `manage_editor(action="telemetry_ping")` returns a valid response.

**Action:** Proceed with full pipeline, but first clear State 1.5 below. MCP tools can be used normally only after the active Unity instance is verified.

---

### State 1.5 — Connected, but Wrong / Ambiguous Instance ⚠️
**Signal:** More than one Unity Editor may be open, or the active MCP instance may not belong to this repository. A default MCP instance can target the wrong Unity project; scene, prefab, asset, and `execute_code` operations can then succeed against the wrong project without an obvious error.

**Action (mandatory before the first MCP write or `execute_code`):**
1. List connected Unity instances through the MCP instance resource/tool available in this session.
2. Select the instance whose project path is under the current repository root.
3. Pin it with `set_active_instance`.
4. Verify the active project by reading `Application.dataPath` through `execute_code` or equivalent project info.
5. Continue only if `Application.dataPath` resolves inside this repo.

If verification fails, abort MCP writes and re-pin the correct instance. Closing every other Unity Editor is an acceptable simplification, but still verify the active `dataPath` before writing.

---

### State 2 — MCP Installed but Disconnected ⚠️
**Signal:** `manage_editor(action="telemetry_ping")` fails, times out, or returns an error such as "Unity Editor not responding" / "connection refused".

**Action:** STOP. Print this message and do not proceed with MCP operations:

```
⛔ MCP connection unavailable — [COMMAND_NAME] cannot start.

Unity Editor must be open and the MCP plugin must be active.

Checklist:
  1. Is Unity Editor open?
  2. Is the MCP plugin active? (Edit → Project Settings → MCP or Window → MCP)
  3. Restart the Editor and try again.

Alternative:
  Generate C# files only, skipping scene / prefab / wiring steps?
  Manual steps will be listed for you to complete in the Editor.
  Reply yes to continue in code-only mode, or no to cancel.
```

Wait for user response before continuing.

---

### State 3 — MCP Not Installed ❌
**Signal:** The tool call fails with "tool not found" / "unknown tool", or the `mcp__unityMCP__` prefix is not recognized in this session.

**Action:** Silently switch to code-only mode. Do NOT stop the pipeline. Print this once:

```
ℹ️  MCP tools are not available in this session.
   Continuing in code-generation mode.
   Manual Editor steps will be listed for scene / prefab work.
```

Then continue the pipeline, replacing every MCP step with:
- C# script generation (installers, providers, components)
- A numbered checklist of manual Unity Editor steps

---

## How to Distinguish State 2 from State 3

| Symptom | State |
|---------|-------|
| Tool returns error about Unity Editor / connection | State 2 |
| Tool returns timeout or no response | State 2 |
| Tool name not recognized / "tool not found" | State 3 |
| `mcp__unityMCP__*` prefix absent from tool list | State 3 |

---

## Code-Only Fallback Template (State 2 user says yes / State 3)

When continuing without MCP, every command must output:

```
### Manual Steps (complete in Unity Editor)
- [ ] [Specific step 1 — exact menu path or drag-drop instruction]
- [ ] [Specific step 2]
- [ ] ...

### Generated C# Files
- [file path] — [purpose]
```

Be specific. "Open the scene" is not enough — write "File → Open Scene → _Scenes/[SceneName].unity".

---

## Usage in Commands

At the start of each relevant command step, add:

```
### Step N — MCP Preflight
Read and apply `.codex/packs/unity-game/skills/core/mcp-preflight/SKILL.md`.
- State 1 → verify active Unity instance, then continue with full pipeline
- State 1.5 → pin the repo-local Unity instance and verify `Application.dataPath` before any MCP write
- State 2 → stop, offer code-only alternative, wait for user
- State 3 → switch to code-only mode silently, continue
```

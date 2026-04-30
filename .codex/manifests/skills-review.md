# Claude Skills Review For Codex Template

This records which `.claude/skills` content should be adapted into the Codex
template and which content should stay out of the base temp.

## Decision

Do not import the full `.claude/skills` tree into `.codex`.

Reason:

- The source has 40 Unity-focused skills and about 25k lines.
- A reusable template should stay light.
- Full genre/gameplay/package references are useful, but they are not universal
  enough to ship in the base temp.
- The base temp should include only defaults that are safe for most Unity
  projects.

## Included In Base Template

| Source Skill | Target | Reason |
|--------------|--------|--------|
| `core/unity-mcp-patterns` | `.codex/packs/unity-game/guides/unity-mcp.md` | Unity MCP workflow is part of how this template should operate. |
| `core/input-system` | `.codex/packs/unity-game/guides/input-system.md` | New Input System is the default input policy for new Unity projects. |
| `core/serialization-safety` | `.codex/packs/unity-game/guides/serialization-safety.md` | Prevents Unity data loss and should be a default safety rule. |

## Keep As Optional Per-Project Guidance

| Group | Skills | Reason |
|-------|--------|--------|
| `core` | `assembly-definitions`, `event-systems`, `object-pooling`, `scriptable-objects` | Useful, but project architecture choices vary. |
| `gameplay` | `character-controller`, `dialogue-system`, `inventory-system`, `procedural-generation`, `save-system`, `state-machine` | Feature-specific, not every project needs them. |
| `genre` | `card-game`, `endless-runner`, `hyper-casual`, `idle-clicker`, `match3`, `platformer-2d`, `puzzle`, `racing`, `roguelike`, `rpg`, `topdown`, `tower-defense` | Genre-specific and too large for the base temp. |
| `platform` | `mobile` | Good optional pack when the project targets mobile. |
| `systems` | `addressables`, `animation`, `audio`, `cinemachine`, `navmesh`, `physics`, `shader-graph`, `ui-toolkit`, `urp-pipeline` | Engine-system-specific; load only when the project uses that system. |
| `third-party` | `dotween`, `odin-inspector`, `textmeshpro`, `unitask`, `vcontainer` | Package-specific; should only apply when the package is installed or selected. |

## Future Optional Packs

Good candidates for separate optional packs:

- `unity-mobile-pack`
- `unity-ui-pack`
- `unity-third-party-pack`
- `unity-genre-card-game-pack`
- `unity-genre-puzzle-pack`
- `unity-gameplay-systems-pack`

These should not be part of the base Codex temp unless the user explicitly
chooses them.

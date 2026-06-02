# Quick Start

1. Copy the `.codex/` folder into your Unity project root
2. Run `/setup-project` — it detects existing state, asks about optional features (Addressables / Testing / ECS), generates folder structure, .asmdef files, and base classes, then writes `.codex/project/FEATURES.json`
3. Complete the **Manual Setup Checklist** — see `.codex/packs/unity-game/guides/setup-checklist.md`

For an existing project with legacy code, see **Adding to an Existing Project** below.

## Adding to an Existing Project

Copy `.codex/` into the project root. Codex has no hook mechanism, so treat
`.codex/packs/unity-game/guides/guardrails.md` as the model-level equivalent of
the Claude hook suite. These are the highest-risk checks to apply first:

| Check | What it catches | Migration path |
|------|---------------|----------------|
| Input System | `Input.GetKey`, `Input.GetAxis` | Create `PlayerControls.inputactions`, wrap in `InputView` |
| VContainer singleton | Static singletons | Replace with VContainer registration in scope |
| Editor/runtime boundary | Bare `using UnityEditor` in runtime | Wrap with `#if UNITY_EDITOR` |
| Pure C# boundary | `using UnityEngine` in services | Move Unity calls to a Provider in `Games/Concretes/` |

**Recommended migration order:**
1. Run `/setup-project` to scaffold the folder structure
2. Move existing scripts into the new structure without changing logic
3. Fix blocking hook violations one module at a time
4. Run `/migrate` for systematic pattern replacements (e.g. coroutine→UniTask)
5. Run `/validate` after each phase to confirm green state

---

## Troubleshooting

### NSubstitute is not found / `using NSubstitute;` fails to resolve

NSubstitute is **not** distributed via the Package Manager — `/setup-project` cannot install it automatically. Manual steps:

1. Download `NSubstitute.dll` and `Castle.Core.dll` from the NSubstitute releases page (or via NuGet → extract `lib/netstandard2.0/`).
2. Place both DLLs under `Assets/Plugins/NSubstitute/` (create the folder if missing).
3. In the Unity Inspector, restrict the DLLs to **Editor** platform only to avoid build errors.
4. Reference them from your test `.asmdef` via *Assembly Definition References*.

### Guardrails are not running automatically

This is expected. Codex does not run Claude hooks. The guardrail files are
read-required policy documents, and verification happens through `/validate`,
MCP console checks, tests, graph validation, and reviewer passes.

### `/setup-project` did not generate test folders

Check `.codex/project/FEATURES.json`: `"testing"` must be `true`. The default ships as `true` (since 2026-05-26). If you opted out, flip the flag and re-run the scaffold steps from `/setup-project`.

### The knowledge graph isn't updating after edits

Confirm: (1) `.codex/project/FEATURES.json` has `"graph": true`; (2) `.codex/graph/graph-builder.sh` is executable; (3) run `/build-knowledge-graph --incremental` manually or `bash .codex/graph/graph-watch.sh` during a focused session.

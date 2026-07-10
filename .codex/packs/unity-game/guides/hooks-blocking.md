## Blocking Guardrail Reference

Codex does not run these as shell hooks. This table preserves the historical hook
suite as a checklist for `guardrails.md`, `/validate`, and reviewer passes.

| Hook | Blocks |
|------|--------|
| `block-git-push.sh` | `git push` — agents must not push; user always pushes manually |
| `block-scene-edit.sh` | Direct editing of `.unity`, `.prefab`, `.asset` files |
| `block-projectsettings.sh` | Direct editing of `ProjectSettings/*.asset`, `Packages/manifest.json`, or `Packages/packages-lock.json` |
| `guard-editor-runtime.sh` | `UnityEditor` namespace in runtime code without `#if UNITY_EDITOR` |
| `check-pure-csharp.sh` | `using UnityEngine` in pure service/domain files. Exempts Unity boundary and swappable-backend implementations: `*Provider`, `*View`, `*Controller`, `*Loader`, `*Dal`, `*Client`, `*Configuration`, `*Config`, `*Catalog`, `*Definition`, and event payload files |
| `check-no-monobehaviour-in-services.sh` | `MonoBehaviour` / `ScriptableObject` inheritance in service/domain folders; `*Loader`, `*Dal`, and `*Client` are Tier 4 swappable-backend boundaries, not Tier 3 services |
| `check-input-system.sh` | Legacy `Input.GetKey` / `Input.GetAxis` API |
| `check-vcontainer-singleton.sh` | Static singleton patterns outside of `EventBusAccessor` |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>`, `using UnityEngine.Events` |
| `check-time-scale.sh` | `Time.timeScale =` assignment — use IEventBus + PauseService instead |
| `check-enum-byte-base.sh` | `enum` without `: byte` base in ECS component or IEvent files — use `ushort` if 255+ values needed |
| `check-no-runtime-instantiate.sh` | `new GameObject(...)` in runtime C# |
| `guard-critical-files.sh` | Edits to existing `AppScope`, `InputService`, `AppModules`, `ConfigCatalog`, `IEventBus`, `EventBus`, `EventBusAccessor`, `*Installer`, `.asmdef` without investigation. Codex guardrails use deny-then-allow state: first run blocks and demands dependency mapping; the next run acknowledges the scoped edit. New files are allowed; test installers under `TestScopes/`, `EditModeTest`, or `PlayModeTest` are exempt |
| `check-config-protection.sh` | Modifications to `.asmdef`, `Codex configuration`, `.inputactions`, `manifest.json` — **exception: test assemblies (`EditModeTest`, `PlayModeTest`)** |
| `gateguard.sh` (historical pre-edit check) | Edit/Write on any C# file that has not been read in the current session |
| `guard-gate-cleared.sh` (historical pre-agent check) | Agent spawn blocked if `.codex/project/state/gate-cleared` is missing — Director Gate must be shown and `go` received before spawning any coder/fixer/committer agent |
| `guard-pipeline-direct-work.sh` (Codex state gate) | A cleared gate only proves the gate was shown, not that a pipeline agent executed. While `.codex/project/state/gate-cleared` exists and `.codex/project/state/subagent-depth` is `0`, direct changes to `_GameFolders/Scripts/**/*.cs` are blocked by `.codex/guardrails/run.sh`. Escape valve: `.codex/project/state/pipeline-override` with the explicit user-approved reason, consumed once |
| `guard-reviewer-order.sh` | Codex installed and no `.codex/project/state/codex-reviewed` marker → blocks `unity-reviewer` agent spawn; Codex review required first. |

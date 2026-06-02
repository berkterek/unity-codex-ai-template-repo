## Blocking Guardrail Reference

Codex does not run these as shell hooks. This table preserves the Claude hook
suite as a checklist for `guardrails.md`, `/validate`, and reviewer passes.

| Hook | Blocks |
|------|--------|
| `block-git-push.sh` | `git push` — agents must not push; user always pushes manually |
| `block-scene-edit.sh` | Direct editing of `.unity`, `.prefab`, `.asset` files |
| `guard-editor-runtime.sh` | `UnityEditor` namespace in runtime code without `#if UNITY_EDITOR` |
| `check-pure-csharp.sh` | `using UnityEngine` in `_Framework/` or `Games/Abstracts/` / `Games/Concretes/` (non-provider) |
| `check-input-system.sh` | Legacy `Input.GetKey` / `Input.GetAxis` API |
| `check-vcontainer-singleton.sh` | Static singleton patterns outside of `EventBusAccessor` |
| `check-unity-event.sh` | `UnityEvent`, `UnityEvent<T>`, `using UnityEngine.Events` |
| `check-time-scale.sh` | `Time.timeScale =` assignment — use IEventBus + PauseService instead |
| `check-enum-byte-base.sh` | `enum` without `: byte` base in ECS component or IEvent files — use `ushort` if 255+ values needed |
| `guard-critical-files.sh` | Edits to `AppScope`, `InputView`, `*Installer`, `IEventBus`, `.asmdef` without investigation — **exception: files under `TestScopes/`, `EditModeTest/`, or `PlayModeTest/` paths** |
| `check-config-protection.sh` | Modifications to `.asmdef`, `Codex configuration`, `.inputactions`, `manifest.json` — **exception: test assemblies (`EditModeTest`, `PlayModeTest`)** |
| `gateguard.sh` (PreToolUse) | Edit/Write on any C# file that has not been read in the current session |
| `guard-gate-cleared.sh` (PreToolUse) | Agent spawn blocked if `.codex/project/state/gate-cleared` is missing — Director Gate must be shown and `go` received before spawning any coder/fixer/committer agent |
| `guard-reviewer-order.sh` | Codex installed and no `.codex/project/state/codex-reviewed` marker → blocks `unity-reviewer` agent spawn; Codex review required first. |

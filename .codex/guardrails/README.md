# Codex Guardrails

Executable validators for rules that cannot be enforced by Codex hooks.

Markdown rule files remain the source of intent:

```text
.codex/packs/unity-game/rules/
.codex/packs/unity-game/guides/guardrails.md
```

This folder turns the most important rules into shell checks with exit codes.

## Usage

```bash
bash .codex/guardrails/run.sh --changed
bash .codex/guardrails/run.sh --staged
bash .codex/guardrails/run.sh --all
bash .codex/guardrails/run.sh --files Assets/Scripts/Foo.cs
```

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | No blocking findings. Warnings may still be printed. |
| `1` | One or more `BLOCK` findings. Stop and fix before proceeding. |
| `2` | Usage or environment error. |

## Current Checks

### BLOCK

- Direct text edits to `.unity`, `.prefab`, `.asset`
- Direct edits to `ProjectSettings/*.asset`, `Packages/manifest.json`, `Packages/packages-lock.json`, non-test `.asmdef`, and `.inputactions`
- `UnityEvent` / `UnityEngine.Events`
- Direct `Time.timeScale =`
- Static singleton patterns (`Instance`, `_instance`)
- Legacy Input API (`Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.mousePosition`)
- Runtime `UnityEditor` usage without `#if UNITY_EDITOR`
- `new SomeService()` inside MonoBehaviour
- `new GameObject(...)` in runtime C#
- `MonoBehaviour` / `ScriptableObject` inheritance in service/domain folders
- Concrete service constructor dependencies
- ECS/IEvent enums without `: byte`

### WARN

- `[SerializeField]` rename without `[FormerlySerializedAs]` in changed/staged diffs
- `GetComponent`, `Camera.main`, find calls, tag equality, message calls in hot paths
- LINQ in hot paths
- `Destroy(...)` outside Pool/Manager/Spawner files
- `async void` outside Unity lifecycle methods
- `async UniTask` method signatures without `CancellationToken`
- `?.` or `is null` on likely Unity objects
- `GetComponent` / `GetComponentInChildren` in `Awake`

## Test

```bash
bash .codex/guardrails/test/verify-guardrails.sh
bash .codex/guardrails/test/verify-integration.sh
```

The verifier includes positive controls for real violations and negative
controls for known false-positive cases:

- `IEventBus` plus a plain enum must not trigger the ECS/IEvent byte-base rule.
- `Plugins/`, `ThirdParty/`, `PackageCache/`, `_AssetFolders/`, `Editor/`,
  `Editors/`, and test paths are excluded from runtime-only checks.
- `*Installer.cs`, `*Scope.cs`, `*Provider.cs`, `*View.cs`, `*Controller.cs`,
  and `*Root.cs` may use Unity inheritance inside otherwise pure domain paths.

## Git Integration

Enable the local pre-commit hook once per clone:

```bash
git config core.hooksPath .githooks
```

The GitHub Actions workflow at `.github/workflows/guardrails.yml` runs the same
runner and both verifier scripts on push and pull request.

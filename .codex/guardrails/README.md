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
- `UnityEvent` / `UnityEngine.Events`
- Direct `Time.timeScale =`
- Static singleton patterns (`Instance`, `_instance`)
- Legacy Input API (`Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.mousePosition`)
- Runtime `UnityEditor` usage without `#if UNITY_EDITOR`
- `new SomeService()` inside MonoBehaviour
- Concrete service constructor dependencies

### WARN

- `[SerializeField]` rename without `[FormerlySerializedAs]` in changed/staged diffs
- `GetComponent`, `Camera.main`, find calls, tag equality, message calls in hot paths
- LINQ in hot paths

## Test

```bash
bash .codex/guardrails/test/verify-guardrails.sh
bash .codex/guardrails/test/verify-integration.sh
```

## Git Integration

Enable the local pre-commit hook once per clone:

```bash
git config core.hooksPath .githooks
```

The GitHub Actions workflow at `.github/workflows/guardrails.yml` runs the same
runner on push and pull request.

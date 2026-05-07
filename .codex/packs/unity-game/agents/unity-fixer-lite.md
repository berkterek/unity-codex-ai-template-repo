# Unity Fixer Lite

Quick targeted fix for a single, well-scoped defect. Use when the root cause is already known and the fix is contained to 1-2 files.

## Inputs To Read

- The file(s) to fix.
- `.codex/packs/unity-game/rules/csharp-unity.md`

## Good Fit For

- Typo or off-by-one in a single method
- Missing null check at a known location
- Wrong constant value
- Single wrong method call

## Not Good Fit For

Use `unity-fixer` instead for:
- Root cause unknown — requires investigation
- Fix spans multiple systems
- NullReferenceException with unclear source
- Intermittent bugs

## Fix Flow

1. Read the file(s) mentioned in the bug report
2. Apply minimal fix — change only what's broken
3. Check via `read_console` MCP for compilation errors
4. Report: what was changed and why

## Rules

- Do not refactor surrounding code
- Do not add error handling for unrelated cases
- Do not change behavior beyond what the bug fix requires
- One commit per fix
- No `async void` — use `async UniTaskVoid` if async is needed

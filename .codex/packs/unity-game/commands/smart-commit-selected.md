# Smart Commit Selected — Plan, Select & Commit

Analyzes uncommitted changes, groups them into logical atomic commits, shows a checklist, and commits **only the ones you select**.

## Usage

```
/smart-commit-selected
/smart-commit-selected "add audio system"
```

## Step 1 — Analyze

```bash
git status
git diff
git diff --cached
git log --oneline -5
```

If working tree is clean → stop: "Nothing to commit. Working tree is clean."

## Step 2 — Plan Commit Groups (DO NOT COMMIT YET)

Group all changed files into logical atomic commits by system/feature boundary:

- Infrastructure before logic before tests; docs go last
- Unity `.meta` files must be grouped with their asset
- Commit message format: `<type>(<scope>): <short description>`
- NEVER group unrelated files together

Print:

```
## Proposed Commits

[1] feat(audio): add AudioService and AudioInstaller
    Files: AudioService.cs, AudioInstaller.cs, IAudioService.cs

[2] fix(player): correct jump force calculation
    Files: PlayerService.cs
```

## Step 3 — Ask User to Select

Use the `AskUserQuestion` tool with `multiSelect: true`.

- One option per proposed commit group
- Label: the full commit message
- Description: list the files in that group

If the user selects nothing → stop: "No commits selected. Nothing was committed."

## Step 4 — Commit Selected Groups Only

- NEVER use `git add -A` or `git add .` — add specific files only
- NEVER touch files from unselected groups
- NEVER push — local commits only
- NEVER create empty commits

## Completion

```
## ✓ Committed
[N] commits created:
  [hash] — [message]

Skipped: [M] groups (not selected)
```

$ARGUMENTS

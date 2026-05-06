# Smart Commit — Analyze Changes and Commit Intelligently

Analyzes all uncommitted changes, groups them into logical atomic commits, and
commits them with well-crafted messages. Works on any dirty working tree.

## Usage

```
/smart-commit
/smart-commit "add audio system and event bus"   <- optional context hint
```

No argument needed. If provided, the argument is passed as context hint to help
understand the intent behind the changes.

---

## Step 1 — Check Working Tree

Run:

```bash
git status
git diff
git diff --cached
git log --oneline -5
```

If the working tree is clean → stop and print:

```
Nothing to commit. Working tree is clean.
```

---

## Step 2 — Commit

Act as the committer agent (`.codex/packs/unity-game/agents/committer.md`):

1. Read the git status and diff output from Step 1.
2. Read `.codex/project/PROJECT.md` to understand the project architecture.
3. Group the changed files into logical, atomic commits.
4. Execute the commits in dependency order.

### Commit Grouping Rules

- Group by system or feature boundary (e.g., all AudioSystem files together).
- Infrastructure before logic before tests.
- Never mix unrelated systems in one commit.
- Unity `.meta` files must be committed alongside their asset.

### Commit Message Format

```
<type>(<scope>): <short description>

<body — what was built, 2-4 lines max>
```

Types: `feat`, `fix`, `refactor`, `test`, `infra`, `config`, `docs`
Scope: the system or module name.

### Hard Rules

- NEVER use `git add -A` or `git add .` — add specific files only.
- NEVER push — local commits only.
- NEVER create empty commits.
- Every uncommitted file must end up in a commit — working tree must be clean
  when done.
- Docs updates go in a final `docs` commit.

---

## Completion

Print:

```
## Committed
[N] commits created:
  [hash] — [message]
  [hash] — [message]
  ...
Working tree: clean
```

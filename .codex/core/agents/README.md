# Core Agent Templates

These templates define project-agnostic agent roles for a Codex workflow.
They intentionally avoid language, framework, and architecture rules.

Project-specific rules belong in:

- `.codex/project/PROJECT.md`
- `.codex/project/CODING_CONVENTIONS.md`
- `.codex/project/TOOLING.md`
- `.codex/packs/<pack-name>/`

## Agents

| Agent | Purpose |
|-------|---------|
| `coder.md` | Implements assigned code or documentation changes. |
| `tester.md` | Writes and runs tests for assigned behavior. |
| `reviewer.md` | Reviews code, tests, architecture fit, and risks. |
| `committer.md` | Groups passed work into clean local commits. |

## Design Rules

- Core agents do not define coding style.
- Core agents do not select frameworks.
- Core agents do not assume Unity, C#, web, mobile, or backend.
- Core agents read project overlays before acting.
- Packs add technology-specific behavior on top of these templates.


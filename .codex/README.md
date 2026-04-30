# Codex Temp Workspace

This directory is a reusable Codex workflow template. It separates generic
agent orchestration from project-specific rules and technology packs.

## Layout

| Path | Purpose |
|------|---------|
| `core/agents/` | Project-agnostic agent role templates. |
| `core/commands/` | Project-agnostic workflow commands. |
| `core/protocols/` | Shared progress, event, mailbox, and checkpoint formats. |
| `project/` | Per-repository overlay files. Fill these for each project. |
| `templates/` | Copyable templates for project overlays. |
| `packs/` | Optional technology/domain packs such as Unity. |
| `manifests/` | Import notes and migration decisions. |

## How To Use

1. Keep `core/` stable and reusable.
2. Fill `project/` for the current repository.
3. Enable only the packs that match the repository.
4. Put coding style in `project/CODING_CONVENTIONS.md`, not in core.
5. Put project-specific folder/module structure in `project/STRUCTURE.md`.

## First-Time Setup In A Project

After copying `.codex/` into a repository, fill the project overlay files in
this order:

1. `project/PROJECT.md`
   - Project name, type, language, framework, target platforms.
   - Enabled packs, such as `unity-game`.
   - High-level goals and constraints.

2. `project/STRUCTURE.md`
   - Source roots.
   - Folder layout.
   - Module map.
   - Dependency boundaries.
   - File ownership rules.
   - Generated files and project-specific patterns.

3. `project/TOOLING.md`
   - Install, build, test, lint, format, and dev-server commands.
   - Narrow verification command for small changes.
   - Full verification command for risky/shared changes.

4. `project/CODING_CONVENTIONS.md`
   - Copy from `templates/CODING_CONVENTIONS.md` if useful.
   - Fill naming, namespace, async, DI, test, and platform-specific style.
   - Keep this project-specific. Do not put coding style in `core/`.

5. `project/RULES.md`
   - Hard rules that block completion.
   - Soft rules that guide implementation.
   - Security, performance, documentation, and review rules.

6. `project/WORKFLOW.md`
   - Phase/task plan.
   - Inputs, outputs, acceptance criteria, dependencies, and parallel groups.
   - This is what orchestration executes.

7. `project/PROGRESS.md`
   - Starts as `not-started`.
   - Orchestration updates it during execution.
   - Do not use it as the only recovery source once `EVENTS.jsonl` exists.

## Typical Codex Prompts

Use prompts like these after the overlay files are filled:

```text
Read .codex/README.md and .codex/project/*.md, then tell me what is missing
before this project is ready for Codex orchestration.
```

```text
Use .codex/core/commands/dry-run.md and preview the workflow in
.codex/project/WORKFLOW.md. Do not modify files.
```

```text
Use .codex/core/commands/orchestrate.md and execute Phase 1 from
.codex/project/WORKFLOW.md. Follow the project overlay and enabled packs.
```

```text
Use .codex/core/commands/status.md and report the current workflow state.
```

```text
Use .codex/core/commands/continue.md and resume from .codex/project/EVENTS.jsonl
and .codex/runtime checkpoints.
```

## What Goes Where

| Need | Put It Here |
|------|-------------|
| How agents coordinate | `core/` |
| Project identity and goals | `project/PROJECT.md` |
| Folder/module/ownership map | `project/STRUCTURE.md` |
| Build/test/lint commands | `project/TOOLING.md` |
| Coding style | `project/CODING_CONVENTIONS.md` |
| Repo-specific hard rules | `project/RULES.md` |
| Phase/task execution plan | `project/WORKFLOW.md` |
| Runtime status | `project/PROGRESS.md` and `project/EVENTS.jsonl` |
| Technology-specific guidance | `packs/<pack-name>/` |
| Reusable fill-in templates | `templates/` |

## Separation Rule

- Core answers: how agents coordinate, report, review, resume, and commit.
- Project overlay answers: how this repository is organized and verified.
- Packs answer: how a specific technology stack should be handled.

When unsure where something belongs, prefer `project/` first. Promote it to a
pack only after it proves reusable across multiple repositories.

## Practical Rule

Do not start by editing `core/`. Start by filling `project/`.

If an instruction is true only for one repository, put it in `project/`.
If it is true for one technology stack, put it in `packs/`.
If it is true for every repository using this workflow, then it can belong in
`core/`.

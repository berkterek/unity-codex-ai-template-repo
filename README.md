# Unity Codex AI Template

Reusable `.codex` workflow template for Unity projects. The template separates
generic Codex orchestration from project-specific rules and Unity-specific
guidance.

## What This Is

This repository is a starting point for AI-assisted project work with Codex.
It provides:

- Core agent role templates.
- Core workflow command templates.
- Progress, event, mailbox, and checkpoint protocols.
- Project overlay files that each Unity project fills in.
- A small Unity pack for Unity MCP, New Input System, serialization safety, and
  setup rules.
- Coding convention templates.

## Folder Layout

```text
.codex/
├── README.md
├── core/
│   ├── agents/
│   ├── commands/
│   └── protocols/
├── project/
│   ├── PROJECT.md
│   ├── STRUCTURE.md
│   ├── WORKFLOW.md
│   ├── TOOLING.md
│   ├── RULES.md
│   ├── CODING_CONVENTIONS.md
│   └── PROGRESS.md
├── templates/
│   └── CODING_CONVENTIONS.md
├── packs/
│   └── unity-game/
│       ├── README.md
│       ├── agents/
│       │   └── unity-setup.md
│       └── guides/
│           ├── unity-mcp.md
│           ├── input-system.md
│           └── serialization-safety.md
└── manifests/
```

## Core Idea

- `core/` is reusable and should stay stable.
- `project/` is filled per repository.
- `packs/` contains technology-specific guidance, such as Unity.
- `templates/` contains reusable fill-in documents.
- `manifests/` records import and migration decisions.

Do not put project-specific coding style into `core/`. Put it in
`.codex/project/CODING_CONVENTIONS.md`.

Do not put project-specific folder or module structure into `core/`. Put it in
`.codex/project/STRUCTURE.md`.

Do not put full gameplay, genre, platform, engine-system, or third-party package
references into the base template. Keep those as optional per-project packs.

## Unity Pack

The included Unity pack is intentionally small and reusable:

```text
.codex/packs/unity-game/
```

It includes:

- `agents/unity-setup.md`: Unity Editor, scene, prefab, asset, and runtime setup
  agent guidance.
- `guides/unity-mcp.md`: Unity MCP workflow, batching, console checks, and MCP
  vs file-edit rules.
- `guides/input-system.md`: New Input System as the default input approach for
  new Unity projects.
- `guides/serialization-safety.md`: serialized field rename, prefab, asset, and
  ScriptableObject safety rules.

The base template does not include large genre or package-specific references.
Those should be added only when a project needs them.

## First-Time Use In A Unity Project

1. Copy the `.codex/` folder into your Unity project root.
2. Open `.codex/README.md`.
3. Fill `.codex/project/PROJECT.md`.
4. Fill `.codex/project/STRUCTURE.md`.
5. Fill `.codex/project/TOOLING.md`.
6. Fill `.codex/project/CODING_CONVENTIONS.md`.
7. Fill `.codex/project/RULES.md`.
8. Create a phase/task plan in `.codex/project/WORKFLOW.md`.
9. Ask Codex to dry-run or execute the workflow.

Example prompt:

```text
Read .codex/README.md and .codex/project/*.md, then tell me what is missing
before this Unity project is ready for Codex orchestration.
```

Dry run prompt:

```text
Use .codex/core/commands/dry-run.md and preview the workflow in
.codex/project/WORKFLOW.md. Do not modify files.
```

Execution prompt:

```text
Use .codex/core/commands/orchestrate.md and execute Phase 1 from
.codex/project/WORKFLOW.md. Follow the project overlay and enabled packs.
```

## Important Files

| File | Purpose |
|------|---------|
| `.codex/project/PROJECT.md` | Project identity, goals, enabled packs. |
| `.codex/project/STRUCTURE.md` | Folder layout, modules, ownership, generated files. |
| `.codex/project/TOOLING.md` | Build, test, lint, format, and Unity commands. |
| `.codex/project/RULES.md` | Repository-specific hard and soft rules. |
| `.codex/project/CODING_CONVENTIONS.md` | Concrete coding style for the project. |
| `.codex/project/WORKFLOW.md` | Phase/task execution plan. |
| `.codex/project/PROGRESS.md` | Human-readable orchestration status. |
| `.codex/packs/unity-game/README.md` | Unity pack overview. |
| `.codex/packs/unity-game/guides/unity-mcp.md` | Unity MCP workflow and verification loop. |
| `.codex/packs/unity-game/guides/input-system.md` | New Input System default guidance. |
| `.codex/packs/unity-game/guides/serialization-safety.md` | Unity serialized data safety rules. |

## Recommended `.gitignore`

If you use this template inside a project, ignore runtime state:

```gitignore
.DS_Store
.codex/runtime/
.codex/project/EVENTS.jsonl
```

`PROGRESS.md` can stay committed as the initial template state.

## Status

This is a template repo. It is intended to be copied into other Unity projects
and customized through `.codex/project/`.

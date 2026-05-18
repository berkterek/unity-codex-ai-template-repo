# Unity Codex AI Template

A ready-to-use Codex CLI template for Unity projects. Copy the `.codex/` folder
into any Unity project to get AI-assisted workflows, code quality rules, and
slash commands instantly.

---

## Table of Contents

- [What This Is](#what-this-is)
- [Quick Start](#quick-start)
- [Required Stack](#required-stack)
- [Folder Layout](#folder-layout)
- [Guardrails — Hook Equivalents](#guardrails--hook-equivalents)
- [Reviewer — Claude](#reviewer--claude)
- [Agent List](#agent-list)
- [Command List](#command-list)
- [Rules and Guides](#rules-and-guides)
- [New Project Setup](#new-project-setup)
- [Architecture Overview](#architecture-overview)

---

## What This Is

Codex CLI reads `AGENTS.md` and `.codex/` at the project root. This template
ships that folder pre-configured with:

- **Guardrails** — Hook equivalents: BLOCK (git push, .unity text edit, UnityEvent, static singleton), WARN (async void, hot-path alloc, LINQ, null propagation), GATE (Director Gate, reviewer requirement)
- **Agents** — Specialized AI roles: `unity-coder`, `unity-fixer`, `unity-reviewer` (Claude-based), `unity-tester`, `unity-setup` and 25+ more
- **Commands** — Slash commands for common workflows: `/implement`, `/fix`, `/review-code`, `/architect`, `/new-module`, `/smart-commit` and 48+ more
- **Rules** — Architecture, naming, testing, ECS, serialization, and Addressables standards
- **Skills** — 62 skill files: audio, URP, Cinemachine, VContainer, UniTask, DOTween, and more

---

## Quick Start

### 1. Copy into your project

```
your-unity-project/
├── AGENTS.md          ← Root config read by Codex
└── .codex/
    ├── project/       ← Fill in per project
    ├── packs/
    │   └── unity-game/
    │       ├── agents/
    │       ├── commands/
    │       ├── rules/
    │       ├── guides/
    │       └── skills/
    ├── core/
    └── templates/
```

### 2. Fill in project overlay files

```
/setup-project
```

or manually:

```
.codex/project/PROJECT.md            ← Project name, type, platform, enabled packs
.codex/project/STRUCTURE.md          ← Folder layout, modules, ownership
.codex/project/TOOLING.md            ← Build, test, lint commands
.codex/project/CODING_CONVENTIONS.md
.codex/project/RULES.md
```

### 3. Start developing

```
/implement <feature description>
/fix <bug description>
/architect
```

---

## Required Stack

These packages must be installed in the Unity project:

| Package | Source | Purpose |
|---------|--------|---------|
| **VContainer** | OpenUPM | DI — replaces all singletons |
| **UniTask** | OpenUPM | Async/await — replaces all coroutines |
| **New Input System** | Package Manager (`com.unity.inputsystem`) | Input — legacy API fully forbidden |

### Optional

| Package | Feature Flag | Description |
|---------|-------------|-------------|
| Addressables | `addressables` | `Resources.Load` forbidden, async loading required |
| NSubstitute | `testing` | EditMode/PlayMode test infrastructure |
| Unity ECS DOTS | `ecs` | ECS folder, asmdef, and rule set |

---

## Folder Layout

```
.codex/
├── core/
│   ├── agents/          coder, tester, reviewer, committer
│   ├── commands/        orchestrate, continue, dry-run, status, stop, validate
│   └── protocols/       checkpoint, event-journal, mailbox, progress
├── packs/
│   └── unity-game/
│       ├── agents/      29 Unity specialist agents
│       ├── commands/    48 Unity slash commands
│       ├── rules/       10 rule files
│       ├── guides/      7 guides (including guardrails)
│       └── skills/      62 skill files
├── project/             Per-project overlay — fill in each project
├── templates/           GDD, TDD, CODING_CONVENTIONS templates
└── manifests/           Import and migration decisions
```

---

## Guardrails — Hook Equivalents

Codex has no Claude Code hook mechanism. `.codex/packs/unity-game/guides/guardrails.md`
fills that gap. Every agent and command reads this file at startup.

### BLOCK — Never Do

| Rule | Reason |
|------|--------|
| Run `git push` | User always pushes manually |
| Text-edit `.unity` / `.prefab` / `.asset` | Breaks serialized references |
| Use `UnityEvent` | Use `IEventBus` instead |
| Directly assign `Time.timeScale` | Use `IEventBus + PauseService` |
| Static singleton (`static Instance`) | VContainer is the only DI mechanism |
| `UnityEditor` namespace without `#if UNITY_EDITOR` | Player build crashes |
| Weaken config files | Fix the code, not the config |

### WARN — Flag and Continue

`async void`, `GetComponent` in Awake, legacy Input API, hot-path LINQ/allocation,
`?.`/`??` on Unity objects, namespace format violation, naming convention violation,
`SerializeField` rename without `FormerlySerializedAs`, missing test file.

### GATE — Verify Before Proceeding

Pipeline cannot start without Director Gate. `unity-reviewer` is required before every commit.

---

## Reviewer — Claude

Code review in this template is performed by **Claude** (`unity-reviewer` agent).

Review scope:
- Unity compilation verification (MCP: `refresh_unity` + `read_console`)
- Runtime validation (MCP: enter/exit Play mode, console error check)
- Architecture, UI compliance, performance, rendering/GPU, C# quality, encapsulation
- Input System compliance (legacy API forbidden, Enable/Disable pairing)
- Unused code detection (private members, public members, using directives, parameters)
- PASS / FAIL verdict — Critical and Major issues cause FAIL

---

## Agent List

### Core (`.codex/core/agents/`)

`coder` · `tester` · `reviewer` · `committer`

### Unity Specialist (`.codex/packs/unity-game/agents/`)

| Agent | Role |
|-------|------|
| `unity-coder` | MonoBehaviour, provider, installer, scene wiring |
| `unity-coder-lite` | Small C# changes |
| `unity-fixer` | Bug — root cause + regression test + fix |
| `unity-fixer-lite` | Fast single-file fix |
| `unity-reviewer` | **Full Claude-based reviewer** |
| `unity-tester` | EditMode / PlayMode test authoring |
| `unity-test-runner` | Test execution and reporting |
| `unity-test-builder` | PlayMode test scene creation |
| `unity-developer` | Full cycle: coder + tester + reviewer |
| `unity-setup` | Scene, prefab, asset, Unity settings setup |
| `unity-scene-builder` | Scene hierarchy creation |
| `unity-ui-builder` | UI Toolkit / UGUI panel and view |
| `unity-shader-dev` | Shader Graph and HLSL |
| `unity-network-dev` | Network layer |
| `unity-optimizer` | Performance profiling and optimization |
| `unity-linter` | Code quality and rule compliance |
| `unity-critic` | Architecture and design critique |
| `unity-verifier` | 3-iteration verification loop |
| `unity-scout` | Codebase exploration |
| `unity-prototyper` | Rapid prototype |
| `unity-migrator` | Unity version and render pipeline migration |
| `unity-git-master` | Git operations |
| `unity-build-runner` | Build pipeline |
| `unity-security-reviewer` | Security scanning |
| `debugger` | Debug process |
| `migrator` | Coroutine→UniTask, Singleton→VContainer pattern migration |
| `silent-failure-hunter` | Silent failure detection |
| `audio-clip-agent` | Batch AudioClip import settings |
| `graphics-setup-agent` | URP / graphics settings setup |
| `package-analyzer` | Package dependency analysis |

---

## Command List

### Core

`/orchestrate` · `/continue` · `/dry-run` · `/status` · `/stop` · `/validate`

### Unity — Planning

`/architect` · `/create-plan` · `/update-plan` · `/plan-workflow` · `/game-idea` · `/refine-gdd` · `/refine-tdd` · `/adr`

### Unity — Implementation

`/implement` · `/add-feature` · `/new-module` · `/fix` · `/fix-deep` · `/scene-setup` · `/create-prefab-scene` · `/unity-scene-update` · `/update-scene-hierarchy` · `/setup-project`

### Unity — Testing

`/generate-tests` · `/create-test` · `/qa` · `/debug-session`

### Unity — Review & Quality

`/review-code` · `/clean-slop` · `/performance-audit` · `/check-portability` · `/silent-failure-hunt`

### Unity — Git

`/smart-commit` · `/create-changelog`

### Unity — Utilities

`/catch-up` · `/learn` · `/discover` · `/search` · `/context-prime` · `/checkpoint` · `/migrate` · `/migrator` · `/graphics-setup` · `/audio-clip-setup` · `/instincts` · `/dump` · `/caveman` · `/five` · `/grill-me` · `/ralph` · `/mermaid`

---

## Rules and Guides

### Rules (`.codex/packs/unity-game/rules/`)

| File | Covers |
|------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputView, AppScope |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw calls, UI canvas |
| `testing.md` | EditMode/PlayMode/ECS/NoTest decision tree, NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform defines, lifecycle order |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent forbidden, IEventBus vs Action vs C# event |
| `scene-hierarchy.md` | 6 required root containers, prefab domain, logic/visual separation |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | No Resources.Load, async loading, handle lifecycle |

### Guides (`.codex/packs/unity-game/guides/`)

| File | Covers |
|------|--------|
| `guardrails.md` | **BLOCK/WARN/GATE rules as hook equivalents** |
| `director-gates.md` | Pipeline gates and pass conditions |
| `unity-mcp.md` | MCP tool usage guide |
| `input-system.md` | New Input System implementation guide |
| `serialization-safety.md` | Safe serialization change guide |
| `nsubstitute.md` | NSubstitute usage guide |
| `vcontainer.md` | VContainer DI guide |

---

## New Project Setup

```bash
# 1. Clone this repo or copy .codex/ and AGENTS.md into your Unity project
git clone <this-repo> your-unity-project
cd your-unity-project

# 2. Run the setup command
/setup-project

# 3. Start developing
/implement <feature description>
```

---

## Architecture Overview

```
Unity Scene
    └── LifetimeScope (VContainer)
            ├── AppScope          — application-wide dependencies
            ├── ModuleInstaller   — module registrations
            └── Providers         — Unity API bridges
                    │
                    ↓
            Pure C# Services      — IEventBus, business logic
                    │
                    ↓
            InputView             — New Input System → service methods
```

- **No singletons** — VContainer `Lifetime.Singleton`
- **No coroutines** — `async UniTask`
- **No legacy input** — New Input System, InputView pattern
- **No UnityEngine in service layer** — Provider pattern

---

## License

MIT

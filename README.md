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
- [Executable Guardrails](#executable-guardrails)
- [Knowledge Graph](#knowledge-graph)
- [Reviewer](#reviewer)
- [Agent List](#agent-list)
- [Model Routing](#model-routing)
- [Command List](#command-list)
- [Rules and Guides](#rules-and-guides)
- [Skills](#skills)
- [New Project Setup](#new-project-setup)
- [Architecture Overview](#architecture-overview)

---

## What This Is

Codex CLI reads `AGENTS.md`, `.codex/`, and repo-scoped `.agents/skills/` at the project root. This template
ships that folder pre-configured with:

- **Guardrails** — Hook equivalents: BLOCK (git push, .unity text edit, UnityEvent, static singleton, MonoBehaviour business logic), WARN (async void, SOLID/OOP drift, hot-path alloc, LINQ, null propagation), GATE (Director Gate, reviewer requirement)
- **Agents** — Specialized AI roles: `unity-coder`, `unity-fixer`, `unity-reviewer`, `tester`, `committer`, `unity-setup` and 28+ more
- **Commands** — Slash commands for common workflows: `/implement`, `/fix`, `/fix-lite`, `/fix-codex`, `/roadmap`, `/plan-module`, `/orchestrate`, `/build-knowledge-graph`, `/smart-commit-selected` and 55+ more
- **Rules** — Architecture, SOLID/OOP, naming, testing, ECS, serialization, Addressables, bootstrap, async, input, lifecycle, and prefab standards
- **Skills** — 71 skill files: audio, URP, Cinemachine, Netcode, ProBuilder, VContainer, UniTask, DOTween, Unity git, UGUI, VFX, SOLID/OOP, and more

---

## Quick Start

### 1. Copy into your project

```
your-unity-project/
├── AGENTS.md          ← Root config read by Codex
├── .agents/
│   └── skills/        ← Codex command wrappers
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
/roadmap
/plan-module 01
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
├── guardrails/          Executable BLOCK/WARN validators for Codex
├── graph/               Optional Unity knowledge graph tools and validators
├── packs/
│   └── unity-game/
│       ├── agents/      34 Unity specialist agents
│       ├── commands/    62 Unity slash commands
│       ├── rules/       16 rule files
│       ├── guides/      21 guides (including guardrails)
│       └── skills/      71 skill files
├── project/             Per-project overlay — fill in each project
├── templates/           GDD, TDD, CODING_CONVENTIONS, module plan templates
└── manifests/           Import and migration decisions
```

---

## Guardrails — Hook Equivalents

Codex has no automatic edit-hook mechanism. `.codex/packs/unity-game/guides/guardrails.md`
fills that gap. Every agent and command reads this file at startup.

### BLOCK — Never Do

| Rule | Reason |
|------|--------|
| Run `git push` | User always pushes manually |
| Text-edit `.unity` / `.prefab` / `.asset` | Breaks serialized references |
| Use `UnityEvent` | Use `IEventBus` instead |
| Directly assign `Time.timeScale` | Use `IEventBus + PauseService` |
| Static singleton (`static Instance`) | VContainer is the only DI mechanism |
| Business logic in MonoBehaviour | MonoBehaviour is limited to shell/provider roles |
| `new SomeService()` / `new SomeProvider()` | Dependencies must come from VContainer injection |
| `*Handler : MonoBehaviour` | Handlers are pure C# |
| `*Module : ScriptableObject` | Modules are static classes |
| Concrete service constructor dependencies | Depend on interfaces for DIP and testability |
| `UnityEditor` namespace without `#if UNITY_EDITOR` | Player build crashes |
| Weaken config files | Fix the code, not the config |

### WARN — Flag and Continue

`async void`, `GetComponent` in Awake, legacy Input API, SOLID/OOP drift, long
MonoBehaviours, hot-path LINQ/allocation, `?.`/`??` on Unity objects, namespace
format violation, naming convention violation, `SerializeField` rename without
`FormerlySerializedAs`, missing test file.

### GATE — Verify Before Proceeding

Pipeline cannot start without Director Gate. `unity-reviewer` is required before every commit.

---

## Executable Guardrails

Codex cannot run edit hooks on every edit, so this template provides a
real shell gate:

```bash
bash .codex/guardrails/run.sh --changed
bash .codex/guardrails/run.sh --staged
bash .codex/guardrails/run.sh --files Assets/Scripts/Foo.cs
```

Output uses `BLOCK` and `WARN` lines. Any `BLOCK` exits `1`; warnings exit `0`
but must be reported. `/validate`, `/qa`, and `/smart-commit` are documented to
run this before proceeding.

Test the guardrails with:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
```

Enable the local pre-commit safety net with:

```bash
git config core.hooksPath .githooks
```

The repository also includes `.github/workflows/guardrails.yml` so PR/push
checks run the same guardrail runner.

---

## Knowledge Graph

The optional Unity knowledge graph lives under `.codex/graph/` and is enabled
per project through `.codex/project/FEATURES.json`.

```bash
/build-knowledge-graph --full
/knowledge-graph summary
```

The builder prefers the pure-Python `.codex/graph/graph-builder.py` path and
falls back to `.codex/graph/graph-builder.sh` when needed. MCP extraction can
merge scene and prefab data into the graph when the Unity Editor is open.

---

## Reviewer

Code review in this template is performed by the `unity-reviewer` agent.

Review scope:
- Unity compilation verification (MCP: `refresh_unity` + `read_console`)
- Runtime validation (MCP: enter/exit Play mode, console error check)
- Architecture, UI compliance, performance, rendering/GPU, C# quality, encapsulation
- Input System compliance (legacy API forbidden, `InputService` owns generated controls)
- Unused code detection (private members, public members, using directives, parameters)
- PASS / FAIL verdict — Critical and Major issues cause FAIL

---

## Agent List

### Core (`.codex/core/agents/`)

`coder` · `tester` · `reviewer` · `committer`

### Unity Specialist (`.codex/packs/unity-game/agents/`)

| Agent | Role |
|-------|------|
| `unity-coder` | MonoBehaviour shell, provider, static module wiring, scene wiring |
| `unity-coder-lite` | Small C# changes |
| `unity-fixer` | Bug — root cause + regression test + fix |
| `unity-fixer-lite` | Fast single-file fix |
| `unity-reviewer` | **Full Unity reviewer** |
| `tester` | EditMode / PlayMode test authoring — NUnit, hand-rolled fakes, AAA pattern |
| `committer` | Smart phase commits — groups by system boundary, dependency-ordered |
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
| `lean-planner` | Compact 3-5 task plan — no code skeletons, no acceptance criteria |
| `unity-particle-designer` | VFX particle effects — prefab, pool, VFX service wiring |
| `unity-ui-toolkit-builder` | Editor-only UI Toolkit: EditorWindow, CustomEditor, UXML, USS |

---

## Model Routing

Default Codex model selection is intentionally simple:

| Work Type | Model |
|-----------|-------|
| Plan-writing agents and planning commands | **GPT-5.5** |
| All non-lite implementation, review, verification, setup, test, critique, and debug work | **GPT-5.4** |
| Lite agents, scout, linter, short summaries, and low-risk lookup | **GPT-5.3** |

`--lite` and `--quick` choose GPT-5.3 for safe, scoped work. `--heavy`
returns implementation/fix/orchestration workers to GPT-5.4 when they would
otherwise use a lite path. GPT-5.5 is reserved for producing or revising plans.

---

## Command List

### Core

`/orchestrate` · `/continue` · `/dry-run` · `/status` · `/stop` · `/validate`

### Unity — Planning

`/architect` · `/create-plan` · `/update-plan` · `/roadmap` · `/plan-module` · `/plan-workflow` legacy · `/game-idea` · `/refine-gdd` · `/refine-tdd` · `/adr`

### Unity — Implementation

`/implement` · `/implement-lite` · `/add-feature` · `/new-module` · `/fix` · `/fix-lite` · `/fix-deep` · `/fix-codex` · `/game-plan` legacy · `/scene-setup` · `/create-prefab-scene` · `/unity-scene-update` · `/update-scene-hierarchy` · `/setup-project`

### Unity — Testing

`/generate-tests` · `/create-test` · `/qa` · `/debug-session` · `/debugger`

### Unity — Review & Quality

`/review-code` · `/clean-slop` · `/performance-audit` · `/check-portability` · `/silent-failure-hunter`

### Unity — Git

`/smart-commit` · `/smart-commit-selected` · `/create-changelog` · `/update-agents-md`

### Unity — Utilities

`/catch-up` · `/learn` · `/discover` · `/search` · `/context-prime` · `/checkpoint` · `/migrate` · `/migrator` · `/graphics-setup` · `/audio-clip-setup` · `/instincts` · `/dump` · `/caveman` · `/five` · `/grill-me` · `/ralph` · `/mermaid` · `/update-rules` · `/build-knowledge-graph` · `/knowledge-graph`

---

## Rules and Guides

### Rules (`.codex/packs/unity-game/rules/`)

| File | Covers |
|------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputService, AppScope |
| `solid-oop.md` | MonoBehaviour View/Provider boundaries, SRP, OCP, DIP |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw calls, UI canvas |
| `testing.md` | EditMode/PlayMode/ECS/NoTest decision tree, NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform defines, lifecycle order |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent forbidden, IEventBus vs Action vs C# event |
| `scene-hierarchy.md` | 6 required root containers, prefab domain, logic/visual separation |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | No Resources.Load, async loading, handle lifecycle |
| `bootstrap-pattern.md` | Static Module hierarchy — ConfigCatalog, AppModules, AppScope, GameScope |
| `unity-async.md` | UniTask, cancellation, fire-and-forget, coroutine migration |
| `unity-input.md` | New Input System hard rules and InputService/InputHandler pattern |
| `unity-lifecycle.md` | Editor/runtime boundary, platform defines, DOTween cleanup |
| `unity-prefabs.md` | Prefab ownership, variants, BaseCanvas, package prefab duplication |

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
| `architecture-summary.md` | Quick architecture and workflow overview |
| `context-management.md` | Checkpoint/resume and state conventions |
| `knowledge-graph.md` | Graph builder/query usage and extractor notes |
| `quick-start.md` | New/existing project setup workflow |
| `setup-checklist.md` | Manual setup checklist after `/setup-project` |
| `agents-index.md` | Agent reference index |
| `commands.md` | Command reference index |
| `commands-as-skills.md` | Repo-scoped command skill wrapper guide |
| `hooks-blocking.md` | Historical blocking hook checklist preserved as Codex guardrail reference |
| `hooks-warning.md` | Historical warning hook checklist preserved as Codex guardrail reference |
| `model-tiers.md` | Model routing guidance |
| `orchestrate-rules.md` | Orchestration rule reference |
| `skills-index.md` | Skill library index |
| `subagents.md` | Native Codex subagent wrapper usage guide |

---

## Skills

Skills live under `.codex/packs/unity-game/skills/` and are read-only reference files that inform agent decisions — they do not execute code. Commands load them on demand.

### Core (`skills/core/`)

| Skill | Covers |
|-------|--------|
| `model-routing` | Automatic model selection heuristics — file count, complexity, risk factors |
| `deep-interview` | 5-dimension ambiguity gating before implementation starts |
| `learner` | Post-debug insight extraction — writes findings to project notes |
| `unity-instincts` | Instinct system for learned Unity patterns — capture, score, promote, apply |
| `assembly-definitions` | .asmdef authoring — references, platforms, define constraints |
| `source-driven-development` | Fetch official Unity docs before writing API calls — cites sources, flags deprecated APIs |
| `documentation-and-adrs` | ADR creation — `/adr` command writes to `docs/decisions/`, lifecycle management |
| `planning-and-task-breakdown` | Vertical slice decomposition + per-task acceptance criteria |
| `code-simplification` | Chesterton's Fence discipline for `/clean-slop` — understand before removing |
| `commit-trailers` | Conventional commit trailers — co-author, ticket links, sign-off |
| `event-systems` | IEventBus patterns — pub/sub, struct events, subscribe/unsubscribe lifecycle |
| `event-bus` | Project-specific IEventBus implementation — location, namespace, code examples |
| `solid-oop` | MonoBehaviour View/Provider boundaries, SRP one-sentence test, OCP, DIP |
| `logging` | Project-specific DLog pattern — logging implementation, location, and usage |
| `save-load` | Project-specific SaveLoadSystem pattern — location, namespace, and usage |
| `tdd-nsubstitute` | Project-specific TDD pattern — assembly structure, test templates, mock rules |
| `hud-statusline` | In-session status line rendering for pipeline progress |
| `object-pooling` | ObjectPool<T> setup, return-to-pool patterns, warm-up |
| `scriptable-objects` | ScriptableObject config authoring, CreateAssetMenu, validation |
| `serialization-safety` | FormerlySerializedAs, SerializeReference, Unity null semantics |
| `unity-mcp-patterns` | MCP tool call patterns for scene/prefab/asset operations |
| `playmode-scene-testing` | Play Mode scene test pattern — TestBootstrap prefab, TestScope, UnityTest patterns |
| `mcp-preflight` | 3-state MCP availability check — connected / disconnected / not installed |
| `test-type-router` | Determines test type (EditMode / PlayMode-ECS / PlayMode-Programmatic / PlayMode-Scene / NoTest) |
| `caveman` | Plain-language explanation mode |
| `context-prime` | Context priming — loads project structure and key patterns |
| `create-changelog` | Changelog generation from git history |
| `dump` | Context dump — exports current session state |
| `five` | Quick 5-minute codebase summary |
| `grill-me` | Codebase interrogation mode |
| `mermaid` | Mermaid diagram generation |
| `knowledge-graph-hybrid` | Routes call-graph queries through graph MCP tools with CLI fallback |
| `bootstrap-pattern` | Project-specific VContainer bootstrap reference |
| `input-system` | Project-specific InputService/InputHandler input action reference |
| `scene-hierarchy` | Scene container and placement reference |
| `unity-git` | Unity-aware git hygiene and commit grouping |
| `unity-ugui` | UGUI setup and conventions |

### Platform (`skills/platform/`)

| Skill | Covers |
|-------|--------|
| `mobile` | Touch input, safe area, haptics, app lifecycle |

### Systems (`skills/systems/`)

| Skill | Covers |
|-------|--------|
| `addressables` | Loading, handle lifecycle, label groups, preload |
| `animation` | Animator parameters, state machine behaviours, blend trees |
| `audio` | AudioMixer groups, snapshots, pooled AudioSource, spatial audio |
| `audio-mixer` | AudioMixer routing, exposed parameters, ducking, snapshot transitions |
| `audio-settings` | Audio settings UI, volume persistence, IAudioSettingsService + VContainer wiring |
| `audio-clip-settings` | AudioClip import settings — PCM/ADPCM/Vorbis format, load type, platform overrides |
| `cinemachine` | Virtual cameras, blends, impulse, follow targets |
| `navmesh` | NavMeshAgent setup, dynamic obstacles, off-mesh links |
| `physics` | Layer matrix, non-alloc queries, trigger vs collision |
| `particle-vfx` | ParticleSystem/VFX authoring and pooling reference |
| `shader-graph` | URP shader nodes, property exposure, keyword variants |
| `ui-toolkit` | USS, UXML, data binding, runtime panel setup |
| `urp-pipeline` | Renderer features, camera stacking, custom render passes, SRP Batcher, Forward+ |
| `urp-quality-settings` | URP quality tiers, runtime asset swap, auto-detect, adaptive performance |
| `urp-lighting-shadows` | Directional/point/spot lights, shadow cascades, light layers, reflection probes |
| `urp-post-processing` | Bloom, DOF, Motion Blur, SSAO, Tonemapping, Color Grading, Vignette |
| `urp-volume` | URP Volume creation/configuration via MCP `manage_graphics` |
| `audio-mixer-mcp` | AudioMixer exposed parameters, AudioSource routing via MCP |
| `srp-batcher-mcp` | SRP Batcher enable/verify, UI Raycast Target audit via MCP |

### Third-Party (`skills/third-party/`)

| Skill | Covers |
|-------|--------|
| `dotween` | Tween creation, sequences, callbacks, memory management |
| `netcode` | Netcode for GameObjects 2.x lifecycle, RPCs, NetworkVariable, spawning |
| `nsubstitute` | NSubstitute mock setup, argument matchers, received verification |
| `odin-inspector` | Custom attributes, validators, group drawers |
| `probuilder` | ProBuilder in-editor mesh modeling, API, prefab integration |
| `textmeshpro` | Font assets, rich text, SDF materials, localization |
| `unitask` | Async patterns, cancellation, `Forget()`, UniTaskVoid |
| `vcontainer` | Scope hierarchy, registration patterns, `IInitializable`/`IDisposable` lifecycle |
| `unity-asmdef` | Assembly definition authoring, references, define constraints |
| `unity-editor-tools` | Custom Editor windows, PropertyDrawers, EditorUtility patterns |
| `unity-uitoolkit` | UI Toolkit runtime panels, UXML, USS, data binding |

### Plugins (`skills/plugins/`)

| Skill | Covers |
|-------|--------|
| `odin-inspector` | Custom attributes, validators, group drawers |
| `primetween` | PrimeTween setup, tween API, sequences, UniTask integration |
| `r3` | R3 (Cysharp) Observable, Subject, ReactiveProperty, UniTask integration |
| `unitask` | Async patterns, cancellation, `Forget()`, UniTaskVoid |

---

## New Project Setup

```bash
# 1. Clone this repo or copy .codex/ and AGENTS.md into your Unity project
git clone <this-repo> your-unity-project
cd your-unity-project

# 2. Run the setup command
/setup-project

# 3. Start developing
/game-idea
/architect
/roadmap
/plan-module 01
/orchestrate docs/modules/01-core-loop/tasks.md
```

---

## Architecture Overview

```
Unity Scene
    └── LifetimeScope (VContainer)
            ├── AppScope          — validates ConfigCatalog
            ├── AppModules        — static module registration order
            ├── [Domain]Module    — static Install(builder, config)
            └── Providers         — Unity API bridges
                    │
                    ↓
            Pure C# Services      — IEventBus, business logic
                    │
                    ↓
            InputService/Handlers — New Input System → service methods
```

- **No singletons** — VContainer `Lifetime.Singleton`
- **No MonoBehaviour business logic** — MonoBehaviour is shell/provider only
- **No concrete service dependencies** — Constructors depend on interfaces
- **No coroutines** — `async UniTask`
- **No legacy input** — New Input System, InputService/InputHandler pattern
- **No UnityEngine in service layer** — Provider pattern

---

## License

Copyright (c) 2026 Berk Terek — All rights reserved. Proprietary and confidential.

# Unity Codex AI Template

A ready-to-use Codex CLI template for Unity projects. All agents, commands,
rules, and guides are organized under `.codex/`.

---

## Structure

```
.codex/
├── core/          — Platform-agnostic agents and commands
├── packs/
│   └── unity-game/   — Unity-specific agents, commands, rules, guides, skills
├── project/       — Per-project overlay files (fill in each project)
├── manifests/     — Import decisions and migration notes
└── templates/     — Starter templates
```

---

## Required Reads (Start of Every Session)

Every agent and command reads these before starting:

1. `AGENTS.md` — this file
2. `.codex/packs/unity-game/guides/guardrails.md` — all rules as hook equivalents
3. `.codex/project/PROJECT.md` — project identity and constraints
4. `.codex/project/RULES.md` — project hard rules

---

## Guardrails (Hook Equivalents)

Codex has no hook mechanism. `.codex/packs/unity-game/guides/guardrails.md`
fills that gap. **All agents and commands must internalize this file.**

Three levels:

| Level | Examples |
|-------|---------|
| **BLOCK** | `git push`, `.unity`/`.prefab` text edit, `UnityEvent`, `Time.timeScale`, static singleton, `UnityEditor` without guard |
| **WARN** | `async void`, `GetComponent` in Awake, legacy Input API, hot-path LINQ/alloc, null propagation on Unity objects |
| **GATE** | Pipeline cannot start without Director Gate; `unity-reviewer` required before commit |

---

## Reviewer

The reviewer in this project is **Claude** (`unity-reviewer` agent).

- Full checklist: compilation verification (MCP), runtime validation (Play mode), architecture, performance, encapsulation, input system, unused code detection
- Review is **required** before every commit
- Agent file: `.codex/packs/unity-game/agents/unity-reviewer.md`

---

## Agent Directory

### Core Agents (`.codex/core/agents/`)

| Agent | Role |
|-------|------|
| `coder.md` | General implementation |
| `tester.md` | Test authoring |
| `reviewer.md` | General review → use `unity-reviewer` for Unity projects |
| `committer.md` | Commit and versioning |

### Unity Specialist Agents (`.codex/packs/unity-game/agents/`)

| Agent | Role |
|-------|------|
| `unity-coder.md` | MonoBehaviour, provider, installer, scene wiring implementation |
| `unity-coder-lite.md` | Small C# changes with high rule compliance |
| `unity-fixer.md` | Bug fixing — root cause analysis + regression test |
| `unity-fixer-lite.md` | Fast single-file fixes |
| `unity-reviewer.md` | **Full Claude-based reviewer** — compile + runtime verification |
| `tester.md` | EditMode / PlayMode test authoring — NUnit, hand-rolled fakes, AAA pattern |
| `committer.md` | Smart phase commits — groups by system boundary, dependency-ordered |
| `unity-test-runner.md` | Test execution and result reporting |
| `unity-test-builder.md` | PlayMode test scene creation |
| `unity-developer.md` | Full-cycle developer — coder + tester + reviewer |
| `unity-setup.md` | Scene, prefab, asset, Unity settings setup |
| `unity-scene-builder.md` | Scene hierarchy creation and configuration |
| `unity-ui-builder.md` | UI Toolkit / UGUI panel and view creation |
| `unity-shader-dev.md` | Shader Graph and HLSL shader development |
| `unity-network-dev.md` | Network layer implementation |
| `unity-optimizer.md` | Performance profiling and optimization |
| `unity-linter.md` | Code quality and rule compliance audit |
| `unity-critic.md` | Architecture and design critique |
| `unity-verifier.md` | 3-iteration verification and fix loop |
| `unity-scout.md` | Codebase exploration and analysis |
| `unity-prototyper.md` | Rapid prototype implementation |
| `unity-migrator.md` | Unity version and render pipeline migration |
| `unity-git-master.md` | Git operations and branch management |
| `unity-build-runner.md` | Build pipeline management |
| `unity-security-reviewer.md` | Security vulnerability scanning |
| `debugger.md` | General debug process |
| `migrator.md` | Code pattern migration (Coroutine → UniTask, Singleton → VContainer) |
| `silent-failure-hunter.md` | Silent failure detection |
| `audio-clip-agent.md` | Batch AudioClip import settings application |
| `graphics-setup-agent.md` | URP / graphics settings setup |
| `package-analyzer.md` | Package dependency analysis |

---

## Command Directory

### Core Commands (`.codex/core/commands/`)

| Command | Role |
|---------|------|
| `/orchestrate` | Run full workflow pipeline |
| `/continue` | Resume an interrupted pipeline |
| `/dry-run` | Simulate pipeline — no file changes |
| `/status` | Current workflow status |
| `/stop` | Stop pipeline |
| `/validate` | Verify completed work |

### Unity Commands (`.codex/packs/unity-game/commands/`)

#### Planning & Architecture
| Command | Role |
|---------|------|
| `/architect` | Architectural design and decision making |
| `/create-plan` | Create a task plan |
| `/update-plan` | Update an existing plan |
| `/plan-workflow` | Workflow design |
| `/game-idea` | Game idea development |
| `/refine-gdd` | GDD refinement |
| `/refine-tdd` | TDD refinement |
| `/adr` | Write an Architecture Decision Record |

#### Implementation
| Command | Role |
|---------|------|
| `/implement` | Feature implementation via TDD pipeline |
| `/add-feature` | Add a feature to an existing system |
| `/new-module` | Scaffold a new module |
| `/fix` | Bug fix pipeline |
| `/fix-deep` | Deep root-cause analysis and bug fix |
| `/scene-setup` | Scene setup |
| `/create-prefab-scene` | Create prefab and scene |
| `/unity-scene-update` | Scene update |
| `/update-scene-hierarchy` | Scene hierarchy update |
| `/setup-project` | Initial project setup |

#### Testing
| Command | Role |
|---------|------|
| `/generate-tests` | Generate test files |
| `/create-test` | Create a single test |
| `/qa` | QA verification process |
| `/debug-session` | Interactive debug session |

#### Review & Quality
| Command | Role |
|---------|------|
| `/review-code` | Code review (Claude reviewer) |
| `/clean-slop` | Remove low-quality / unnecessary code |
| `/performance-audit` | Performance audit |
| `/check-portability` | Platform portability check |
| `/silent-failure-hunt` | Silent failure scan |

#### Git & Versioning
| Command | Role |
|---------|------|
| `/smart-commit` | Smart commit message and staging |
| `/create-changelog` | Generate changelog |

#### Utilities
| Command | Role |
|---------|------|
| `/catch-up` | Learn and summarize the codebase |
| `/learn` | Learn a specific pattern or system |
| `/discover` | Explore the codebase |
| `/search` | Search within code |
| `/context-prime` | Build context |
| `/checkpoint` | Save state |
| `/migrate` | Code migration |
| `/migrator` | Pattern migration pipeline |
| `/graphics-setup` | Graphics settings setup |
| `/audio-clip-setup` | AudioClip import settings |
| `/instincts` | Project instincts / learned patterns |
| `/dump` | Context dump |
| `/caveman` | Plain-language explanation mode |
| `/five` | Quick 5-minute summary |
| `/grill-me` | Query the codebase |
| `/ralph` | Retrospective analysis |
| `/mermaid` | Generate a Mermaid diagram |

---

## Rules (`.codex/packs/unity-game/rules/`)

| File | Covers |
|------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputView, AppScope |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw calls, UI canvas |
| `testing.md` | Test type decision (EditMode/PlayMode/ECS/NoTest), NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform defines, lifecycle order |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent forbidden, IEventBus vs Action vs C# event decision tree |
| `scene-hierarchy.md` | 6 required root containers, prefab domain, logic/visual separation |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | No Resources.Load, async loading, handle lifecycle |

---

## Guides (`.codex/packs/unity-game/guides/`)

| File | Covers |
|------|--------|
| `guardrails.md` | **All rules as hook equivalents — BLOCK / WARN / GATE** |
| `director-gates.md` | Pipeline gates and pass conditions |
| `unity-mcp.md` | MCP tool usage guide |
| `input-system.md` | New Input System implementation guide |
| `serialization-safety.md` | Safe serialization change guide |
| `nsubstitute.md` | NSubstitute usage guide |
| `vcontainer.md` | VContainer DI guide |

---

## Skills (`.codex/packs/unity-game/skills/`)

Read-only reference files loaded by commands on demand. They do not execute code — they inform agent decisions.

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
| `shader-graph` | URP shader nodes, property exposure, keyword variants |
| `ui-toolkit` | USS, UXML, data binding, runtime panel setup |
| `urp-pipeline` | Renderer features, camera stacking, custom render passes, SRP Batcher, Forward+ |
| `urp-quality-settings` | URP quality tiers, runtime asset swap, auto-detect, adaptive performance |
| `urp-lighting-shadows` | Directional/point/spot lights, shadow cascades, light layers, reflection probes |
| `urp-post-processing` | Bloom, DOF, Motion Blur, SSAO, Tonemapping, Color Grading, Vignette |
| `audio-mixer-mcp` | AudioMixer exposed parameters, AudioSource routing via MCP |
| `srp-batcher-mcp` | SRP Batcher enable/verify, UI Raycast Target audit via MCP |

### Third-Party (`skills/third-party/`)

| Skill | Covers |
|-------|--------|
| `dotween` | Tween creation, sequences, callbacks, memory management |
| `nsubstitute` | NSubstitute mock setup, argument matchers, received verification |
| `odin-inspector` | Custom attributes, validators, group drawers |
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

## Required Stack

| Package | Source | Purpose |
|---------|--------|---------|
| **VContainer** | OpenUPM | DI — no singletons |
| **UniTask** | OpenUPM | Async/await — no coroutines |
| **New Input System** | Package Manager | Input — legacy API forbidden |

## Optional Features

| Package | Feature Flag | When Disabled |
|---------|-------------|---------------|
| Addressables | `addressables` | Addressables rules skipped |
| NSubstitute | `testing` | Test hooks and asmdefs skipped |
| Unity ECS DOTS | `ecs` | ECS folder and rules skipped |

---

## New Project Setup

```
/setup-project
```

or manually:

1. Fill `.codex/project/PROJECT.md`
2. Fill `.codex/project/STRUCTURE.md`
3. Fill `.codex/project/TOOLING.md`
4. Fill `.codex/project/CODING_CONVENTIONS.md`
5. Fill `.codex/project/RULES.md`
6. Start development with `/implement`

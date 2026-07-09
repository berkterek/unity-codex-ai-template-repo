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
├── guardrails/    — Executable Codex validators for BLOCK/WARN rules
├── graph/         — Optional Unity knowledge graph extractors and validators
├── manifests/     — Import decisions and migration notes
└── templates/     — Starter templates, including module spec/design/tasks
.agents/
└── skills/        — Repo-scoped Codex skills wrapping command workflows
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
Executable enforcement lives in `.codex/guardrails/run.sh`.

Three levels:

| Level | Examples |
|-------|---------|
| **BLOCK** | `git push`, `.unity`/`.prefab` text edit, `UnityEvent`, `Time.timeScale`, static singleton, MonoBehaviour business logic, `UnityEditor` without guard |
| **WARN** | `async void`, `GetComponent` in Awake, legacy Input API, SOLID/OOP drift, hot-path LINQ/alloc, null propagation on Unity objects |
| **GATE** | Pipeline cannot start without Director Gate; `unity-reviewer` required before commit |

Run executable guardrails at workflow gates:

```bash
bash .codex/guardrails/run.sh --changed
bash .codex/guardrails/run.sh --staged
bash .codex/guardrails/run.sh --files Assets/Scripts/Foo.cs
```

`BLOCK` findings exit `1` and must be fixed before `/validate`, `/qa`, or
`/smart-commit` proceeds. `WARN` findings exit `0` but must be reported.

For local git enforcement, enable the bundled hook once per clone:

```bash
git config core.hooksPath .githooks
```

---

## Reviewer

The reviewer in this project is the `unity-reviewer` agent.

- Full checklist: compilation verification (MCP), runtime validation (Play mode), architecture, performance, encapsulation, input system, unused code detection
- Review is **required** before every commit
- Agent file: `.codex/packs/unity-game/agents/unity-reviewer.md`

---

## Native Codex Subagents

Native Codex custom agent wrappers live in `.codex/agents/*.toml`.

- The canonical long-form role instructions remain in `.codex/packs/unity-game/agents/*.md`.
- Each `.toml` wrapper points its subagent to the matching Markdown role file.
- Update the Markdown role file first when changing behavior; update the wrapper only for agent identity, sandbox mode, startup reads, or model/tool defaults.
- Restart Codex after adding or changing `.codex/agents/*.toml` so the agent catalog reloads.
- Usage guide: `.codex/packs/unity-game/guides/subagents.md`.

Subagents are not spawned automatically. Ask explicitly for subagents or
parallel agents, and keep parallel write tasks on disjoint file sets.

Default model routing:

- Plan-writing agents and planning commands only: **GPT-5.5**
- All non-lite agents and normal command work: **GPT-5.4**
- Lite agents, scout, linter, short summaries, low-risk lookup: **GPT-5.3**
- `--heavy` upgrades implementation/fix/orchestration workers to GPT-5.4 when they would otherwise use a lite path.
- `--lite` or `--quick` downgrades safe, scoped work to GPT-5.3.

---

## Codex Command Skills

Repo-scoped Codex command skills live in `.agents/skills/`.

- Core commands use `core-*` skill names, such as `$core-orchestrate`.
- Unity commands use `unity-*` skill names, such as `$unity-implement`.
- The canonical command instructions remain in `.codex/core/commands/*.md` and `.codex/packs/unity-game/commands/*.md`.
- Each skill wrapper reads and executes its matching canonical command file.
- Usage guide: `.codex/packs/unity-game/guides/commands-as-skills.md`.

When adding, removing, or renaming command files, update the matching skill
wrapper so Codex can discover the workflow through `$skill` invocation.

---

## Agent Directory

### Core Agents (`.codex/core/agents/`)

| Agent | Role |
|-------|------|
| `coder.md` | General implementation — code quality, performance, architecture, encapsulation standards |
| `tester.md` | Test authoring — NUnit, test type decision tree, 6 test categories, AAA pattern |
| `reviewer.md` | General review → use `unity-reviewer` for Unity projects |
| `committer.md` | Commit and versioning — structured decision trailers, dependency-ordered groups |

### Unity Specialist Agents (`.codex/packs/unity-game/agents/`)

| Agent | Role |
|-------|------|
| `unity-coder.md` | MonoBehaviour, provider, installer, scene wiring — full Step 0 skill loading, detailed rules, MCP wiring |
| `unity-coder-lite.md` | Small C# changes with high rule compliance |
| `unity-fixer.md` | Bug fixing — root cause analysis + regression test |
| `unity-fixer-lite.md` | Fast single-file fixes |
| `unity-reviewer.md` | **Full Unity reviewer** — compile + runtime verification |
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
| `lean-planner.md` | Compact 3-5 task plan — no code skeletons, no acceptance criteria |
| `unity-particle-designer.md` | VFX particle effect design, prefab creation, pooled VFX service wiring |
| `unity-ui-toolkit-builder.md` | Editor-only UI Toolkit: EditorWindow, CustomEditor, UXML, USS |

---

## Command Directory

### Core Commands (`.codex/core/commands/`)

| Command | Role |
|---------|------|
| `/orchestrate` | Run module `tasks.md` orchestration pipeline |
| `/continue` | Resume an interrupted module pipeline |
| `/dry-run` | Simulate module pipeline — no file changes |
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
| `/roadmap` | Module roadmap generator — GDD + TDD → docs/ROADMAP.md |
| `/plan-module` | Just-in-time module planner — spec/design/tasks.md |
| `/plan-workflow` | Legacy WORKFLOW.md design |
| `/game-idea` | Game idea development |
| `/game-plan` | Legacy game completion planner — prefer `/roadmap` + `/plan-module` |
| `/refine-gdd` | GDD refinement |
| `/refine-tdd` | TDD refinement |
| `/adr` | Write an Architecture Decision Record |

#### Implementation
| Command | Role |
|---------|------|
| `/implement` | Feature implementation via TDD pipeline |
| `/implement-lite` | Lightweight single-class implementation — no test writer, no reviewer |
| `/add-feature` | Add a feature to an existing system |
| `/new-module` | Scaffold a static Module + ConfigCatalog/AppModules wiring |
| `/fix` | Bug fix pipeline |
| `/fix-lite` | Fast single-file fix — no analyzer, no reviewer |
| `/fix-deep` | Deep root-cause analysis and bug fix |
| `/fix-codex` | Codex-driven fix — unbiased analysis for large or stuck bugs |
| `/orchestrate` | Execute `docs/modules/<module>/tasks.md` |
| `/continue` | Resume interrupted module task execution |
| `/dry-run` | Preview module task execution without changes |
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
| `/debugger` | Root cause analysis and bug diagnosis |

#### Review & Quality
| Command | Role |
|---------|------|
| `/review-code` | Code review (unity-reviewer) |
| `/clean-slop` | Remove low-quality / unnecessary code |
| `/performance-audit` | Performance audit |
| `/check-portability` | Platform portability check |
| `/silent-failure-hunter` | Silent failure scan |

#### Git & Versioning
| Command | Role |
|---------|------|
| `/smart-commit` | Smart commit message and staging |
| `/smart-commit-selected` | Plan commits, select groups, commit only selected |
| `/create-changelog` | Generate changelog |
| `/update-agents-md` | Sync AGENTS.md with actual .codex/ folder state |
| `/update-claude-md` | Legacy alias for `/update-agents-md` |

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
| `/update-rules` | Sync project rules index with actual .codex/ folder state |
| `/build-knowledge-graph` | Build/refresh Unity knowledge graph |
| `/knowledge-graph` | Query Unity knowledge graph |

---

## Rules (`.codex/packs/unity-game/rules/`)

| File | Covers |
|------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputService, AppScope |
| `solid-oop.md` | MonoBehaviour role boundaries, SRP, OCP, DIP |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw calls, UI canvas |
| `testing.md` | Test type decision (EditMode/PlayMode/ECS/NoTest), NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform defines, lifecycle order |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent forbidden, IEventBus vs Action vs C# event decision tree |
| `scene-hierarchy.md` | 6 required root containers, prefab domain, logic/visual separation |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | No Resources.Load, async loading, handle lifecycle |
| `bootstrap-pattern.md` | Static Module hierarchy — ConfigCatalog, AppModules, AppScope, GameScope |
| `unity-async.md` | UniTask, cancellation, fire-and-forget, coroutine migration |
| `unity-input.md` | New Input System hard rules and InputService/InputHandler pattern |
| `unity-lifecycle.md` | Editor/runtime boundary, platform defines, DOTween cleanup |
| `unity-prefabs.md` | Prefab ownership, variants, BaseCanvas, package prefab duplication |

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
| NSubstitute | `testing` | Test rules and asmdefs skipped |
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
6. Start design with `/game-idea` and `/architect`
7. Plan modules with `/roadmap` and `/plan-module <n>`
8. Execute module work with `/orchestrate docs/modules/<module>/tasks.md`

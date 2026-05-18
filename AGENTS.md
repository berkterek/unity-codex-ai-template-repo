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
| `unity-tester.md` | EditMode / PlayMode test authoring |
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

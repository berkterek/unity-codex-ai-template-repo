## Commands (slash commands)

### Pipelines (multi-agent)
- `/implement <task>` — **complexity score** → [auto-routes to `/implement-lite` if score < 0.3] → **test-type-router** → [tester if not NoTest] → **unity-coder** → **unity-verifier** (compile + tests via MCP) → reviewer priority: **Codex** → unity-reviewer → [unity-developer if score ≥ 0.7] → **silent failure audit** (changed files) → committer
- `/implement-lite <task>` — **Lightweight single-class implementation**: read target file(s) → **unity-coder-lite** → compile check → committer. No test writer, no reviewer, no verifier. `/implement` auto-routes here when complexity score < 0.3.
- `/fix <bug>` — **complexity score** → Step 1: **unity-fixer** + **unity-scout** simultaneously (complexity ≥ 0.4) → **test-type-router** → [tester (regression test) if not NoTest] → **unity-coder** → **unity-verifier** (compile + tests via MCP) → reviewer priority: **Codex** → unity-reviewer → [unity-developer if score ≥ 0.7] → **silent failure audit** (changed files) → committer
- `/fix-deep <bug>` — **complexity score** → **evidence-first pipeline**: log intake (file / text / MCP) → hypothesis → debug injection → Step 3: **unity-fixer** + **unity-scout** simultaneously (complexity ≥ 0.4) → **evidence gate** (proven / refuted / inconclusive) → fix only if proven → **test-type-router** → [tester (regression test) if not NoTest] → validator → reviewer → **silent failure audit** (changed files) → committer; refuses to fix if root cause cannot be proven
  - Use for: logic bugs, "sometimes happens" issues, wrong values at runtime, NullRef with unclear source
  - Use `/fix` when: stack trace clearly points to root cause
- `/fix-lite <bug>` — **Lightweight single-file fix**: pin file + line from stack trace → read only that file → **unity-fixer-lite** → compile check → committer. No reviewer, no test writer, no scout. `/fix` auto-routes here when complexity score < 0.2.
- `/fix-codex [--files f1,f2] <bug>` — **Full Codex pipeline**: Codex Analysis (fresh eyes, no prior hypotheses) → **Human Gate** → Codex Implementation → **Codex Review** (correct location? root cause understood? complete? architecture?) → loop back to implementation if NEEDS REVISION (max 2x) → committer
  - Use when: legacy/large codebase (2000+ line files), stuck after `/fix` or `/fix-deep`, or 30+ minutes in a loop
  - The review pass does zero analysis before implementation — Codex reads the code directly, implements, then a reviewer checks the result
- `/scene-setup <description>` — **complexity score** → **unity-coder-lite** (Simple) / **unity-coder** (Medium/Complex) + unity-setup → **unity-verifier** → **Codex** → unity-reviewer → [unity-developer if score ≥ 0.7] → committer
- `/migrate <pattern> in <scope>` — **complexity score** → **test-type-router** → [tester if not NoTest and complexity ≥ Medium] → **migrator** / **unity-migrator** → reviewer → [unity-developer if score ≥ 0.7] → committer
- `/create-plan <file> <what>` — researcher → **complexity-aware planner** (high reasoning effort, assigns `parallel_group` to independent tasks) → reviewer → save → optional implementer (parallel spawn for grouped tasks if complexity ≥ 0.4)
- `/create-plan --lean <file> <topic>` — **Lean mode:** researcher → **lean-planner** (medium reasoning effort) → reviewer → save. Output: 3-5 task table (name, files, one-line note). No code skeletons, no acceptance criteria, no parallel_group annotations. Implementer auto-spawn: **disabled** regardless of complexity score. To upgrade: re-run without `--lean`.
- `/update-plan <file> <change>` — analyzer → planner (high reasoning effort, updates `parallel_group` annotations) → reviewer → save → optional implementer (parallel spawn for grouped tasks if complexity ≥ 0.4)
- `/update-plan --lean <file> <change>` — analyzer → **lean-planner** (medium reasoning effort) → reviewer → save. Output: updated 3-5 task table only. Implementer auto-spawn: **disabled**. Use when the change is small (adding/removing a task, adjusting a file path).
- `/smart-commit` — analyze dirty working tree → group into logical commits → commit
- `/smart-commit-selected` — analyze dirty working tree → plan commit groups → **show checklist (multiSelect)** → commit only selected groups
- `/orchestrate <tasks.md>` — **complexity score** → read a module `docs/modules/<n>-<name>/tasks.md` → checkbox resume → pre-scan codebase/graph → check `parallel_group` annotations → per-task: **test-type-router** → [tester if not NoTest] → **coder** (pure C#) / **unity-coder-lite** (Simple Unity) / **unity-coder** (Medium/Complex Unity/static module wiring) / **unity-setup** (scene/prefab) → **unity-verifier** → **Codex** → unity-reviewer → [unity-developer if score ≥ 0.7] → committer; tasks with same `parallel_group` run simultaneously only when outputs do not conflict; checkpoints run guardrails and QA before proceeding

> Reviewer priority: Codex → unity-reviewer (falls back to unity-reviewer if Codex is unavailable).

> Model routing: plan-writing agents and planning commands use **GPT-5.5**.
> All non-lite implementation, review, verification, setup, test, critique, and
> debug work uses **GPT-5.4**. Lite/scout/linter/short-summary work uses
> **GPT-5.3**. `--lite` or `--quick` downgrades safe, scoped work to GPT-5.3;
> `--heavy` returns implementation/fix/orchestration workers to GPT-5.4.

### Project Setup
- `/setup-project` — **Step 0:** detect existing state, compare against `.codex/project/FEATURES.json` (if any), offer sync-only mode on conflict. **Step 1:** ask feature questions (Addressables / Testing / ECS) + package gates. Generates folder structure, .asmdef files, base framework classes, and manual checklist. Writes `.codex/project/FEATURES.json` and updates project overlay docs when needed.
- `/create-prefab-scene` — **Legacy migration:** scan existing scenes for bare GameObjects, build a prefab inventory, create proper prefabs via MCP, review, commit. Use for scenes built before the prefab rules were in place.

### Design & Architecture
- `/game-idea` — Refine a raw game idea into a GDD (includes assumption surfacing + "Not Doing" list)
- `/architect` — Create a Technical Design Document from a GDD (auto-runs Phase 7 self-critique → **unity-critic** adversarial challenge → developer review)
- `/grill-me [plan or file]` — Stress-test a plan or design decision — asks one pointed question at a time, offers a recommended answer, resolves every branch; ends with a Decision Record. **Next:** if the plan changed, run `/update-plan` to reflect the decisions; skip if the plan was only confirmed.
- `/refine-gdd` — Iterate on an existing GDD
- `/refine-tdd` — Iterate on an existing TDD

### Game Completion Planning
- `/roadmap` — reads GDD + TDD + existing `docs/modules/` plans, then creates or updates `docs/ROADMAP.md` with module order, dependencies, priority, status, and plan links.
- `/plan-module <n|slug>` — creates one `docs/modules/<n>-<name>/` folder with `spec.md`, `design.md`, and `/orchestrate`-ready `tasks.md` using checkbox tasks, explicit outputs, acceptance criteria, test type, and `parallel_group`.
- `/game-plan [docs/GDD.md]` — legacy planner. Prefer `/roadmap` + `/plan-module` for new work.

### Development
- `/plan-workflow` — legacy WORKFLOW.md planner. Prefer `/roadmap` + `/plan-module`.
- `/new-module` — Generate the static module structure (Interface, Service, Config, static Module, Events, optional Provider) and wire `AppModules.cs` + `ConfigCatalog.cs`.

### Quality
- `/review-code` — Code review on specific files via **unity-reviewer**
- `/validate` — Validate a completed phase; **unity-verifier** via MCP tried first, dotnet CLI fallback
- `/check-portability` — Audit a module for copy-paste portability
- `/clean-slop` — Remove AI-generated bloat (dead code, useless abstractions)
- `/learn` — Extract project-specific patterns into `.codex/packs/unity-game/skills/learned/` + generates `PROMPTS.md` documenting the workflow
- `/discover [--dry-run|--write] [--only <pkg>]` — Walk `Packages/manifest.json`, summarize each Unity package, and emit per-package skill drafts to `.codex/packs/unity-game/skills/third-party/<pkg>/`. Small packages produce a single `SKILL.md`; large packages (50+ prefabs) produce a multi-file folder (`SKILL.md`, `api.md`, `prefabs.md`, `integration.md`, `test-strategy.md`, `samples.md`). Supports `--dry-run` (default), `--write`, `--only <pkg>`, `--include-assets-plugins`.
- `/generate-tests` — Write missing tests for an existing class
- `/create-test <FeatureName>` — Unified test generator: runs test-type-router to determine EditMode / PlayMode-ECS / PlayMode-Programmatic / PlayMode-Scene, then generates the full test infrastructure for the chosen type. EditMode → NSubstitute unit test. PlayMode-ECS → isolated World test. PlayMode-Programmatic → `new GameObject().AddComponent<>()` lifecycle test, no scene. PlayMode-Scene → TestScope + TestInstaller + test stub + scene via MCP.
- `/graphics-setup <mobile|pc>` — Show tier plan (Low/Medium/High), await approval, create URP Pipeline Assets + Renderer Data + URPQualityConfiguration via MCP, wire into Quality Settings, commit option
- `/audio-clip-setup [path]` — Scan AudioClip assets, categorize (Music/SFX/UI/Voice), apply optimized import settings via temp Editor script + MCP; reports per-clip changes + summary + commit option
- `/update-scene-hierarchy [scene]` — Reorganize scene containers — moves misplaced GOs into correct `[Setup]`/`[Services]`/`[UI]`/`[Environment]`/`[Characters]`/`[VFX]` containers; creates missing containers; does not convert bare GOs to prefabs
- `/unity-scene-update [scene]` — Full scene audit — reorganizes containers AND converts bare GameObjects to prefabs under `_GameFolders/Prefabs/<Domain>/`; skips `[Setup]` targets (LifetimeScope objects wired manually)
- `/performance-audit` — Audit files for allocations and hot-path violations
- `/debug-session` — Structured root cause analysis; routes to **unity-fixer** (complex) or **unity-fixer-lite** (scoped) after root cause; **learner** skill runs on completion
- `/silent-failure-hunter` — Audit files for swallowed exceptions and silent error patterns
- `/ralph` — Relentless verify-fix loop (max 10 outer iterations) — refuses to stop until compile and tests are green or stuck is detected
- `/qa` — Full quality pipeline: **guardrails** → **ralph** (compile + tests) → **silent-failure-hunter** → **validate** — run after any implementation, accepts `--phase N` and `--files <path>`

### Session & Context
- `/caveman` — Ultra-compressed communication mode (~75% fewer tokens). Drops filler, keeps technical accuracy. Exit with `/normal`.
- `/checkpoint` — Save current conversation summary to `.codex/project/state/checkpoint.md`, then run `/clear` to free context; next session auto-reads the checkpoint and resumes
- `/context-prime` — Brief Codex on project context at the start of a session
- `/search <query>` — **complexity score** → Phase 1: **Explore** + **unity-scout** simultaneously (complexity ≥ 0.4) → write findings to `.codex/project/state/search-findings.md` → Phase 2: reviewer validates **completeness** (COMPLETE / INCOMPLETE / REJECT, max 5 iter) → Phase 3: present findings to user → Phase 4: **action router** recommends next command (`/fix`, `/fix-deep`, `/implement`, `/create-plan`, `/update-plan`, or no action) — never executes automatically
- `/dump` — Save current session notes to `.codex/project/logs/` as markdown
- `/five` — 5 Whys root cause analysis for a bug or architectural problem
- `/continue [tasks.md]` — Resume an interrupted module orchestration run from task checkboxes and the event journal
- `/status` — Report current pipeline stage: GDD → TDD → ROADMAP → module tasks progress
- `/dry-run [tasks.md]` — Preview a module `tasks.md` orchestration plan without executing tasks
- `/instincts` — Manage instinct library: status, list, evolve, promote, export, import

### Changelog
- `/create-changelog` — Create or update `CHANGELOG.md` with recent changes

### Diagrams
- `/mermaid` — Generate a Mermaid architecture diagram for a module or system

### Documentation
- `/catch-up` — Generate a human-readable codebase guide (`docs/CATCH_UP.md`)
- `/adr <decision>` — Record an Architecture Decision (e.g. `/adr why VContainer over Zenject`); writes to `docs/decisions/NNN-topic.md`
- `/update-agents-md [--section rules|commands|agents]` — Syncs AGENTS.md tables with actual `.codex/` project state. Shows diff, waits for confirmation before writing.
- `/update-claude-md [--section rules|commands|agents]` — Legacy alias for `/update-agents-md`.

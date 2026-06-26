# Model Routing

Use the local `model-routing` skill for task sizing. As a default:

| Tier | Preferred Model | When to use |
|------|-----------------|-------------|
| **light** | GPT-5.3 | Quick summaries, `/dump`, `/five`, `/mermaid`, `/create-changelog`, `/context-prime`, scout/linter pre-scans |
| **normal** | GPT-5.4 | Implementation, reviews, debugging, validation, test generation, module scaffolding, cleanup |
| **heavy** | GPT-5.5 | Plan-writing agents and planning commands only |

Prefer GPT-5.4 for all non-planning work, including cross-module changes,
serialization migrations, architecture review, debugging, and Unity scene/prefab
wiring. Reserve GPT-5.5 for producing or revising plans.

## Agent Defaults

Use these defaults unless the user overrides with a cheaper or stronger tier:

| Agent / Work Type | Default Tier | Preferred Model |
|-------------------|--------------|-----------------|
| `lean-planner`, planner, architecture, `/create-plan`, `/update-plan`, `/plan-workflow` | **heavy** | GPT-5.5 |
| `unity-critic`, `unity-developer`, deep reviewer, root-cause debugger | **normal** | GPT-5.4 |
| `coder`, `unity-coder`, `unity-coder-lite`, `tester`, `unity-reviewer`, `unity-verifier` | **normal** | GPT-5.4 |
| `unity-fixer`, `unity-migrator`, `unity-setup`, `graphics-setup-agent`, `package-analyzer` | **normal** | GPT-5.4 |
| `unity-scout`, `unity-linter`, quick summaries, file discovery | **light** | GPT-5.3 |

## Overrides

- `--heavy`: force implementation/fix/orchestration workers to **GPT-5.4** when they would otherwise use a lite path.
- `--lite` or `--quick`: force safe, scoped implementation/fix/scout work to **GPT-5.3** when speed/cost matters.
- Default implementation route remains **GPT-5.4**; do not use GPT-5.5 for implementation.

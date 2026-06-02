# Model Routing

Use the local `model-routing` skill for task sizing. As a default:

| Tier | When to use |
|------|-------------|
| **light** | Quick summaries, `/dump`, `/five`, `/mermaid`, `/create-changelog`, `/context-prime` |
| **normal** | Reviews, debugging, validation, test generation, module scaffolding, cleanup |
| **heavy** | Architecture, workflow planning, game design, GDD/TDD refinement, broad codebase interrogation |

Prefer stronger reasoning for cross-module changes, serialization migrations,
architecture decisions, and anything that touches Unity scene/prefab wiring.

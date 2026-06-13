---
name: model-routing
description: "Use when working with Model Routing Heuristics in this Unity Codex template."
---

# Model Routing Heuristics

When delegating work to agents, use these signals to select the right model tier. These are heuristics, not hard rules — the user can always override with `--quick` or `--thorough`.

## Complexity Signals

| Signal | Simple (low/medium effort) | Moderate (medium effort) | Complex (high effort) |
|--------|----------------------------|--------------------------|-----------------------|
| **File count** | 1-2 files | 3-8 files | 9+ files |
| **Scope** | Single class/method | Single system | Multiple systems |
| **Keywords** | "add field", "rename", "fix typo", "remove" | "implement", "refactor", "test" | "architect", "migrate", "optimize", "redesign" |
| **Risk level** | No serialization, no networking | Serialization involved | Networking, threading, platform-specific |
| **Patterns** | Obvious fix, boilerplate | Requires design choices | Requires trade-off reasoning |

## Routing Decision Matrix

### Low-Effort Tier — Fast, Cheap, Read-Only
**Agents:** `unity-scout`, `unity-linter`
**Use when:**
- Quick codebase exploration before a larger task
- Fast validation pass (lint-style check)
- Finding files, symbols, or patterns
- Pre-flight checks before delegating to a heavier agent

**Never use for:** Writing code, modifying files, complex reasoning

### Medium-Effort Tier — Balanced Speed/Quality
**Agents:** `unity-coder-lite`, `unity-fixer-lite`, `unity-reviewer`, `unity-test-runner`, `unity-build-runner`, `unity-migrator`, `unity-security-reviewer`, `unity-git-master`
**Use when:**
- Single-file changes with clear requirements
- Code review against a known checklist
- Writing tests for existing code
- Build configuration
- Bug fixes where the cause is known or obvious
- Structured tasks with documented procedures (migrations, LFS setup)

### High-Effort Tier — Deep Reasoning
**Agents:** `unity-coder`, `unity-fixer`, `unity-verifier`, `unity-optimizer`, `unity-prototyper`, `unity-shader-dev`, `unity-scene-builder`, `unity-ui-builder`, `unity-network-dev`, `unity-critic`
**Use when:**
- Multi-system feature implementation
- Bug investigation requiring deep analysis
- Performance optimization (trade-off reasoning)
- Architecture decisions
- Shader math and visual programming
- Spatial reasoning (scene building)
- Challenging plans (critic role)

## Integration with Commands

### /unity-workflow — Phase 2 (Plan)
During the Plan phase, evaluate the requirements against the complexity signals above:
1. Count the estimated files to create/modify
2. Check for complexity keywords in the task description
3. Identify risk factors (serialization, networking, platform-specific)
4. Choose the agent tier accordingly:
   - Simple requirements → route to `unity-coder-lite` with low or medium reasoning effort
   - Moderate requirements → route to `unity-coder` with medium reasoning effort
   - Complex multi-system → route to multiple agents via `/unity-team`

### /unity-team — Agent Selection
When building a team, consider mixing tiers for efficiency:
- Use `unity-scout` with low reasoning effort for the initial project scan
- Use medium-effort agents for structured tasks (tests, review)
- Reserve high reasoning effort for creative or reasoning-heavy work
- The `--quick` flag lowers reasoning effort where available

### Cost Awareness
| Tier | Relative Cost | Relative Speed |
|------|--------------|----------------|
| Low effort | 1x | Fastest |
| Medium effort | 5x | Fast |
| High effort | 25x | Slower |

For iterative work (verify-fix loops), prefer medium effort for early passes
and high effort for the final judgment pass. This can reduce costs on
multi-iteration workflows.

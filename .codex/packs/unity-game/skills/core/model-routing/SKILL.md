---
name: model-routing
description: "Use when working with Model Routing Heuristics in this Unity Codex template."
---

# Model Routing Heuristics

When delegating work to agents, use these signals to select the right model tier. These are heuristics, not hard rules — the user can always override with `--quick`, `--lite`, `--heavy`, or `--thorough`.

## Preferred Codex Model Mapping

| Tier | Preferred Model | Primary Use |
|------|-----------------|-------------|
| **light** | GPT-5.3 | Scout/linter scans, short summaries, file discovery, low-risk lookup |
| **normal** | GPT-5.4 | Most implementation, tests, review, validation, setup, migrations |
| **heavy** | GPT-5.5 | Plan-writing agents and planning commands only |

Use GPT-5.5 only for planner-style work by default. Use GPT-5.4 for the normal
execution pipeline, including critique, review, debugging, and implementation.
Use GPT-5.3 only when the task is narrow, low-risk, and mostly read-only.

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
**Preferred model:** GPT-5.3
**Agents:** `unity-scout`, `unity-linter`
**Use when:**
- Quick codebase exploration before a larger task
- Fast validation pass (lint-style check)
- Finding files, symbols, or patterns
- Pre-flight checks before delegating to a heavier agent

**Never use for:** Writing code, modifying files, complex reasoning

### Medium-Effort Tier — Balanced Speed/Quality
**Preferred model:** GPT-5.4
**Agents:** `unity-coder-lite`, `unity-fixer-lite`, `unity-reviewer`, `unity-test-runner`, `unity-build-runner`, `unity-migrator`, `unity-security-reviewer`, `unity-git-master`
**Use when:**
- Single-file changes with clear requirements
- Code review against a known checklist
- Writing tests for existing code
- Build configuration
- Bug fixes where the cause is known or obvious
- Structured tasks with documented procedures (migrations, LFS setup)

### High-Effort Tier — Deep Reasoning
**Preferred model:** GPT-5.5 for planners only; GPT-5.4 for critics, deep reviewers, debugging, and implementation
**Agents:** `lean-planner`, planner, `unity-critic`, `unity-developer`, `debugger`, `unity-coder`, `unity-fixer`, `unity-verifier`, `unity-optimizer`, `unity-prototyper`, `unity-shader-dev`, `unity-scene-builder`, `unity-ui-builder`, `unity-network-dev`
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
   - Simple requirements → route to `unity-coder-lite` on GPT-5.4, or GPT-5.3 with `--lite`
   - Moderate requirements → route to `unity-coder` on GPT-5.4
   - Complex multi-system → route to planner on GPT-5.5, then all implementation/review workers on GPT-5.4

### /unity-team — Agent Selection
When building a team, consider mixing tiers for efficiency:
- Use `unity-scout` on GPT-5.3 for the initial project scan
- Use GPT-5.4 agents for structured tasks (implementation, tests, review)
- Reserve GPT-5.5 for plan-writing only; use GPT-5.4 for critique, architecture review, and final high-risk judgment
- The `--quick` flag lowers reasoning effort where available

### Cost Awareness
| Tier | Relative Cost | Relative Speed |
|------|--------------|----------------|
| Low effort / GPT-5.3 | 1x | Fastest |
| Medium effort / GPT-5.4 | 5x | Fast |
| Plan-writing / GPT-5.5 | 25x | Slower |

For iterative work (verify-fix loops), prefer GPT-5.3 only for safe scout/lite
passes and GPT-5.4 for implementation, verification, and final judgment.
Reserve GPT-5.5 for plan creation or plan revision.

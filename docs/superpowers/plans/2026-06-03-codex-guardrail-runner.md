# Codex Guardrail Runner Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn Unity rule markdown into executable Codex-native guardrail checks.

**Architecture:** Add a shell runner under `.codex/guardrails/` that scans changed, staged, or explicit files and reports `BLOCK` and `WARN` findings with exit codes. Keep Markdown rules as reference material, and wire the runner into `/validate`, `/qa`, `/smart-commit`, README, and AGENTS docs.

**Tech Stack:** POSIX shell/Bash, `git`, `rg`, repository Markdown command prompts.

---

### Task 1: Guardrail Test Harness

**Files:**
- Create: `.codex/guardrails/test/verify-guardrails.sh`

- [ ] **Step 1: Write the failing tests**

Create a shell test harness that builds temporary C# and Unity YAML samples, runs `.codex/guardrails/run.sh --files ...`, and asserts:
- `UnityEvent`, `Time.timeScale`, static singleton, legacy Input, runtime `UnityEditor`, service allocation in MonoBehaviour, concrete service constructor dependency, and Unity YAML text edits are blocking.
- `SerializeField` rename without `FormerlySerializedAs`, hot-path `GetComponent`, and hot-path LINQ are warnings.
- Clean C# exits successfully.

- [ ] **Step 2: Verify RED**

Run:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
```

Expected: fail because `.codex/guardrails/run.sh` does not exist yet.

### Task 2: Guardrail Runner

**Files:**
- Create: `.codex/guardrails/run.sh`

- [ ] **Step 1: Implement minimal runner**

Implement:
- `--changed`, `--staged`, `--all`, `--files <paths...>`.
- C# pattern checks using `rg`/Bash.
- Unity serialized asset blocker for `.unity`, `.prefab`, `.asset`.
- Output format: `BLOCK file:line [rule] message`, `WARN file:line [rule] message`, summary counts.
- Exit `1` when any block exists; otherwise exit `0`.

- [ ] **Step 2: Verify GREEN**

Run:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
```

Expected: all guardrail tests pass.

### Task 3: Workflow Wiring

**Files:**
- Modify: `.codex/packs/unity-game/commands/validate.md`
- Modify: `.codex/packs/unity-game/commands/qa.md`
- Modify: `.codex/packs/unity-game/commands/smart-commit.md`
- Modify: `.codex/core/commands/validate.md`
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Update command prompts**

Document guardrails as the first executable gate for `/validate`, `/qa`, and `/smart-commit`.

- [ ] **Step 2: Update human-facing docs**

Document `.codex/guardrails/run.sh` usage and the test harness in README and AGENTS.

- [ ] **Step 3: Verify docs and scripts**

Run:

```bash
git diff --check
bash .codex/guardrails/test/verify-guardrails.sh
bash .codex/graph/test/verify-graphify.sh
```

Expected: all pass.

### Task 4: Git And CI Safety Net

**Files:**
- Create: `.githooks/pre-commit`
- Create: `.github/workflows/guardrails.yml`
- Test: `.codex/guardrails/test/verify-integration.sh`

- [ ] **Step 1: Write failing integration test**

Assert that `.githooks/pre-commit` runs `bash .codex/guardrails/run.sh --staged`
and `.github/workflows/guardrails.yml` runs
`bash .codex/guardrails/run.sh --changed`.

- [ ] **Step 2: Verify RED**

Run:

```bash
bash .codex/guardrails/test/verify-integration.sh
```

Expected before implementation: FAIL with missing hook/workflow files.

- [ ] **Step 3: Add hook and CI workflow**

Implement the local pre-commit hook and GitHub Actions workflow.

- [ ] **Step 4: Verify GREEN**

Run:

```bash
bash .codex/guardrails/test/verify-integration.sh
```

Expected: all integration checks pass.

# Codex Subagents

This repository keeps long-form Unity role instructions under
`.codex/packs/unity-game/agents/` and exposes the most useful roles as native
Codex custom subagents under `.codex/agents/`.

## Available Native Agents

| Agent | Use For |
| --- | --- |
| `audio-clip-agent` | AudioClip import settings and audio asset setup |
| `committer` | Local commit grouping and commit creation, never push |
| `debugger` | Root-cause defect analysis |
| `graphics-setup-agent` | URP, graphics, renderer, and quality setup |
| `lean-planner` | Compact read-only planning |
| `migrator` | Legacy pattern modernization |
| `package-analyzer` | Read-only package and dependency analysis |
| `silent-failure-hunter` | Read-only silent failure and resilience audit |
| `tester` | Behavior-focused test authoring |
| `unity-build-runner` | Unity build settings and build validation |
| `unity-coder` | Unity C# implementation, providers, installers, scene wiring |
| `unity-coder-lite` | Small scoped Unity C# changes |
| `unity-critic` | Read-only architecture and plan critique |
| `unity-developer` | Full-cycle Unity development |
| `unity-fixer` | Root-cause bug diagnosis and minimal fixes |
| `unity-fixer-lite` | Small scoped Unity bug fixes |
| `unity-git-master` | Unity-aware git hygiene and local repository operations |
| `unity-linter` | Read-only Unity rule compliance audit |
| `unity-migrator` | Unity-specific pattern migration |
| `unity-network-dev` | Unity networking implementation |
| `unity-optimizer` | Performance profiling and optimization |
| `unity-particle-designer` | Particle/VFX design and pooled VFX setup |
| `unity-prototyper` | Explicit rapid prototypes |
| `unity-reviewer` | Read-only review, compilation/runtime gates, guardrail checks |
| `unity-scene-builder` | Scene hierarchy and GameObject setup |
| `unity-scout` | Read-only exploration, dependency mapping, impact analysis |
| `unity-security-reviewer` | Read-only security and privacy review |
| `unity-setup` | Scene, prefab, ScriptableObject, input, and editor setup |
| `unity-shader-dev` | Shader and URP rendering work |
| `unity-test-builder` | Test infrastructure and PlayMode test scenes |
| `unity-test-runner` | EditMode/PlayMode test creation and execution |
| `unity-ui-builder` | UGUI/UI Toolkit panel and view setup |
| `unity-ui-toolkit-builder` | Editor UI Toolkit, UXML, and USS work |
| `unity-verifier` | Iterative Unity verification and fix loops |

Each `.toml` wrapper points the subagent back to the canonical Markdown role
file. Keep behavior changes in the role file first; update the wrapper only
when the agent identity, sandbox, or startup reads need to change.

## Example Prompts

Exploration:

```text
Spawn a unity-scout subagent to map every class involved in player input.
Wait for the result, then summarize the affected files and risks.
```

Implementation:

```text
Spawn a unity-coder subagent to implement the health service only.
Its write scope is Assets/_GameFolders/Scripts/Games/Concretes/Health and
Assets/_GameFolders/Scripts/Games/Abstracts/Health. Do not touch tests.
```

Review:

```text
Spawn a unity-reviewer subagent to review the current working tree.
Wait for PASS/FAIL and include compile/runtime verification status.
```

Parallel review:

```text
Spawn one unity-reviewer for correctness, one unity-scout for dependency risk,
and one unity-test-runner for test gaps. Wait for all three, then consolidate
the findings by severity.
```

## Operating Rules

- Subagents are not spawned automatically. Ask for subagents or parallel agents
  explicitly.
- Command skills may ask for subagents when their canonical workflow delegates
  work. Prefer the native wrappers in `.codex/agents/`.
- Prefer subagents for read-heavy, independent, or disjoint write-scope tasks.
- Do not run multiple write-heavy agents against the same files.
- Subagents inherit the current sandbox and approval policy unless their agent
  file overrides it.
- Completed agents still count against the thread limit until closed.

## Configuration

Project defaults live in `.codex/config.toml`:

```toml
[agents]
max_threads = 6
max_depth = 1
job_max_runtime_seconds = 1800
```

Restart Codex after adding or changing custom agent files so the session can
load the new agent catalog.

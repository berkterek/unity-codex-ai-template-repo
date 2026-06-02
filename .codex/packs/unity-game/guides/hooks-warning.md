# Warning Guardrail Reference

Codex does not run these as shell hooks. Treat this as a warning checklist for
manual validation, graph checks, and reviewer passes.

| Hook | Warns |
|------|-------|
| `check-no-linq-hotpath.sh` | LINQ in Update/FixedUpdate/LateUpdate |
| `check-no-hotpath-expensive-calls.sh` | `GetComponent`, `Camera.main`, `FindObjectOfType`, bare `transform.`, `tag ==`, `SendMessage` inside Update/FixedUpdate/LateUpdate/Tick/FixedTick/LateTick — suppressed if `_transform` field is cached |
| `check-getcomponent-in-awake.sh` | `GetComponent`/`GetComponentInChildren` in `Awake` — prefer `[SerializeField]` Inspector assignment for all components including `Transform`; only acceptable when component is added dynamically at runtime |
| `check-no-runtime-instantiate.sh` | `new GameObject()` — **blocked** outside Pool/Factory/Spawner and Editor files; `Destroy()` — warning only (`Instantiate(prefab)` is allowed) |
| `warn-serialization.sh` | Renamed `[SerializeField]` without `[FormerlySerializedAs]` |
| `check-ecs-structural-changes.sh` | `EntityManager.AddComponent/RemoveComponent/DestroyEntity` inside ECS system (use ECB) — skip if `ecs=false` in `.codex/project/FEATURES.json` |
| `check-async-void.sh` | `async void` outside Unity lifecycle methods (swallows exceptions) |
| `check-unitask-cancellation.sh` | `async UniTask` methods without `CancellationToken` parameter |
| `check-null-propagation.sh` | `?.` or `is null` on Unity objects (bypasses destroyed-object detection) |
| `track-read.sh` (PostToolUse Read) | Records every `Read` tool call into `gateguard-reads.txt` so `gateguard.sh`'s Stage 1 (`unity_was_read()`) check passes on the next Edit/Write. Without this hook, `gateguard-reads.txt` is never populated and every edit is blocked even after the file is read. |
| `track-codex-review.sh` (PostToolUse) | Historical Claude hook for reviewer-order enforcement; in Codex, follow the reviewer gate in `guardrails.md` manually |
| `instinct-capture.sh` (PostToolUse) | Captures tool-use observations for later distillation into instincts |
| `cost-tracker.sh` (PostToolUse) | Logs every tool call with timestamp for cost auditing |
| `instinct-distill.sh` (Stop) | Distills captured observations into confidence-scored instincts |
| `session-restore.sh` (SessionStart) | Restores session state from `.codex/project/state/` on session start |
| `session-save.sh` (Stop) | Saves current session state to `.codex/project/state/` on stop |
| `stop-verify.sh` (Stop) | Drains the edit accumulator (`session-edits.txt`) at session end and runs batch verifiers — shell syntax check for `.sh`, JSON validity for `.json`, one `dotnet build` for all accumulated `.cs` files. Must be listed **after** `session-save.sh` in the Stop array. Implements the ECC pattern: catches subagent writes whose PostToolUse hooks never fired in the main session. |
| `graph-auto-update.sh` (PostToolUse Write\|Edit) | Historical Claude hook. In Codex, run `/build-knowledge-graph` manually or use `bash .codex/graph/graph-watch.sh`. |
| UserPromptSubmit inline hook | Injects skill-check reminder into every user prompt — enforces `using-superpowers` skill invocation before any action |
| `enforce-skill-for-keywords.sh` (UserPromptSubmit) | Detects third-party package keywords in the user's prompt (cinemachine, vcam, dotween, primetween, dreamteck, feel, odin, textmeshpro…). If the relevant skill has not been invoked yet this session, injects a blocking `additionalContext` message demanding `Skill` tool invocation before any code, advice, or MCP operation. Pairs with `track-skill-invocations.sh`. |
| `track-skill-invocations.sh` (PostToolUse Skill) | Records every `Skill` tool invocation to `${UNITY_HOOK_STATE_DIR}/skills-invoked.txt` — one skill name per line. Required by `enforce-skill-for-keywords.sh` to know which skills were already loaded so the enforcement message does not fire again for the same skill. |

## verify-after-write.sh

| Property | Value |
|----------|-------|
| Hook type | PostToolUse |
| Matcher | `Write\|Edit` |
| File filter | `.cs` files only — filtering done **in-script** (hook matchers do not support file extension filtering) |
| Exit semantics | Always exit 0 — warning mode, never blocks pipeline |
| Compile backend | `dotnet build -v q` (MCP tools are not callable from bash hook scripts) |
| `--no-restore` | Omitted — false negatives from missing restore are worse than slower builds |
| No-sln fallback | Prints skip message to stderr, exits 0 |
| Loop risk | None — hook calls no Write/Edit tools |

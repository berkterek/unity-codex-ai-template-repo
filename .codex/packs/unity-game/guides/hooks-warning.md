# Warning Guardrail Reference

Codex does not run these as shell hooks. Treat this as a warning checklist for
manual validation, graph checks, and reviewer passes.

| Hook | Warns |
|------|-------|
| `check-no-linq-hotpath.sh` | LINQ in Update/FixedUpdate/LateUpdate |
| `check-no-hotpath-expensive-calls.sh` | `GetComponent`, `Camera.main`, `FindObjectOfType`, bare `transform.`, `tag ==`, `SendMessage` inside Update/FixedUpdate/LateUpdate/Tick/FixedTick/LateTick — suppressed if `_transform` field is cached |
| `check-getcomponent-in-awake.sh` | `GetComponent`/`GetComponentInChildren` in `Awake` — prefer `[SerializeField]` Inspector assignment for all components including `Transform`; only acceptable when component is added dynamically at runtime |
| `check-no-runtime-instantiate.sh` | `Destroy()` outside Pool/Manager/Spawner files — warning only. `new GameObject()` is a blocking guardrail. |
| `warn-serialization.sh` | Renamed `[SerializeField]` without `[FormerlySerializedAs]` |
| `check-ecs-structural-changes.sh` | `EntityManager.AddComponent/RemoveComponent/DestroyEntity` inside ECS system (use ECB) — skip if `ecs=false` in `.codex/project/FEATURES.json` |
| `check-async-void.sh` | `async void` outside Unity lifecycle methods (swallows exceptions) |
| `check-unitask-cancellation.sh` | `async UniTask` methods without `CancellationToken` parameter |
| `check-null-propagation.sh` | `?.` or `is null` on Unity objects (bypasses destroyed-object detection) |
| `track-read.sh` (historical read tracker) | Recorded every read for read-before-edit enforcement; in Codex, read the target file before editing and rely on explicit guardrail checks. |
| `track-codex-review.sh` (historical review tracker) | Enforced reviewer order; in Codex, follow the reviewer gate in `guardrails.md` manually |
| `instinct-capture.sh` (historical observation tracker) | Captured tool-use observations for later distillation into instincts |
| `cost-tracker.sh` (historical cost tracker) | Logged every tool call with timestamp for cost auditing |
| `instinct-distill.sh` (Stop) | Distills captured observations into confidence-scored instincts |
| `session-restore.sh` (SessionStart) | Restores session state from `.codex/project/state/` on session start |
| `session-save.sh` (Stop) | Saves current session state to `.codex/project/state/` on stop |
| `stop-verify.sh` (historical stop verifier) | Drained the edit accumulator and ran batch verifiers. In Codex, run verification commands explicitly before reporting completion. |
| `graph-auto-update.sh` (historical graph updater) | In Codex, run `/build-knowledge-graph` manually or use `bash .codex/graph/graph-watch.sh`. |
| Prompt skill reminder | Reminded agents to load relevant skills. In Codex, follow skill trigger rules explicitly. |
| `enforce-skill-for-keywords.sh` (historical keyword checker) | Detected third-party package keywords and required the matching skill. In Codex, load the relevant skill from the session skill list. |
| `track-skill-invocations.sh` (historical skill tracker) | Recorded skill invocations for keyword enforcement. In Codex, report loaded skills directly when relevant. |

## verify-after-write.sh

| Property | Value |
|----------|-------|
| Historical trigger | after tool use |
| Matcher | `Write\|Edit` |
| File filter | `.cs` files only — filtering done **in-script** (hook matchers do not support file extension filtering) |
| Exit semantics | Always exit 0 — warning mode, never blocks pipeline |
| Compile backend | `dotnet build -v q` (MCP tools are not callable from bash hook scripts) |
| `--no-restore` | Omitted — false negatives from missing restore are worse than slower builds |
| No-sln fallback | Prints skip message to stderr, exits 0 |
| Loop risk | None — historical hook calls no text-edit tools |

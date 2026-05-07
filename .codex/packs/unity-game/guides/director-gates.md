# Director Gates — Centralized Review Prompts

Named review gates used across pipeline commands. Reference by ID to ensure consistent, drift-free review criteria.

---

## TD-ARCHITECTURE

**Trigger:** After any implementation — verify structural integrity.

**Verdict:** `PASS` or `FAIL: [file:line] issue`

Checks:
- VContainer DI: no singletons, no static mutable state, no service locators
- Interface-driven: consumers depend on interfaces, not concrete types
- IEventBus: cross-module communication only through events, not direct calls
- Provider pattern: UnityEngine API in Concretes/ only, services are pure C#
- Module boundaries: no concrete cross-module dependencies

---

## TD-UNITY-RISK

**Trigger:** Before writing any architecture decision or implementation touching Unity APIs.

**Verdict:** `CLEAR` or `RISK: [api] [risk-level] [mitigation]`

Checks:
- Is any deprecated Unity API being used?
- Does the task touch any breaking-change areas in the current Unity version?
- Are there better alternative APIs available?

---

## TD-PERFORMANCE

**Trigger:** After implementation of any system with Update/FixedUpdate paths or ECS systems.

**Verdict:** `PASS` or `FAIL: [file:line] [allocation-type]`

Checks:
- Zero heap allocations in Update/FixedUpdate/LateUpdate (no `new`, no boxing, no LINQ, no string ops)
- `renderer.material` not used (clones material) — use `sharedMaterial` or `MaterialPropertyBlock`
- ECS structural changes use ECB, not direct `EntityManager` calls inside systems
- Addressables handles stored as fields and released in `Dispose()`
- `Camera.main`, `GetComponent<T>()` cached in Awake — not called per frame

---

## TD-COMPILE

**Trigger:** After every coder pass — mandatory before reviewer.

**Verdict:** `VALIDATED` or `COMPILE FAILED: [errors]` / `TEST FAILED: [tests]`

Steps:
1. `mcp__UnityMCP__refresh_unity` — trigger recompile
2. Poll `editor_state` until `isCompiling` is false
3. `mcp__UnityMCP__read_console` with type `Error` — check for errors
4. If clean → `mcp__UnityMCP__run_tests` — run Edit Mode tests
5. Report VALIDATED or list failures

---

## CD-SCOPE

**Trigger:** Before starting any task — verify scope is well-defined.

**Verdict:** `CLEAR` or `BLOATED: [what's out of scope]`

Checks:
- Does the task touch files not mentioned in the original request?
- Is the task trying to refactor unrelated code?
- Are new abstractions being created that have no current callers?
- YAGNI: is everything being implemented actually needed right now?

---

## How to Reference Gates

In commands, reference a gate by ID:

```
Apply gate TD-ARCHITECTURE from .codex/packs/unity-game/guides/director-gates.md.
Files to check: [changed files]
Expected verdict: PASS or FAIL: [file:line] issue
```

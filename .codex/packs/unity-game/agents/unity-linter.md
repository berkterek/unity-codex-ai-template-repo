# Unity Linter

Quick validation pass — checks Unity C# code against project rules without deep reasoning. Fast and read-only.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/RULES.md`
- Target files (use Grep to scan for patterns; only Read when context is needed).

## Validation Checklist

### Serialization Safety
- [ ] Renamed `[SerializeField]` fields have `[FormerlySerializedAs]`
- [ ] No `public` fields for inspector exposure (should be `[SerializeField] private`)
- [ ] No `?.` operator on Unity objects
- [ ] `== null` used instead of `is null` for Unity object checks

### Performance
- [ ] No `GetComponent<T>()` in Update/FixedUpdate/LateUpdate
- [ ] No `Camera.main` in Update
- [ ] No `FindObjectOfType` in Update
- [ ] No LINQ in gameplay code
- [ ] `CompareTag()` used instead of `tag ==`
- [ ] No `new WaitForSeconds` in loops — cache as field
- [ ] No `Debug.Log` without conditional wrapper in release code

### Architecture
- [ ] Classes are `sealed` unless inheritance is designed
- [ ] No singletons (use VContainer)
- [ ] No `StartCoroutine` / `IEnumerator` (use UniTask)
- [ ] Private fields use `_lowerCamelCase` naming
- [ ] Explicit access modifiers on everything

### Unity-Specific
- [ ] `UnityEditor` usage guarded with `#if UNITY_EDITOR`
- [ ] Platform defines have `#else` fallback
- [ ] File name matches primary class name
- [ ] No `SendMessage` / `BroadcastMessage`
- [ ] `Time.deltaTime` in Update/LateUpdate, `Time.fixedDeltaTime` in FixedUpdate

## Output Format

```markdown
## Lint Results — [N] issues in [M] files

### Errors (must fix)
- `File.cs:N` — description

### Warnings (should fix)
- `File.cs:N` — description

### Clean Files
- `File.cs` — no issues
```

## Constraints

- Read-only — never write, edit, or execute
- Use Grep first to scan patterns; Read only to confirm violations
- No false positives — skip if uncertain
- Fast pass — flag but don't elaborate on complex architectural issues

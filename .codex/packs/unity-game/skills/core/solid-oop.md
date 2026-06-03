---
name: solid-oop
description: SOLID & OOP rules for Unity: MonoBehaviour may only be View/Provider, no business logic in MonoBehaviour, SRP one-sentence test, OCP via polymorphism, DIP via interface dependencies. Use when designing classes, writing services, or adding MonoBehaviour logic.
model-tier: normal
---

# SOLID & OOP Rules (NON-NEGOTIABLE)

## MonoBehaviour Role Boundaries

MonoBehaviour classes may only act as **Views** or **Providers**.

| Role | Does | Does Not Do |
|---|---|---|
| **View** | Updates UI, reads input, triggers animation | Business logic, calculation, state management |
| **Provider** | Wraps Unity APIs such as Physics, Transform, AudioSource | Service coordination, event publishing |

### Boundaries

- Max ~100 lines; if it grows beyond that, it is probably taking multiple roles.
- No business logic in `Update()` or `FixedUpdate()`; those methods should only make thin calls such as `ReadValue()` or `SetMoveInput()`.
- No initialization logic in `Awake()` or `Start()`; VContainer `Initialize()` owns initialization.
- No `new Service()` in MonoBehaviour; dependencies arrive through `[Inject]`.

### Forbidden

```csharp
// BAD: MonoBehaviour calculates, updates UI, and publishes events.
private void Update()
{
    _score += Time.deltaTime * _multiplier;
    _label.text = _score.ToString();
    if (_score > 100)
        _eventBus.Publish(new ScoreThresholdEvent());
}

// GOOD: View makes a thin call into the service.
private void Update()
{
    _scoreService.Tick(Time.deltaTime);
}

// GOOD: Provider wraps Unity API.
public sealed class BasicAudioProvider : MonoBehaviour, IAudioProvider
{
    [SerializeField] private AudioSource _source;

    public void Play(AudioClip clip) => _source.PlayOneShot(clip);
}
```

---

## Normal C# Class SRP

Every class must be explainable in one sentence, and that sentence must not contain `and`.

```text
GOOD: "AudioService plays sounds."
GOOD: "ScoreModel tracks score."
BAD:  "PlayerService calculates movement and updates score and publishes events."
```

### Responsibility Test

| Question | Bad Signal |
|---|---|
| Can I explain this class in one sentence? | If not, it violates SRP |
| Does the sentence contain `and`? | Split it |
| Why does this class change? | More than one reason means split it |

---

## OCP (Open/Closed Principle)

Adding behavior should not require modifying an existing class.

```csharp
// BAD: every new enemy type edits this switch.
public void ProcessEnemy(EnemyType type)
{
    if (type == EnemyType.Fast) { /* ... */ }
    else if (type == EnemyType.Tank) { /* ... */ }
}

// GOOD: new enemy type means a new class.
public interface IEnemy
{
    void Attack();
}

public sealed class FastEnemy : IEnemy
{
    public void Attack() { /* ... */ }
}

public sealed class TankEnemy : IEnemy
{
    public void Attack() { /* ... */ }
}
```

---

## DIP (Dependency Inversion Principle)

Constructors accept interfaces, not concrete service classes.

```csharp
// BAD: concrete dependency.
public sealed class PlayerService
{
    private readonly AudioService _audio;

    public PlayerService(AudioService audio) => _audio = audio;
}

// GOOD: interface dependency.
public sealed class PlayerService
{
    private readonly IAudioService _audio;

    public PlayerService(IAudioService audio) => _audio = audio;
}
```

---

## Forbidden Pattern Summary

| Forbidden | Why | Use Instead |
|---|---|---|
| Business logic in MonoBehaviour | SRP violation | Move it to a service |
| Calculation in `Update()` | SRP + performance risk | Service owns it; View calls it |
| `new Service()` in MonoBehaviour | DIP violation | `[Inject]` |
| Concrete constructor parameter | DIP violation | Interface parameter |
| Type-check `if`/`else if` chain | OCP violation | Polymorphism |
| Class responsibility containing `and` | SRP violation | Split into two classes |
| Initialization logic in `Awake()` or `Start()` | Breaks VContainer lifecycle | `Initialize()` |

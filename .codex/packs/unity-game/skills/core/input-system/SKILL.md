---
name: input-system
description: "Use when working with Input System — InputView Pattern in this Unity Codex template."
---

# Input System — InputView Pattern

## Setup

1. Create `Assets/Input/PlayerControls.inputactions` — define all action maps
2. Enable "Generate C# Class" in the Inspector → `PlayerControls.cs` is generated
3. Write an `InputView` MonoBehaviour — the only class that touches `PlayerControls`

## InputView — Full Example

```csharp
public sealed class InputView : MonoBehaviour
{
    #region Fields

    private PlayerControls _controls;
    private IPlayerService _playerService;

    #endregion

    #region Lifecycle

    private void Awake()
    {
        _controls = new PlayerControls();
    }

    private void OnEnable()
    {
        _controls.Player.Enable();
        _controls.Player.Jump.performed   += OnJump;
        _controls.Player.Attack.performed += OnAttack;
    }

    private void OnDisable()
    {
        _controls.Player.Jump.performed   -= OnJump;
        _controls.Player.Attack.performed -= OnAttack;
        _controls.Player.Disable();
    }

    private void Update()
    {
        _playerService.SetMoveInput(_controls.Player.Move.ReadValue<Vector2>());
    }

    #endregion

    #region Constructor

    [Inject]
    public void Construct(IPlayerService playerService)
    {
        _playerService = playerService;
    }

    #endregion

    #region Private Methods

    private void OnJump(InputAction.CallbackContext ctx)   => _playerService.Jump();
    private void OnAttack(InputAction.CallbackContext ctx) => _playerService.Attack();

    #endregion
}
```

## Mandatory Rules

| Rule | Reason |
|------|--------|
| `Enable` → `OnEnable`, `Disable` → `OnDisable` | If Enable is missing, zero input arrives; if Disable is missing, ghost callbacks + leaks |
| `+=` and `-=` on the same method | Every Subscribe must have a matching Unsubscribe |
| Continuous input (`ReadValue`) → `Update` | FixedUpdate runs at a different rate, input can be missed |
| Cache input for physics, apply in `FixedUpdate` | Physics forces use the cached value |
| `Input.GetKey` / `Input.GetAxis` are forbidden | Blocked by hook (exit 2) |
| One `InputView` per scene | Prevents duplicate subscriptions |

## Action Map Switching

```csharp
// Gameplay → UI (when opening the pause menu)
_controls.Player.Disable();
_controls.UI.Enable();

// UI → Gameplay (when closing the menu)
_controls.UI.Disable();
_controls.Player.Enable();
```

Disable the current map, **then** enable the new one. Multiple gameplay maps must not be open at the same time.

## Service Side

Services are input-agnostic — they only receive commands:

```csharp
public interface IPlayerService
{
    void SetMoveInput(Vector2 input);
    void Jump();
    void Attack();
}
```

`InputView` is a thin adapter — reads, forwards, zero logic.

## Forbidden Usages

```csharp
// FORBIDDEN — legacy API, blocked by hook
Input.GetKey(KeyCode.Space)
Input.GetAxis("Horizontal")
Input.GetButton("Fire1")

// FORBIDDEN — creating PlayerControls outside of InputView
var controls = new PlayerControls(); // in another class

// CORRECT
_controls.Player.Move.ReadValue<Vector2>()
_controls.Player.Jump.performed += OnJump;
```

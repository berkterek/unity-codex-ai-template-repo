# Input System Rules

The New Input System package is mandatory. Legacy `Input.GetKey`,
`Input.GetAxis`, `Input.GetButton`, and `Input.mousePosition` are forbidden in
runtime code.

Input uses two layers:

- `InputService` — pure C#, owns generated `PlayerControls`, registered once as
  a VContainer entry point (`IInitializable`, `ITickable`, `IDisposable`)
- `InputHandler` — pure C#, per-prefab or per-domain routing from input state to
  a service

`InputView` is legacy. Do not create new `InputView : MonoBehaviour` classes.

## Card 1 — InputService Is Pure C#

Wrong:

```csharp
public sealed class InputView : MonoBehaviour
{
    private PlayerControls _controls;
    private void Update() => _playerService.SetMoveInput(_controls.Player.Move.ReadValue<Vector2>());
}
```

Right:

```csharp
public sealed class InputService : IInputService, IInitializable, ITickable, IDisposable
{
    private readonly PlayerControls _controls = new();
    private Vector2 _moveInput;
    private bool _jumpPressed;

    public Vector2 MoveInput => _moveInput;
    public bool JumpPressed => _jumpPressed;

    public void Initialize()
    {
        _controls.Player.Enable();
        _controls.Player.Jump.performed += OnJump;
    }

    public void Tick()
    {
        _moveInput = _controls.Player.Move.ReadValue<Vector2>();
    }

    public void Dispose()
    {
        _controls.Player.Jump.performed -= OnJump;
        _controls.Player.Disable();
        _controls.Dispose();
    }

    public void LateTick()
    {
        _jumpPressed = false;
    }

    private void OnJump(InputAction.CallbackContext _) => _jumpPressed = true;
}
```

`new PlayerControls()` is allowed because it is a generated dependency-free input
wrapper. Other services/providers are still constructed by VContainer.

## Card 2 — InputHandler Is Pure C#

Wrong:

```csharp
public sealed class PlayerInputView : MonoBehaviour
{
    [Inject] private IInputService _input;
    [Inject] private IPlayerService _player;
    private void Update() => _player.SetMoveInput(_input.MoveInput);
}
```

Right:

```csharp
public sealed class PlayerInputHandler : IPlayerInputHandler
{
    private readonly IInputService _inputService;
    private readonly IPlayerService _playerService;

    public PlayerInputHandler(IInputService inputService, IPlayerService playerService)
    {
        _inputService = inputService;
        _playerService = playerService;
    }

    public void Tick(float deltaTime)
    {
        _playerService.SetMoveInput(_inputService.MoveInput);

        if (_inputService.JumpPressed)
        {
            _playerService.Jump();
        }
    }
}
```

The Mono Shell (`PlayerController`) may call `_inputHandler.Tick(Time.deltaTime)`
from `Update()`. The handler does the routing; the shell only forwards lifecycle.

## Card 3 — One InputService

Register `InputService` once:

```csharp
builder.RegisterEntryPoint<InputService>().AsImplementedInterfaces();
```

Rules:

- Do not register `InputService` in multiple scene/prefab scopes.
- Do not use `Transient`.
- Do not create `PlayerControls` anywhere except `InputService`.
- Action map switching happens through `IInputService`, not direct `_controls`
  access.

## Generated C# Class

1. Create `Assets/_GameFolders/Input/PlayerControls.inputactions`.
2. Enable "Generate C# Class" in the Inspector.
3. Use the generated `PlayerControls` class only inside `InputService`.

## Interface Shape

```csharp
using UnityEngine;

namespace Game.Abstracts.Input
{
    public interface IInputService
    {
        Vector2 MoveInput { get; }
        bool JumpPressed { get; }
        void EnableGameplay();
        void EnableUI();
    }
}
```

## Rules

| Rule | Why |
|------|-----|
| `InputService` is pure C# | No serialized refs or Unity callbacks needed |
| `InputService` owns generated controls | Prevent duplicate subscriptions |
| Use `RegisterEntryPoint` | VContainer drives lifecycle and ticking |
| `InputHandler` is pure C# | Prefab-local input routing is testable |
| Every `+=` has matching `-=` | Prevent ghost callbacks |
| Read continuous input in `Tick` or `Update` equivalent | Do not read input in `FixedUpdate` |
| Legacy Input API forbidden | New Input System only |

## Forbidden

- `Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.mousePosition`
- `InputView : MonoBehaviour` for new code
- `PlayerControls` fields in controllers/views/providers
- Direct action map switching outside `InputService`
- Multiple `InputService` registrations

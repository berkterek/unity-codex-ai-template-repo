---
name: input-system
description: "Use when working with the New Input System — pure C# InputService plus per-prefab InputHandler pattern."
---

# Input System — InputService/InputHandler Pattern

## Setup

1. Create `Assets/_GameFolders/Input/PlayerControls.inputactions`.
2. Enable "Generate C# Class" in the Inspector.
3. Use generated `PlayerControls` only inside `InputService`.

## Architecture

- `InputService`: pure C#, owns `PlayerControls`, registered once as
  `RegisterEntryPoint<InputService>().AsImplementedInterfaces()`.
- `InputHandler`: pure C#, per-prefab or per-domain, routes input state to
  domain services.
- Mono Shell (`*Controller`) forwards `Update` to the handler; no input logic.

## Example

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

## Mandatory Rules

| Rule | Reason |
|------|--------|
| `InputService` owns `PlayerControls` | Prevent duplicate subscriptions |
| Register with `RegisterEntryPoint` | VContainer controls lifecycle and ticking |
| `+=` and `-=` pair | Prevent ghost callbacks |
| No legacy `Input.*` API | New Input System only |
| No `InputView` for new code | Input does not need a MonoBehaviour owner |
| Services receive commands/state only | Services stay input-system agnostic |

## Forbidden

```csharp
Input.GetKey(KeyCode.Space);
Input.GetAxis("Horizontal");
var controls = new PlayerControls(); // outside InputService
public sealed class InputView : MonoBehaviour { }
```

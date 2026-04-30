# Unity New Input System Guide

Use Unity's New Input System as the default input approach for new template
projects.

Do not use the legacy `Input.GetKey`, `Input.GetAxis`, or old Input Manager for
new work unless an existing project already depends on it and the project
overlay explicitly says to keep it.

## Project Overlay Should Define

Record these in `.codex/project/PROJECT.md`, `.codex/project/STRUCTURE.md`, or
`.codex/project/TOOLING.md`:

- Input package availability.
- Input Action Asset path.
- Generated C# class name, if generated classes are used.
- Action maps, such as `Player`, `UI`, `Menu`, or project-specific maps.
- Device targets, such as keyboard/mouse, gamepad, touch, or mobile.
- Rebinding policy.
- Whether input is event-driven, polled, or buffered.

## Recommended Structure

Use action maps by context:

```text
PlayerControls.inputactions
  Player
    Move      Value / Vector2
    Look      Value / Vector2
    Jump      Button
    Attack    Button
    Interact  Button
  UI
    Navigate  Value / Vector2
    Submit    Button
    Cancel    Button
  Menu
    Pause     Button
```

## Implementation Rules

- Prefer generated C# classes for type-safe action access when the project uses
  an Input Action Asset.
- Subscribe and unsubscribe input callbacks in matching lifecycle methods.
- Keep input collection separate from gameplay decisions when practical.
- Use input buffering for time-sensitive actions such as jump, dash, attack,
  and card or board interactions.
- Switch action maps when entering UI, gameplay, pause, or dialogue contexts.
- For mobile, record touch, safe area, and virtual-control expectations in the
  project overlay.

## Verification

When input changes:

- Confirm the Input Action Asset exists.
- Confirm generated classes are regenerated if enabled.
- Check console errors after script changes.
- Test action-map switching for gameplay and UI.
- Test keyboard/gamepad/touch paths that the project claims to support.

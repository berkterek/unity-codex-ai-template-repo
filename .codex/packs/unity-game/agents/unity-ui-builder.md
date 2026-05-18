# Unity UI Builder

UI Toolkit specialist — UXML, USS, runtime panel setup, data binding, responsive layout for Unity games.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/packs/unity-game/rules/architecture.md`
- Task description and UI design requirements.

## Capabilities

- **UXML** — declarative UI markup, hierarchy composition
- **USS** — styling, flex layout, responsive sizing
- **Runtime Panel** — UIDocument setup, panel settings, event handling
- **Data Binding** — runtime data → UI element connection
- **MCP Setup** — create UIDocument components via MCP for scene wiring

## UXML Structure

```xml
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <ui:VisualElement name="root" class="screen-container">
        <ui:Label name="title-label" class="title" text="Game Title"/>
        <ui:VisualElement name="button-container" class="button-row">
            <ui:Button name="play-button" class="btn btn--primary" text="Play"/>
            <ui:Button name="settings-button" class="btn btn--secondary" text="Settings"/>
        </ui:VisualElement>
    </ui:VisualElement>
</ui:UXML>
```

## USS Conventions

```css
.screen-container {
    flex-grow: 1;
    align-items: center;
    justify-content: center;
}

.title {
    font-size: 48px;
    -unity-font-style: bold;
    color: rgb(255, 255, 255);
}

.btn {
    width: 200px;
    height: 60px;
    margin: 8px;
}

.btn--primary {
    background-color: rgb(50, 180, 80);
}
```

## Runtime Code Pattern

```csharp
public sealed class MainMenuView : MonoBehaviour
{
    [SerializeField] private UIDocument _document;
    private Button _playButton;
    private readonly IEventBus _eventBus;

    public MainMenuView(IEventBus eventBus)
    {
        _eventBus = eventBus;
    }

    private void Awake()
    {
        var root = _document.rootVisualElement;
        _playButton = root.Q<Button>("play-button");
        _playButton.clicked += OnPlayClicked;
    }

    private void OnDestroy()
    {
        _playButton.clicked -= OnPlayClicked;
    }

    private void OnPlayClicked()
    {
        _eventBus.Publish(new PlayRequestedEvent());
    }
}
```

## Scene Setup via MCP

```
create_gameobject name:"UIRoot"
add_component type:"UIDocument"
set_component UIDocument.panelSettings = <PanelSettings asset>
set_component UIDocument.visualTreeAsset = <UXML asset>
```

## Rules

- Always unsubscribe from `clicked` in `OnDestroy`
- Use USS classes for styling — no inline styles in UXML
- `Q<T>("name")` in `Awake`, never in `Update`
- Fire events via IEventBus — never call other systems directly from UI
- Use `[SerializeField] private UIDocument _document` — injected in Inspector

# Unity UI Toolkit Builder

Builds Unity Editor tools using UI Toolkit: custom inspectors, EditorWindow subclasses, UXML templates, and USS stylesheets. Runtime UI in this project uses UGUI — this agent is for Editor-only UI Toolkit work.

## Project Rule

Per `event-patterns.md`: UI Toolkit is **Editor-only** in this project. All runtime UI is UGUI Canvas-based. Never put UIDocument or VisualElement in runtime (non-Editor) code.

## File Placement

```
Assets/
└── Editor/
    └── <ToolName>/
        ├── <ToolName>Window.cs
        ├── <ToolName>Inspector.cs
        ├── <ToolName>.uxml
        └── <ToolName>.uss
```

## EditorWindow Pattern

```csharp
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine.UIElements;
using UnityEditor.UIElements;

public sealed class ExampleWindow : EditorWindow
{
    [MenuItem("Tools/Example Window")]
    public static void ShowWindow()
    {
        var window = GetWindow<ExampleWindow>("Example");
        window.minSize = new Vector2(400, 300);
    }

    public void CreateGUI()
    {
        var visualTree = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>(
            "Assets/Editor/ExampleWindow/ExampleWindow.uxml");
        visualTree.CloneTree(rootVisualElement);

        var styleSheet = AssetDatabase.LoadAssetAtPath<StyleSheet>(
            "Assets/Editor/ExampleWindow/ExampleWindow.uss");
        rootVisualElement.styleSheets.Add(styleSheet);

        rootVisualElement.Q<Button>("apply-button").clicked += OnApplyClicked;
    }

    private void OnApplyClicked() { }
}
#endif
```

## Custom Inspector Pattern

```csharp
#if UNITY_EDITOR
[CustomEditor(typeof(MyComponent))]
public sealed class MyComponentInspector : Editor
{
    public override VisualElement CreateInspectorGUI()
    {
        var root = new VisualElement();
        var visualTree = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>(
            "Assets/Editor/MyComponent/MyComponentInspector.uxml");
        visualTree.CloneTree(root);
        root.Bind(serializedObject);
        return root;
    }
}
#endif
```

## UXML Template Pattern

```xml
<ui:UXML xmlns:ui="UnityEngine.UIElements" xmlns:uie="UnityEditor.UIElements">
    <ui:VisualElement class="container">
        <ui:Label text="My Tool" class="title" />
        <uie:PropertyField binding-path="myField" label="My Field" />
        <ui:Button name="apply-button" text="Apply" />
    </ui:VisualElement>
</ui:UXML>
```

## USS Stylesheet Pattern

```css
.container { padding: 8px; flex-direction: column; }
.title { font-size: 14px; -unity-font-style: bold; margin-bottom: 8px; }
Button { margin-top: 4px; height: 28px; }
Button:hover { background-color: rgb(80, 120, 200); }
```

## Data Binding

Prefer automatic binding:

```csharp
var field = new PropertyField(serializedObject.FindProperty("_speed"), "Speed");
root.Add(field);
root.Bind(serializedObject);
```

Manual binding only when custom logic is needed:

```csharp
var toggle = root.Q<Toggle>("active-toggle");
toggle.value = target.IsActive;
toggle.RegisterValueChangedCallback(evt =>
{
    Undo.RecordObject(target, "Toggle Active");
    target.IsActive = evt.newValue;
    EditorUtility.SetDirty(target);
});
```

## Rules

| Rule | Why |
|------|-----|
| All files under `Assets/Editor/` | Editor-only, stripped from builds |
| Always `#if UNITY_EDITOR` guard | Prevents build failure if file escapes Editor folder |
| `CreateGUI()` not `OnGUI()` | UI Toolkit entry point |
| `root.Bind(serializedObject)` after adding all elements | Ensures all PropertyFields are bound |
| `Undo.RecordObject` before manual changes | Ctrl+Z support |
| `EditorUtility.SetDirty` after manual changes | Marks asset/scene as modified |
| Never `UIDocument` in runtime scenes | Runtime UI = UGUI only |

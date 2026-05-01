# Technical Design Document

Use this template before implementation when a feature or system needs a clear
technical plan.

## 1. Technical Overview

Describe the implementation approach:

- Goal:
- Non-goals:
- Main constraints:

## 2. Unity Version And Target Platform

```text
Unity Version:
Render Pipeline:
Target Platform:
Orientation:
Input System:
Scripting Backend:
```

## 3. Architecture

Recommended structure, if the project has no stronger rule:

```text
Core/
Systems/
Views/
Data/
UI/
Composition/
Tests/
```

Explain which layers will be used and why:

- Core:
- Systems:
- Views:
- Data:
- UI:
- Composition:

## 4. Main Systems

For each system:

```text
System Name:
Responsibility:
Dependencies:
Input:
Output:
Unity Coupling:
Testability:
```

## 5. Core Models

List pure C# models and data structures:

```text
Model:
Fields:
Purpose:
Rules:
```

## 6. MonoBehaviour Views And Adapters

List Unity-facing behaviours:

```text
View:
Scene Role:
Serialized References:
Events Sent:
Events Received:
```

## 7. Data And Config

List ScriptableObjects or config classes:

```text
Config:
Fields:
Used By:
Designer Tunable:
Migration Risk:
```

## 8. Dependency Wiring

If DI is used:

```text
DI Framework:
Installers:
Bindings:
Lifetime:
```

If DI is not used, describe how dependencies are created and passed.

## 9. Input Plan

- Input Action Asset:
- Generated input class:
- Action maps:
- Devices:
- Rebinding:
- Input buffering:
- UI navigation:

## 10. Performance Considerations

Check:

- Allocations:
- Update loops:
- Pooling:
- Physics:
- UI rebuilds:
- Draw calls:
- Mobile constraints:

## 11. Save And Persistence

Describe what needs to be saved:

```text
Data:
Format:
Versioning:
Migration:
```

## 12. Testing Plan

```text
EditMode Tests:
PlayMode Tests:
Manual Tests:
Unity Console Checks:
```

## 13. Implementation Phases

```text
Phase 1:
Goal:
Tasks:
Validation:

Phase 2:
Goal:
Tasks:
Validation:
```

## 14. Risks And Trade-Offs

- `[risk or trade-off]`

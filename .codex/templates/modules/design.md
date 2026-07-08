# Design: [Module Name]

> Module: [number-slug]
> Spec: spec.md

## Architecture Summary

[Short summary of how this module fits the project architecture.]

## Dependencies

- Depends on: [module/interface]
- Publishes: [events]
- Subscribes to: [events]

## Public Contracts

```csharp
namespace Game.Abstracts.[Domain]
{
    public interface I[Domain]Service
    {
    }
}
```

## Runtime Types

| Type | Path | Role |
|------|------|------|
| `I[Domain]Service` | `Assets/_GameFolders/Scripts/Games/Abstracts/[Domain]/I[Domain]Service.cs` | Public contract |
| `[Domain]Service` | `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Service.cs` | Pure C# service |
| `[Domain]Module` | `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Module.cs` | Static VContainer wiring |

## Data And Configuration

- `[Domain]Configuration`: [fields and validation rules]
- `ConfigCatalog`: [field/property/null-check additions]

## Events

- `[EventName]Event`: [when published, payload]

## Testing Strategy

- EditMode: [service behavior]
- PlayMode: [scene or Unity lifecycle behavior]
- NoTest rationale: [only if applicable]

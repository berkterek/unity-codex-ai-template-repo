# Coding Conventions Import Manifest

Source file:
`/Users/berkterek/Downloads/00_CodingConventions.md`

Generated template:
`.codex/templates/CODING_CONVENTIONS.md`

## What Became General Template

- Naming conventions for types, interfaces, methods, properties, fields,
  constants, locals, parameters, events.
- File name equals primary type name.
- One primary type per file, with documented exceptions.
- Region policy as a project-selectable option instead of a base rule.
- Plain C# null checks and Unity object null checks split into separate rules.
- Async policy as a selectable project decision (`UniTask`, `Task`, etc.).
- Dependency injection principles: composition root, constructor injection,
  interface boundaries, no service locator/context objects.
- Event subscription lifecycle table.
- Layer/module dependency principles.
- Portable module skeleton, generalized from the original Store/Audio examples.
- Defensive programming rules: fail fast, guard clauses, try/finally cleanup.
- Test naming and Arrange/Act/Assert conventions.
- Optional Unity overlay and optional ECS/DOTS overlay.

## What Stayed Project-Specific

- `SpaceTroopers` project name and exact namespaces.
- `_Framework`, `_GameFolders`, `_Scenes`, `Games/Abstracts`,
  `Games/Concretes` folder names.
- Exact assembly names such as `SpaceTroopersGames`,
  `SpaceTroopersEditor`, `SpaceTroopersTests`.
- Exact scene topology: `Bootstrap`, `Menu`, `Game`.
- Exact VContainer types: `AppScope`, `AppInstaller`, `ModuleInstaller`,
  `MenuScope`, `GameScope`.
- Exact provider locations such as
  `_GameFolders/Scripts/Games/Concretes/<Module>/`.
- Exact test assemblies and `NSubstitute.dll` asmdef setup.
- Exact ECS systems from SpaceTroopers examples.

## What Should Be A Pack, Not Core

- Unity serialization and `SerializeField` policy.
- Unity object creation and prefab hierarchy rules.
- VContainer registration details.
- UniTask requirement.
- Unity Test Framework PlayMode/EditMode split.
- ECS/DOTS naming, authoring, baker, command buffer, bridge system rules.

These belong in a `unity` or `unity-dots` pack and should only be applied when
the project opts into that technology stack.

## Conflicts To Resolve Per Project

- Public config fields vs `[SerializeField] private`: choose one policy.
- Runtime `Instantiate`: choose `pool-only`, `prefab-instantiate-allowed`, or
  standard Unity behavior.
- Mocking style: original document uses NSubstitute; some projects may prefer
  hand-written fakes.
- Region usage: original document requires regions in project scripts; base
  template makes this selectable.
- Namespace mapping: original document assumes `_Framework`/`_GameFolders`;
  template requires project-specific mapping.


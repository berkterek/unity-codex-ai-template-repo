# Tasks: [Module Name]

> Design: design.md
> Status: Pending

## Phase 0 — Foundation

- [ ] T001 `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Module.cs` — Add static module installer with `Install(IContainerBuilder builder, [Domain]Configuration config)`
  - Type: Add
  - Agent: unity-coder
  - Test type: EditMode
  - Outputs: `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Module.cs`
  - Acceptance: No compile errors; module can be called from `AppModules.Install(...)`.

## Phase 1 — Playable Slice

- [ ] T002 [parallel_group:1] `Assets/_GameFolders/Scripts/Games/Abstracts/[Domain]/I[Domain]Service.cs` — Add public service interface
  - Type: Add
  - Agent: coder
  - Test type: NoTest
  - Outputs: `Assets/_GameFolders/Scripts/Games/Abstracts/[Domain]/I[Domain]Service.cs`
  - Acceptance: Interface compiles and exposes only module-level operations.

- [ ] T003 [parallel_group:1] `Assets/_GameFolders/Scripts/Tests/[Project]EditModeTest/[Domain]ServiceTests.cs` — Add EditMode tests
  - Type: Add
  - Agent: tester
  - Test type: EditMode
  - Outputs: `Assets/_GameFolders/Scripts/Tests/[Project]EditModeTest/[Domain]ServiceTests.cs`
  - Acceptance: Tests fail before implementation and cover spec acceptance criteria.

- [ ] T004 `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Service.cs` — Implement service behavior
  - Type: Add
  - Agent: coder
  - Test type: EditMode
  - Inputs: `Assets/_GameFolders/Scripts/Games/Abstracts/[Domain]/I[Domain]Service.cs`
  - Outputs: `Assets/_GameFolders/Scripts/Games/Concretes/[Domain]/[Domain]Service.cs`
  - Acceptance: T003 tests pass; no UnityEngine dependency in the service.

**Checkpoint: Phase 1 independent test passes.**

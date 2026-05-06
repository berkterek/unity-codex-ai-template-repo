# Check Portability — Module Portability Audit

Audits one or more modules to verify they are portable — can be copy-pasted to
another project without modification.

## Usage

```
/check-portability <module name or path>
/check-portability AudioModule
/check-portability _GameFolders/Scripts/Games/AudioModule
```

If no argument is given, ask: "Which module(s) should be audited?"

---

## Inputs To Read

Before starting, read:

- `.codex/packs/unity-game/rules/architecture.md`
- `.codex/project/RULES.md`

---

## What You Check

For each module folder provided
(`_GameFolders/Scripts/Games/[ModuleName]/`):

### 1. No UnityEngine in Service Class

- Read `[ModuleName]Service.cs`.
- FAIL if `using UnityEngine` is present.
- PASS if clean; note if a Provider exists in
  `Concretes/[ModuleName]/`.

### 2. No Concrete Cross-Module Dependencies

- Check constructor parameters of `[ModuleName]Service.cs`.
- FAIL if any parameter is a concrete class from another module
  (not an interface).

### 3. Config Null Guard

- Check `[ModuleName]Installer.cs`.
- FAIL if `Install()` has no null check on `_config` before registering.

### 4. Events in Own File

- Check if `IEvent` structs are in `[ModuleName]Events.cs`.
- WARN if they are embedded inside the service file.

### 5. Provider Separation

- Check `_GameFolders/Scripts/Games/Concretes/[ModuleName]/`.
- WARN if provider files are inside the module folder instead.

### 6. Interface Coverage

- Check `I[ModuleName]Service.cs`.
- WARN if `[ModuleName]Service.cs` has public methods not declared in
  the interface.

---

## Output Format

```
## Portability Audit: AudioModule

PASS  No UnityEngine in AudioService.cs
PASS  Only interface dependencies in constructor
PASS  Config null guard present in AudioInstaller.Install()
PASS  Events in AudioEvents.cs
PASS  Provider in Concretes/Audio/ (BasicAudioProvider.cs)
WARN  AudioService.SetVolume() is public but not declared in IAudioService

Result: PORTABLE with 1 warning
```

If any check **fails** (not just warns), the module is **NOT PORTABLE** and
the output explains what to fix.

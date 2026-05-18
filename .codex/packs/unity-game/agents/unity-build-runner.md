# Unity Build Runner

Configures and triggers Unity builds via MCP. Handles platform switching, player settings, build profiles, Addressables builds, and monitors build progress.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/project/TOOLING.md`

## Build Workflow

### Step 1: Check Current State
```
project_info → current platform, Unity version
manage_build action:"get_settings" → current player settings
read_console → any existing errors
```

### Step 2: Configure Build
```
manage_build action:"set_player_settings"
manage_build action:"set_scenes"
manage_build action:"switch_platform" (if needed)
```

### Step 3: Platform-Specific Configuration

**Android:**
- Minimum API level 24+
- IL2CPP backend for release
- ARM64 architecture (disable ARMv7)
- Package name: `com.company.gamename`
- Target API: latest stable
- Enable AAB for Play Store

**iOS:**
- Bundle identifier: `com.company.gamename`
- Minimum iOS version: 15.0+
- Signing team ID — warn user to configure in Xcode

### Step 4: Pre-Build Checks
- `read_console` — ensure no compilation errors
- Verify all build scenes exist
- Check no `UnityEditor` namespace leaks

### Step 5: Execute Build
```
manage_build action:"build"
```

Monitor progress via `read_console`.

### Step 6: Post-Build
- Report build result (success/failure), build size, and warnings
- If Addressables: remind to build Addressables content separately

## Build Profiles (Unity 6+)

```
manage_build action:"create_profile"
manage_build action:"set_active_profile"
```

## Common Build Issues

| Error | Cause | Fix |
|-------|-------|-----|
| `UnityEditor namespace` | Editor code in build | Add `#if UNITY_EDITOR` guard |
| `Type not found` | Missing assembly reference | Check .asmdef references |
| `Stripping` removes code | IL2CPP strips unused code | Add to `link.xml` |
| Build size too large | Uncompressed assets | Check texture/audio compression |

## Rules

- Never modify ProjectSettings/ files directly — use MCP
- Never build without checking for compilation errors first
- Never assume keystore/signing credentials are configured
- Always switch platform before build

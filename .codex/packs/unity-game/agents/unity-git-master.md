# Unity Git Master

Unity-aware git operations — LFS configuration, merge strategies for binary assets, .meta file hygiene, branch naming, .gitattributes maintenance.

**Bash usage restricted to git commands only.**

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.gitattributes` (if exists)
- `.gitignore` (if exists)

## Capabilities

### Git LFS Setup

Configure `.gitattributes` to track large Unity binary files:

- Textures: `*.psd *.tga *.png *.jpg *.jpeg *.gif *.bmp *.tif *.tiff *.exr *.hdr`
- 3D Models: `*.fbx *.obj *.blend *.max *.ma *.mb *.3ds *.dae`
- Audio: `*.wav *.mp3 *.ogg *.aif *.aiff *.flac *.bank`
- Video: `*.mp4 *.mov *.avi *.webm`
- Unity-specific: `*.unity *.asset *.cubemap *.unitypackage`
- Fonts: `*.ttf *.otf`

### .meta File Hygiene

- Every file and folder under `Assets/` must have a corresponding `.meta` file
- No orphaned `.meta` files
- No duplicate GUIDs across `.meta` files (causes silent reference breaks)
- `.meta` files committed alongside their assets — never one without the other

### .gitattributes for Unity

```
*.unity merge=unityyamlmerge diff
*.prefab merge=unityyamlmerge diff
*.asset merge=unityyamlmerge diff
*.meta merge=unityyamlmerge diff
*.png binary
*.psd binary
*.fbx binary
*.wav binary
*.mp3 binary
*.cs text=auto diff=csharp
*.shader text=auto
*.json text=auto
```

### .gitignore Template

```
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]serSettings/
.vs/
.vscode/
*.csproj
*.sln
.DS_Store
Thumbs.db
*.apk
*.aab
*.ipa
```

### Branch Naming

- `feature/<description>` — new features
- `fix/<description>` — bug fixes
- `release/<version>` — release preparation
- `hotfix/<description>` — production fixes
- `refactor/<description>` — code restructuring

### Merge Conflict Resolution

- `.unity` and `.prefab` — use UnityYAMLMerge, prefer target branch version if unresolvable
- `.meta` files — keep the version whose `guid:` is referenced elsewhere in the project
- `.asmdef` files — merge both reference sets, remove duplicates

## Rules

- Explain each git command before executing it
- Never run non-git shell commands
- Never force push to main/master

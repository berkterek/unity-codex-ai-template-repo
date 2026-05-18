# Unity Git Master

> Apply `.codex/packs/unity-game/guides/guardrails.md` rules throughout.

Unity-aware git operations — LFS configuration, merge strategies for binary
assets, .meta file hygiene, branch naming, .gitattributes maintenance.

**Bash usage is restricted to git commands only.** Do not run arbitrary shell
commands. Only execute `git` and `git lfs` commands.

## Inputs To Read

- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/PROJECT.md`
- Task description.

---

## 1. Git LFS Setup

Configure `.gitattributes` to track large binary files:

**Textures:** `*.psd`, `*.tga`, `*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.bmp`,
`*.tif`, `*.tiff`, `*.exr`, `*.hdr`

**3D Models:** `*.fbx`, `*.obj`, `*.blend`, `*.max`, `*.ma`, `*.mb`, `*.3ds`,
`*.dae`, `*.c4d`

**Audio:** `*.wav`, `*.mp3`, `*.ogg`, `*.aif`, `*.aiff`, `*.flac`, `*.bank`

**Video:** `*.mp4`, `*.mov`, `*.avi`, `*.webm`

**Unity-specific:** `*.unity`, `*.asset`, `*.cubemap`, `*.unitypackage`

**Fonts:** `*.ttf`, `*.otf`

Run `git lfs install` to set up hooks, then `git lfs track` for each pattern.
Verify with `git lfs track` (no args) to list tracked patterns.

---

## 2. .meta File Hygiene

Validate that Unity's .meta file ecosystem is intact:
- Every file and folder under `Assets/` must have a corresponding `.meta` file.
- No orphaned `.meta` files (meta whose asset no longer exists).
- No duplicate GUIDs across `.meta` files (causes silent reference breaks).
- `.meta` files must be committed alongside their assets — never one without the other.

Use `git status` to detect uncommitted .meta files. Use Grep to scan for
duplicate `guid:` values across `.meta` files.

---

## 3. .gitattributes for Unity

```
# Unity YAML
*.unity merge=unityyamlmerge diff
*.prefab merge=unityyamlmerge diff
*.asset merge=unityyamlmerge diff
*.meta merge=unityyamlmerge diff

# Binary files — no merge, no diff
*.png binary
*.psd binary
*.tga binary
*.fbx binary
*.obj binary
*.wav binary
*.mp3 binary
*.ogg binary

# C# scripts — normalize line endings
*.cs text=auto diff=csharp
*.shader text=auto
*.cginc text=auto
*.hlsl text=auto
*.compute text=auto

# Config
*.json text=auto
*.xml text=auto
*.yaml text=auto
*.yml text=auto
```

If UnityYAMLMerge is available (ships with Unity), configure it as the merge
tool in `.gitconfig` or provide instructions.

---

## 4. .gitignore Template

```
# Unity generated
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]serSettings/
[Mm]emoryCaptures/

# IDE
.vs/
.vscode/
*.csproj
*.sln
*.suo
*.tmp
*.user

# OS
.DS_Store
Thumbs.db

# Build artifacts
*.apk
*.aab
*.ipa
*.exe

# Gradle (Android)
ExportedObj/
.gradle/

# Packages
Packages/packages-lock.json
```

---

## 5. Branch Hygiene

Naming conventions:
- `feature/<description>` — new features
- `fix/<description>` — bug fixes
- `release/<version>` — release preparation
- `hotfix/<description>` — production fixes
- `refactor/<description>` — code restructuring

Help with:
- Creating properly named branches
- Listing and cleaning up merged branches (`git branch --merged`)
- Identifying stale branches

---

## 6. Merge Conflict Resolution

- **`.unity` and `.prefab` files** — recommend UnityYAMLMerge. If conflicts
  remain, prefer the target branch version and re-apply changes in the Unity
  Editor.
- **`.meta` files** — the correct version is whichever has the GUID referenced
  elsewhere in the project. Check both versions and prefer that GUID.
- **`ProjectSettings/*.asset`** — merge carefully, prefer the version with
  newer settings but verify each changed line.
- **`.asmdef` files** — merge both sets of references, remove duplicates.

When running git commands, always explain what each command does before
executing it.

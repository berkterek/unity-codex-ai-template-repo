# Unity Performance Optimizer

Profiles and optimizes Unity performance. Uses MCP profiler for frame timing, memory snapshots, and rendering stats. Identifies CPU/GPU bottlenecks, GC spikes, and draw call issues.

## Inputs To Read
- `.codex/packs/unity-game/guides/guardrails.md`

- `.codex/project/PROJECT.md`
- `.codex/packs/unity-game/rules/performance.md`
- Source files for identified hot paths.

## Profiling Workflow

### Step 1: Capture Profile Data
```
manage_profiler action:"start_session"
manage_profiler action:"get_frame_timing" → CPU/GPU frame times
manage_profiler action:"memory_snapshot" → detailed memory breakdown
manage_graphics action:"get_rendering_stats" → draw calls, batches, triangles
```

### Step 2: Identify Bottleneck Type

**CPU-bound** (frame time > 16.6ms):
- GC allocations in gameplay code
- Expensive Update loops
- Physics queries
- UI rebuilds

**GPU-bound** (GPU time > CPU time):
- Too many draw calls (>100 on mobile)
- Overdraw (transparent layers stacking)
- Complex shaders (too many instructions)
- High fill rate

**Memory issues:**
- Texture memory
- Audio clips loaded uncompressed
- Addressables handles not released
- Object pool sizing

### Step 3: Code Analysis

Grep for anti-patterns in hot paths:
- `GetComponent` in Update methods
- `Camera.main` without caching
- `FindObjectOfType` in gameplay code
- LINQ in Update/FixedUpdate
- String concatenation in Update
- `new` keyword inside Update/FixedUpdate

### Step 4: Fix and Verify

Apply fixes, then re-profile to confirm improvement:
```
manage_profiler action:"start_session" → new profile after fix
manage_profiler action:"get_frame_timing" → compare before/after
```

## Performance Budgets

| Metric | Low-End Mobile | Mid-Range Mobile |
|--------|---------------|-----------------|
| Draw calls | < 50 | < 100 |
| Frame time | 33ms (30fps) | 16.6ms (60fps) |
| Texture memory | < 100MB | < 150MB |
| GC alloc per frame | 0 bytes | 0 bytes |

## Common Optimizations

| Issue | Fix |
|-------|-----|
| GC spikes | Remove allocations from Update, pool objects |
| Expensive GetComponent | Cache in Awake |
| Too many draw calls | SRP Batcher, GPU instancing, static batching |
| Large textures | ASTC compression, reduce max size |
| Audio memory | Compress, stream music, decompress-on-load for SFX |
| Addressables leaks | Release all handles in Dispose |

## Rules

- Don't optimize without profiling first — measure, then fix
- Don't optimize initialization code (runs once)
- Don't sacrifice readability for micro-optimizations
- Always test on actual devices — Editor profiler is not representative of mobile
- No VFX Graph or compute shaders — they don't work on mobile

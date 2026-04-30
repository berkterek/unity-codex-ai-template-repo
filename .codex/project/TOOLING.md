# Tooling Overlay

This file defines commands agents should use to inspect, build, test, lint,
format, and run this project.

## Environment

| Tool | Version/Command |
|------|-----------------|
| Runtime | `[command --version]` |
| Package manager | `[command --version]` |
| Build tool | `[command --version]` |

## Setup

```bash
[install dependencies command]
```

## Common Commands

| Purpose | Command |
|---------|---------|
| Install dependencies | `[command]` |
| Build | `[command]` |
| Typecheck | `[command]` |
| Lint | `[command]` |
| Format check | `[command]` |
| Format write | `[command]` |
| Unit tests | `[command]` |
| Integration tests | `[command]` |
| Full verification | `[command]` |
| Dev server | `[command]` |

## Verification Strategy

For small changes:

```bash
[narrow verification command]
```

For shared or risky changes:

```bash
[full verification command]
```

Before commit:

```bash
[pre-commit verification command]
```

## Generated Files

Do not edit these manually unless the task explicitly requires it:

- `[path or pattern]`

## External Services

List commands that require network, credentials, simulator, editor, or other
external state:

- `[command]` - `[requirements]`

## Local Server

If the project has a server:

| Field | Value |
|-------|-------|
| Default port | `[port]` |
| Start command | `[command]` |
| Health check | `[URL or command]` |


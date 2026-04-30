# Project Rules Overlay

This file contains project-specific rules that are not general enough for
`.codex/core` and not broad enough for a reusable pack.

For coding style, prefer `CODING_CONVENTIONS.md`.

## Hard Rules

These block completion if violated:

- `[rule]`

## Soft Rules

These guide implementation but may be waived with a reason:

- `[rule]`

## Architecture Boundaries

Allowed dependency directions:

```text
[Layer A] -> [Layer B]
[Layer B] -> [Layer C]
```

Forbidden dependencies:

- `[forbidden dependency]`

## API And Contract Rules

- `[rule]`

## Data And Migration Rules

- `[rule]`

## Security And Secrets

- Do not commit credentials, tokens, private keys, or local machine config.
- `[project-specific secret rule]`

## Performance Rules

- `[rule]`

## Documentation Rules

- `[rule]`

## Review Rules

Reviewer must fail work when:

- `[blocking review condition]`


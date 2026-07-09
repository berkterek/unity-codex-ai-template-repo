# Workflows

## guardrails.yml

Runs the Codex guardrail suite on every push and pull request:

```bash
bash .codex/guardrails/test/verify-guardrails.sh
bash .codex/guardrails/test/verify-integration.sh
bash .codex/guardrails/run.sh --changed
```

`verify-guardrails.sh` is the regression harness for blocking/warning rules.
It includes negative controls for known false positives such as third-party
code, editor folders, installer/scope classes, and `IEventBus` references.

`verify-integration.sh` confirms the local git hook and GitHub workflow still
invoke the guardrail runner.

The workflow uses `actions/checkout@v5`.

## graph-tests.yml

Runs the Codex knowledge graph integration harness on pushes and pull requests
that touch graph tooling:

```bash
bash .codex/graph/test/verify-graphify.sh
```

The workflow installs `jq`, sets up Python 3.12, and verifies the builder,
validator, traversal helpers, MCP cache merge behavior, and known regression
fixtures from a clean checkout.

#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd -P)"
PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %s\n%s\n' "$1" "$2"
}

assert_file_contains() {
  local name="$1"
  local file="$2"
  local pattern="$3"

  if [ ! -f "$file" ]; then
    fail "$name" "Missing file: $file"
    return
  fi

  if ! grep -qE "$pattern" "$file"; then
    fail "$name" "Expected pattern '$pattern' in $file"
    return
  fi

  pass "$name"
}

assert_file_contains \
  "pre-commit hook runs staged guardrails" \
  "$ROOT/.githooks/pre-commit" \
  'bash[[:space:]]+\.codex/guardrails/run\.sh[[:space:]]+--staged'

assert_file_contains \
  "CI workflow runs changed guardrails" \
  "$ROOT/.github/workflows/guardrails.yml" \
  'bash[[:space:]]+\.codex/guardrails/run\.sh[[:space:]]+--changed'

precommit_output="$(cd "$ROOT" && bash .githooks/pre-commit 2>&1)"
precommit_status=$?
if [ "$precommit_status" -eq 0 ]; then
  pass "pre-commit hook exits cleanly with no staged files"
else
  fail "pre-commit hook exits cleanly with no staged files" "$precommit_output"
fi

printf '\nGuardrail integration verifier: %s pass, %s fail\n' "$PASS_COUNT" "$FAIL_COUNT"

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

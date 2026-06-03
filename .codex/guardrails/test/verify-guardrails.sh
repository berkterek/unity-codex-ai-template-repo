#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd -P)"
RUNNER="$ROOT/.codex/guardrails/run.sh"
TMP_DIR=""
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

trap cleanup EXIT

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-guardrails-test.XXXXXX")"

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$1"
}

record_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %s\n%s\n' "$1" "$2"
}

write_sample() {
  local path="$1"
  local content="$2"
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$content" > "$path"
}

run_guardrail() {
  bash "$RUNNER" "$@" 2>&1
}

assert_block() {
  local name="$1"
  local rel="$2"
  local content="$3"
  local expected="$4"
  local file="$TMP_DIR/$rel"
  local output
  local status

  write_sample "$file" "$content"
  output="$(run_guardrail --files "$file")"
  status=$?

  if [ "$status" -ne 1 ]; then
    record_fail "$name" "Expected exit 1, got $status. Output:\n$output"
    return
  fi

  if ! printf '%s\n' "$output" | grep -q "BLOCK.*$expected"; then
    record_fail "$name" "Expected BLOCK containing '$expected'. Output:\n$output"
    return
  fi

  record_pass "$name"
}

assert_warn() {
  local name="$1"
  local rel="$2"
  local content="$3"
  local expected="$4"
  local file="$TMP_DIR/$rel"
  local output
  local status

  write_sample "$file" "$content"
  output="$(run_guardrail --files "$file")"
  status=$?

  if [ "$status" -ne 0 ]; then
    record_fail "$name" "Expected exit 0, got $status. Output:\n$output"
    return
  fi

  if ! printf '%s\n' "$output" | grep -q "WARN.*$expected"; then
    record_fail "$name" "Expected WARN containing '$expected'. Output:\n$output"
    return
  fi

  record_pass "$name"
}

assert_clean() {
  local name="$1"
  local rel="$2"
  local content="$3"
  local file="$TMP_DIR/$rel"
  local output
  local status

  write_sample "$file" "$content"
  output="$(run_guardrail --files "$file")"
  status=$?

  if [ "$status" -ne 0 ]; then
    record_fail "$name" "Expected exit 0, got $status. Output:\n$output"
    return
  fi

  if printf '%s\n' "$output" | grep -qE '^(BLOCK|WARN) '; then
    record_fail "$name" "Expected no findings. Output:\n$output"
    return
  fi

  record_pass "$name"
}

assert_block \
  "UnityEvent is blocked" \
  "Assets/Scripts/BadUnityEvent.cs" \
  'using UnityEngine.Events;
public sealed class BadUnityEvent
{
    private UnityEvent _clicked;
}' \
  "unity-event"

assert_block \
  "Time.timeScale assignment is blocked" \
  "Assets/Scripts/BadTimeScale.cs" \
  'using UnityEngine;
public sealed class BadTimeScale
{
    public void Pause()
    {
        Time.timeScale = 0f;
    }
}' \
  "time-scale"

assert_block \
  "Static singleton is blocked" \
  "Assets/Scripts/BadSingleton.cs" \
  'public sealed class BadSingleton
{
    public static BadSingleton Instance { get; private set; }
}' \
  "singleton"

assert_block \
  "Legacy input is blocked" \
  "Assets/Scripts/BadInput.cs" \
  'using UnityEngine;
public sealed class BadInput
{
    public bool JumpPressed()
    {
        return Input.GetKey(KeyCode.Space);
    }
}' \
  "legacy-input"

assert_block \
  "Runtime UnityEditor usage is blocked" \
  "Assets/Scripts/BadRuntimeEditor.cs" \
  'using UnityEditor;
public sealed class BadRuntimeEditor
{
    public void Ping()
    {
        EditorUtility.DisplayDialog("x", "y", "ok");
    }
}' \
  "unityeditor-runtime"

assert_block \
  "MonoBehaviour service allocation is blocked" \
  "Assets/Scripts/BadMonoService.cs" \
  'using UnityEngine;
public sealed class BadMonoService : MonoBehaviour
{
    private void Awake()
    {
        var service = new AudioService();
    }
}' \
  "monobehaviour-new-service"

assert_block \
  "Concrete service constructor dependency is blocked" \
  "Assets/Scripts/BadConstructor.cs" \
  'public sealed class PlayerService
{
    public PlayerService(AudioService audioService)
    {
    }
}' \
  "concrete-service-dependency"

assert_block \
  "Unity serialized asset text edit is blocked" \
  "Assets/Prefabs/Bad.prefab" \
  '%YAML 1.1
--- !u!1 &100000
GameObject:
  m_Name: Bad' \
  "unity-serialized-text-edit"

assert_warn \
  "Hot-path GetComponent warning" \
  "Assets/Scripts/WarnGetComponent.cs" \
  'using UnityEngine;
public sealed class WarnGetComponent : MonoBehaviour
{
    private void Update()
    {
        GetComponent<Rigidbody>();
    }
}' \
  "hot-path-getcomponent"

assert_warn \
  "Hot-path LINQ warning" \
  "Assets/Scripts/WarnLinq.cs" \
  'using System.Linq;
using UnityEngine;
public sealed class WarnLinq : MonoBehaviour
{
    private int[] _values = { 1, 2, 3 };
    private void Update()
    {
        _values.Where(value => value > 1).ToArray();
    }
}' \
  "hot-path-linq"

assert_clean \
  "Clean service passes" \
  "Assets/Scripts/CleanService.cs" \
  'public interface IAudioService
{
    void Play();
}

public sealed class PlayerService
{
    private readonly IAudioService _audioService;

    public PlayerService(IAudioService audioService)
    {
        _audioService = audioService;
    }
}'

serialize_repo="$TMP_DIR/serialize-repo"
mkdir -p "$serialize_repo/Assets/Scripts"
(
  cd "$serialize_repo" || exit 1
  git init -q
  git config user.email "guardrails@example.test"
  git config user.name "Guardrails Test"
  cat > Assets/Scripts/RenamedField.cs <<'CS'
using UnityEngine;
public sealed class RenamedField : MonoBehaviour
{
    [SerializeField] private int _oldScore;
}
CS
  git add Assets/Scripts/RenamedField.cs
  git commit -q -m "baseline"
  cat > Assets/Scripts/RenamedField.cs <<'CS'
using UnityEngine;
public sealed class RenamedField : MonoBehaviour
{
    [SerializeField] private int _newScore;
}
CS
  output="$(bash "$RUNNER" --changed 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    printf '[FAIL] SerializeField rename warning\nExpected exit 0, got %s. Output:\n%s\n' "$status" "$output"
    exit 10
  fi
  if ! printf '%s\n' "$output" | grep -q "WARN.*serialized-rename"; then
    printf '[FAIL] SerializeField rename warning\nExpected WARN containing serialized-rename. Output:\n%s\n' "$output"
    exit 11
  fi
)
serialize_status=$?
if [ "$serialize_status" -eq 0 ]; then
  record_pass "SerializeField rename warning"
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

printf '\nGuardrail verifier: %s pass, %s fail\n' "$PASS_COUNT" "$FAIL_COUNT"

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

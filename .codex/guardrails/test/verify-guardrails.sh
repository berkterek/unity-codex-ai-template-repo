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
  "new-service"

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

assert_block \
  "Runtime new GameObject is blocked" \
  "Assets/Scripts/BadNewGameObject.cs" \
  'using UnityEngine;
public sealed class BadNewGameObject
{
    public GameObject Create()
    {
        return new GameObject("Bad");
    }
}' \
  "new-gameobject"

assert_clean \
  "Editor new GameObject is allowed" \
  "Assets/Scripts/Editor/EditorTool.cs" \
  'using UnityEngine;
public sealed class EditorTool
{
    public GameObject CreatePreview()
    {
        return new GameObject("Preview");
    }
}'

assert_clean \
  "Editors folder new GameObject is allowed" \
  "Assets/_Framework/Editors/EditorTool.cs" \
  'using UnityEngine;
public sealed class EditorTool
{
    public GameObject CreatePreview()
    {
        return new GameObject("Preview");
    }
}'

assert_clean \
  "Plugin legacy input is allowed" \
  "Assets/Plugins/ThirdPartyInput.cs" \
  'using UnityEngine;
public sealed class ThirdPartyInput
{
    public bool JumpPressed()
    {
        return Input.GetKey(KeyCode.Space);
    }
}'

assert_block \
  "ECS enum without byte base is blocked" \
  "Assets/Scripts/Game/Ecs/BadEcsEnum.cs" \
  'using Unity.Entities;
public struct BadEcsEnumComponent : IComponentData
{
    public State Value;
    public enum State
    {
        Idle,
        Moving
    }
}' \
  "enum-byte-base"

assert_block \
  "Multi-interface IEvent enum without byte base is blocked" \
  "Assets/Scripts/Game/Events/BadEventEnum.cs" \
  'using System;
public interface IEvent {}
public struct BadEvent : IDisposable, IEvent
{
    public Direction Value;
    public void Dispose() {}
}
public enum Direction
{
    Up,
    Down
}' \
  "enum-byte-base"

assert_clean \
  "IEventBus field with plain enum is allowed" \
  "Assets/Scripts/Game/ChestFlowController.cs" \
  'public interface IEventBus {}
public sealed class ChestFlowController
{
    private readonly IEventBus _eventBus;
    private ChestFlowState _state;

    private enum ChestFlowState
    {
        Closed,
        Open
    }
}'

assert_block \
  "ProjectSettings asset edit is blocked" \
  "ProjectSettings/ProjectSettings.asset" \
  '%YAML 1.1
PlayerSettings:
  companyName: Bad' \
  "project-settings"

assert_block \
  "Runtime inputactions edit is blocked" \
  "Assets/Input/PlayerControls.inputactions" \
  '{"name":"PlayerControls"}' \
  "config-protection"

assert_block \
  "Non-test asmdef edit is blocked" \
  "Assets/Scripts/Game.Game.asmdef" \
  '{"name":"Game.Game"}' \
  "config-protection"

assert_block \
  "MonoBehaviour inheritance in service folder is blocked" \
  "Assets/_GameFolders/Scripts/Games/Concretes/Audio/AudioService.cs" \
  'using UnityEngine;
public sealed class AudioService : MonoBehaviour
{
}' \
  "service-unity-inheritance"

assert_clean \
  "Installer in service folder may inherit MonoBehaviour" \
  "Assets/_GameFolders/Scripts/Games/Concretes/Installers/AudioInstaller.cs" \
  'using UnityEngine;
public sealed class AudioInstaller : MonoBehaviour
{
}'

assert_clean \
  "Scope in service folder may inherit MonoBehaviour" \
  "Assets/_GameFolders/Scripts/Games/Concretes/Scopes/GameScope.cs" \
  'using UnityEngine;
public sealed class GameScope : MonoBehaviour
{
}'

assert_clean \
  "Swappable backend Dal may import UnityEngine" \
  "Assets/_GameFolders/Scripts/Games/Concretes/SaveLoad/LocalSaveLoadDal.cs" \
  'using UnityEngine;
public sealed class LocalSaveLoadDal
{
    public string Path => Application.persistentDataPath;
}'

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

assert_warn \
  "Destroy outside pool manager warning" \
  "Assets/Scripts/BadDestroy.cs" \
  'using UnityEngine;
public sealed class BadDestroy : MonoBehaviour
{
    public void Remove(GameObject target)
    {
        Destroy(target);
    }
}' \
  "runtime-destroy"

assert_warn \
  "async void warning outside lifecycle" \
  "Assets/Scripts/WarnAsyncVoid.cs" \
  'public sealed class WarnAsyncVoid
{
    public async void Load()
    {
    }
}' \
  "async-void"

assert_warn \
  "UniTask without CancellationToken warning" \
  "Assets/Scripts/WarnUniTask.cs" \
  'using Cysharp.Threading.Tasks;
public sealed class WarnUniTask
{
    public async UniTask LoadAsync()
    {
    }
}' \
  "unitask-cancellation"

assert_warn \
  "Unity null propagation warning" \
  "Assets/Scripts/WarnNullPropagation.cs" \
  'using UnityEngine;
public sealed class WarnNullPropagation : MonoBehaviour
{
    [SerializeField] private Transform _target;
    public void Ping()
    {
        _target?.gameObject.SetActive(true);
    }
}' \
  "unity-null-propagation"

assert_warn \
  "GetComponent in Awake warning" \
  "Assets/Scripts/WarnAwakeGetComponent.cs" \
  'using UnityEngine;
public sealed class WarnAwakeGetComponent : MonoBehaviour
{
    private Rigidbody _body;
    private void Awake()
    {
        _body = GetComponent<Rigidbody>();
    }
}' \
  "awake-getcomponent"

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

pipeline_repo="$TMP_DIR/pipeline-repo"
mkdir -p "$pipeline_repo/Assets/_GameFolders/Scripts/Game"
(
  cd "$pipeline_repo" || exit 1
  git init -q
  git config user.email "guardrails@example.test"
  git config user.name "Guardrails Test"
  cat > Assets/_GameFolders/Scripts/Game/PlayerService.cs <<'CS'
public sealed class PlayerService
{
    public int Value => 1;
}
CS
  git add Assets/_GameFolders/Scripts/Game/PlayerService.cs
  git commit -q -m "baseline"
  mkdir -p .codex/project/state
  touch .codex/project/state/gate-cleared
  cat > Assets/_GameFolders/Scripts/Game/PlayerService.cs <<'CS'
public sealed class PlayerService
{
    public int Value => 2;
}
CS
  output="$(bash "$RUNNER" --changed 2>&1)"
  status=$?
  if [ "$status" -ne 1 ]; then
    printf '[FAIL] Pipeline direct work is blocked\nExpected exit 1, got %s. Output:\n%s\n' "$status" "$output"
    exit 12
  fi
  if ! printf '%s\n' "$output" | grep -q "BLOCK.*pipeline-direct-work"; then
    printf '[FAIL] Pipeline direct work is blocked\nExpected BLOCK containing pipeline-direct-work. Output:\n%s\n' "$output"
    exit 13
  fi
)
pipeline_status=$?
if [ "$pipeline_status" -eq 0 ]; then
  record_pass "Pipeline direct work is blocked"
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

critical_repo="$TMP_DIR/critical-repo"
mkdir -p "$critical_repo/Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure"
(
  cd "$critical_repo" || exit 1
  git init -q
  git config user.email "guardrails@example.test"
  git config user.name "Guardrails Test"
  cat > Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure/AppScope.cs <<'CS'
public sealed class AppScope
{
    public int Value => 1;
}
CS
  git add Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure/AppScope.cs
  git commit -q -m "baseline"
  cat > Assets/_GameFolders/Scripts/Games/Concretes/Infrastructure/AppScope.cs <<'CS'
public sealed class AppScope
{
    public int Value => 2;
}
CS
  output="$(bash "$RUNNER" --changed 2>&1)"
  status=$?
  if [ "$status" -ne 1 ] || ! printf '%s\n' "$output" | grep -q "BLOCK.*critical-architecture-investigation"; then
    printf '[FAIL] Critical architecture edit blocks first pass\nExpected critical block. Status: %s Output:\n%s\n' "$status" "$output"
    exit 14
  fi
  output="$(bash "$RUNNER" --changed 2>&1)"
  status=$?
  if [ "$status" -ne 0 ]; then
    printf '[FAIL] Critical architecture edit passes after acknowledgement\nExpected exit 0, got %s. Output:\n%s\n' "$status" "$output"
    exit 15
  fi
)
critical_status=$?
if [ "$critical_status" -eq 0 ]; then
  record_pass "Critical architecture edit deny-then-allow"
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

printf '\nGuardrail verifier: %s pass, %s fail\n' "$PASS_COUNT" "$FAIL_COUNT"

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi

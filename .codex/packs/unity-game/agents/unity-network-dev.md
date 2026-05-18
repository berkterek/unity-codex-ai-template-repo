# Unity Network Developer

> Apply `.codex/packs/unity-game/guides/guardrails.md` rules throughout.

Implements multiplayer networking. Writes network scripts AND sets up network
infrastructure via MCP. Supports Netcode for GameObjects, Mirror, Photon, and
Fish-Net.

## Inputs To Read

- `.codex/packs/unity-game/guides/guardrails.md`
- `.codex/project/PROJECT.md`
- `.codex/project/TOOLING.md`
- `.codex/packs/unity-game/rules/architecture.md`

---

## Framework Selection

Ask which framework the project uses, or detect from packages:

| Framework | Package | Best For |
|-----------|---------|----------|
| **Netcode for GameObjects** | `com.unity.netcode.gameobjects` | Official Unity solution, Relay/Lobby integration |
| **Mirror** | Assets/Mirror/ | Community standard, easy setup, great docs |
| **Photon Fusion/PUN** | `com.photonengine.fusion` | Hosted servers, tick-based prediction |
| **Fish-Net** | `com.firstgeargames.fishnet` | Performance-focused, prediction built-in |

---

## Netcode for GameObjects Patterns

### NetworkBehaviour Base

```csharp
public sealed class PlayerNetworkController : NetworkBehaviour
{
    [SerializeField] private float _moveSpeed = 5f;

    private NetworkVariable<Vector3> _networkPosition = new(
        writePerm: NetworkVariableWritePermission.Server);

    public override void OnNetworkSpawn()
    {
        if (IsOwner)
        {
            // Enable input for local player only
        }
    }

    // Input is supplied by InputView — never read Input.* here.
    private Vector2 _moveInput;
    public void SetMoveInput(Vector2 input) => _moveInput = input;

    private void Update()
    {
        if (!IsOwner) return;
        MoveServerRpc(new Vector3(_moveInput.x, 0, _moveInput.y));
    }

    [ServerRpc]
    private void MoveServerRpc(Vector3 input)
    {
        transform.position += input * _moveSpeed * Time.deltaTime;
        _networkPosition.Value = transform.position;
    }
}
```

### Key Patterns

- `NetworkVariable<T>` — automatic synchronization, server-authoritative
- `[ServerRpc]` — client calls, server executes
- `[ClientRpc]` — server calls, all clients execute
- `IsOwner` — check before processing input
- `IsServer` — check before authoritative logic
- `OnNetworkSpawn` / `OnNetworkDespawn` — lifecycle hooks

---

## Scene Setup via MCP

```
batch_execute:
  - Create NetworkManager GameObject
  - Add NetworkManager component
  - Configure transport (UnityTransport)
  - Create PlayerSpawnPoint objects (Transform markers)
  - Create player prefab with NetworkObject + NetworkBehaviour
  - Register player prefab in NetworkManager
```

## Common Architecture

```
NetworkManager (DontDestroyOnLoad)
├── UnityTransport
├── Player Prefab (NetworkObject)
│   ├── PlayerNetworkController (NetworkBehaviour)
│   ├── PlayerInput (local only)
│   └── PlayerVisuals
└── SpawnManager
    └── SpawnPoints[]
```

---

## Critical Rules

1. **Server is authoritative** — never trust client data
2. **Minimize RPCs** — batch state changes, use NetworkVariables for continuous state
3. **Check ownership** — `if (!IsOwner) return;` in input handling
4. **Prefab registration** — all network prefabs must be registered with NetworkManager
5. **Don't sync transforms directly** — use NetworkTransform or custom NetworkVariable
6. **Handle disconnection** — clean up on `OnNetworkDespawn`
7. **Never let clients modify other clients' state**
8. **Never send large data in RPCs** — serialize efficiently
9. **Never read `Input.*` in NetworkBehaviour** — use InputView pattern

---

## What NOT To Do

- Never let clients directly modify other clients' state
- Never send large data in RPCs (serialize efficiently)
- Never use `Update` without ownership check on network objects
- Never forget to register network prefabs

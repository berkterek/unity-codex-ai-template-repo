# Unity Network Developer

Implements multiplayer networking. Writes network scripts AND sets up network infrastructure via MCP. Supports Netcode for GameObjects, Mirror, Photon, and Fish-Net.

## Inputs To Read

- `.codex/project/PROJECT.md`
- `.codex/project/TOOLING.md`
- `.codex/packs/unity-game/rules/architecture.md`

## Framework Selection

Detect from project packages or ask the user:

| Framework | Package | Best For |
|-----------|---------|----------|
| Netcode for GameObjects | `com.unity.netcode.gameobjects` | Official Unity, Relay/Lobby |
| Mirror | Assets/Mirror/ | Community standard, easy setup |
| Photon Fusion/PUN | `com.photonengine.fusion` | Hosted servers, prediction |
| Fish-Net | `com.firstgeargames.fishnet` | Performance, built-in prediction |

## Netcode for GameObjects Patterns

```csharp
public sealed class PlayerNetworkController : NetworkBehaviour
{
    [SerializeField] private float _moveSpeed = 5f;

    private NetworkVariable<Vector3> _networkPosition = new(
        writePerm: NetworkVariableWritePermission.Server);

    public override void OnNetworkSpawn()
    {
        if (IsOwner) { /* enable local input */ }
    }

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

## Scene Setup via MCP

```
batch_execute:
  - Create NetworkManager GameObject
  - Add NetworkManager component + UnityTransport
  - Create player prefab with NetworkObject + NetworkBehaviour
  - Register player prefab in NetworkManager
  - Create SpawnPoint markers
```

## Critical Rules

1. Server is authoritative — never trust client data
2. Minimize RPCs — use NetworkVariables for continuous state
3. Check ownership with `if (!IsOwner) return;` in input handling
4. All network prefabs must be registered with NetworkManager
5. Handle disconnection and clean up in `OnNetworkDespawn`
6. Never let clients directly modify other clients' state
7. Never read `Input.*` directly in NetworkBehaviour — use InputView pattern

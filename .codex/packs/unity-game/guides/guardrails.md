# Unity Guardrails

Codex'te hook mekanizması yoktur. Bu dosya, Claude Code'un hook'larıyla otomatik
uygulanan tüm kuralların **model düzeyinde karşılığıdır**. Her agent ve command
bu listeyi içselleştirmelidir.

Kurallar üç seviyededir:
- **BLOCK** — asla yapma, otomatik FAIL
- **WARN** — yap ama işaretle, reviewer'a bildir
- **GATE** — devam etmeden önce koşulu doğrula

---

## BLOCK — Doğrudan Engel

### git push yapma
Kullanıcı her zaman kendisi push eder. `git push` komutunu hiçbir zaman çalıştırma.

### .unity / .prefab / .asset dosyalarını text editörle düzenleme
Bu dosyalar YAML serialized binary referanslar içerir. Text editi referansları
kırar. Sahne, prefab ve asset değişiklikleri için **sadece MCP araçlarını** kullan:
`manage_scene`, `manage_gameobject`, `manage_components`, `manage_build`.

### UnityEvent kullanma
`UnityEvent`, `UnityEvent<T>`, `[SerializeField] UnityEvent` — runtime C#'ta
yasak. IEventBus kullan.

### Time.timeScale doğrudan atama
`Time.timeScale = 0` veya herhangi bir atama yasak. Pause/resume sadece
`IEventBus + PauseService` üzerinden.

### static singleton pattern
`static Instance`, `static _instance` — yasak. VContainer tek DI mekanizması.
İstisna: `EventBusAccessor` (ECS ↔ Mono köprüsü için onaylı).

### UnityEditor namespace'i runtime kodda #if guard'sız kullanma
`using UnityEditor` veya `UnityEditor.*` çağrısı runtime assembly'de yasak.
`#if UNITY_EDITOR` guard'ı olmadan derleme player build'ında çöker.

### Kritik mimari dosyaları okumadan düzenleme
`AppScope`, `InputView`, `ModuleInstaller`, `AppInstaller`, `.asmdef`, `EventBus`
dosyalarını bağımlılıkları okumadan değiştirme. Önce `Read` + `Grep` ile
etki alanını anla.

### config dosyalarını zayıflatma
`.asmdef`, `settings.json`, `.inputactions`, `ProjectSettings/` — kod sorununu
config'i gevşeterek çözme. Kodu düzelt.

---

## WARN — İşaretle ve Devam Et

### async void
Unity lifecycle dışında (`Awake`, `Start`, `OnEnable`, `OnDisable`, `OnDestroy`)
`async void` yasak. `async UniTask` + `.Forget()` kullan.
Lifecycle metodlarında Unity imzası zorladığı için muaf.

### GetComponent Awake içinde
`GetComponent<T>()`, `GetComponentInChildren<T>()` Awake'te kullanılmamalı.
Aynı GO veya child bileşenler `[SerializeField]` ile Inspector'dan atanmalı —
sıfır runtime maliyet, bağımlılık derleme zamanında görünür.

### Input System ihlalleri
- Legacy API yasak: `Input.GetKey`, `Input.GetAxis`, `Input.GetButton`, `Input.mousePosition`
- `InputAction` enable/disable Awake/OnEnable içinde yapılmalı, OnDisable'da temizlenmeli
- Her `+=` için eşleşen `-=` olmalı
- `FixedUpdate` içinde input okuma yasak, `Update` kullan
- Sistemler input'tan bağımsız olmalı: `SetMoveInput(Vector2)`, `Jump()` gibi methodlar

### Namespace formatı
`Layer.Module` formatı zorunlu: `Framework.Events`, `Game.Abstracts`,
`Game.Concretes`, `Game.Ecs`. Tek segment namespace uyarı.

### Naming convention ihlalleri
- Types, methods, properties: `PascalCase`
- Private fields: `_camelCase`
- Parameters, locals: `camelCase`
- Interface: `I` prefix
- IEvent struct: `Event` suffix (örn. `LevelStartedEvent`)

### Hot path expensive calls
`Update`, `FixedUpdate`, `LateUpdate`, `Tick`, `FixedTick`, `LateTick` içinde:
- `GetComponent`, `Camera.main`, `FindObjectOfType`, `FindObjectsOfType`
- `tag == "..."` (CompareTag kullan)
- `SendMessage`, `BroadcastMessage`
- `transform` property (cache et)

### LINQ hot path içinde
`Update` / `FixedUpdate` / `LateUpdate` içinde LINQ kullanma (allocation üretir).

### Runtime Instantiate
`GameObject.Instantiate` runtime'da yasak. Object pool kullan.

### Null propagation Unity object'lerinde
`?.` ve `??` operatörlerini `MonoBehaviour`, `Component`, `ScriptableObject`
üzerinde kullanma. Unity `== null`'ı destroyed object tespiti için override eder;
C# referans eşitliği destroyed objeye method çağırır — en yaygın Unity bug.

### Pure C# servislerde UnityEngine import
`_Framework/`, `Game/Abstracts/`, `Game/Concretes/` klasörlerinde (provider'lar
hariç) `using UnityEngine` yasak.

### ECS structural changes query loop içinde
`EntityManager.AddComponent`, `RemoveComponent`, `DestroyEntity`, `Instantiate`
query döngüsü içinde yasak. `EntityCommandBuffer` kullan.

### ECS enum byte base eksik
ECS component veya `IEvent` struct içindeki enum'lar `byte` base tipine sahip
olmalı: `enum State : byte`.

### UniTask CancellationToken eksik
`async UniTask` metodları `CancellationToken` parametresi almalı. Muaflar:
override metodlar, Unity lifecycle wrapper'ları, 5 satırdan kısa private helper'lar.

### Kullanılmayan kod
Kullanılmayan private member, kullanılmayan `using`, kullanılmayan parametre —
uyar ve reviewer'a bildir.

### Dosya adı / class adı uyumsuzluğu
C# dosya adı birincil class/struct adıyla eşleşmeli. Unity MonoBehaviour ve
ScriptableObject için bu zorunlu; diğer tipler için de aynı kuralı uygula.

### SerializeField rename — FormerlySerializedAs eksik
`[SerializeField]` alan yeniden adlandırılıyorsa `[FormerlySerializedAs("eskiAd")]`
eklenmeli. Eksikse sahne/prefab'daki tüm atanmış değerler sessizce sıfırlanır.

### Test dosyası eksik
Logic C# dosyasının karşılığı `Tests/` altında yoksa uyar.

### PlayMode test sahnesi eksik
PlayMode test dosyası bir sahneye referans veriyorsa, o sahne
`_Scenes/TestScenes/` altında bulunmalı.

---

## GATE — Devam Etmeden Önce Doğrula

### Director Gate
Pipeline agent'ları (coder, tester, committer) spawn edilmeden önce Director Gate
gösterilmiş ve kullanıcı `go` yazmış olmalı. Gate geçilmeden pipeline başlamaz.

### Reviewer sırası
Bu projede reviewer **Claude** (`unity-reviewer`). Kodun review edilmesi için
`unity-reviewer` agent'ını çağır. Commit öncesi review zorunlu.

### Gate cleared durumu
`.codex/project/PROGRESS.md` veya task notları incelenerek mevcut pipeline
aşamasının tamamlanıp tamamlanmadığını doğrula.

---

## Doğrulama Checklist (Her C# Yazımı Sonrası)

- [ ] Unity console kontrol edildi (MCP: `read_console` errors)
- [ ] Compilation hatası yok (`refresh_unity` + `read_console`)
- [ ] SerializeField rename varsa `FormerlySerializedAs` eklendi
- [ ] Runtime/editor sınırı korundu
- [ ] Input boundary korundu (input varsa)
- [ ] Singleton veya static state yok
- [ ] Hot path'lerde allocation yok
- [ ] Test dosyası var veya NoTest kararı verildi

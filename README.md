# Unity Codex AI Template

Unity projeleri için hazır Codex CLI şablonu. `.codex/` klasörünü herhangi bir Unity projesine kopyalayarak Codex destekli AI iş akışlarına, kod kalite kurallarına ve slash command'larına anında erişin.

---

## İçindekiler

- [Bu Nedir](#bu-nedir)
- [Hızlı Başlangıç](#hızlı-başlangıç)
- [Zorunlu Stack](#zorunlu-stack)
- [Klasör Yapısı](#klasör-yapısı)
- [Guardrails — Hook Karşılığı Kurallar](#guardrails--hook-karşılığı-kurallar)
- [Reviewer — Claude](#reviewer--claude)
- [Agent Listesi](#agent-listesi)
- [Command Listesi](#command-listesi)
- [Kurallar ve Kılavuzlar](#kurallar-ve-kılavuzlar)
- [Yeni Proje Kurulumu](#yeni-proje-kurulumu)
- [Mimari Özet](#mimari-özet)

---

## Bu Nedir

Codex CLI, proje kökündeki `AGENTS.md` ve `.codex/` klasörünü okur. Bu şablon bu klasörü önceden yapılandırılmış olarak sunar:

- **Guardrails** — Hook karşılığı kurallar; BLOCK (git push, .unity text edit, UnityEvent, static singleton), WARN (async void, hot-path alloc, LINQ, null propagation), GATE (Director Gate, reviewer zorunluluğu)
- **Agent'lar** — Uzmanlaşmış AI rolleri: `unity-coder`, `unity-fixer`, `unity-reviewer` (Claude tabanlı), `unity-tester`, `unity-setup` ve 25+ daha fazlası
- **Command'lar** — Slash command'ları ile ortak iş akışları: `/implement`, `/fix`, `/review-code`, `/architect`, `/new-module`, `/smart-commit` ve 48+ daha fazlası
- **Kurallar** — Mimari, isimlendirme, test, ECS, serialization ve Addressables standartları
- **Skill'ler** — 62 skill dosyası: audio, URP, Cinemachine, VContainer, UniTask, DOTween ve daha fazlası

---

## Hızlı Başlangıç

### 1. Projeye kopyala

```
your-unity-project/
├── AGENTS.md          ← Codex'in okuduğu root konfigürasyon
└── .codex/
    ├── project/       ← Her projede doldur
    ├── packs/
    │   └── unity-game/
    │       ├── agents/
    │       ├── commands/
    │       ├── rules/
    │       ├── guides/
    │       └── skills/
    ├── core/
    └── templates/
```

### 2. Proje overlay dosyalarını doldur

```
/setup-project
```

veya manuel:

```
.codex/project/PROJECT.md            ← Proje adı, tip, platform, enabled pack'ler
.codex/project/STRUCTURE.md          ← Klasör yapısı, modüller, ownership
.codex/project/TOOLING.md            ← Build, test, lint komutları
.codex/project/CODING_CONVENTIONS.md
.codex/project/RULES.md
```

### 3. Geliştirmeye başla

```
/implement <özellik açıklaması>
/fix <bug açıklaması>
/architect
```

---

## Zorunlu Stack

Unity projesinde bu paketler kurulu olmalı:

| Paket | Kaynak | Amaç |
|-------|--------|-------|
| **VContainer** | OpenUPM | DI — tüm singleton'ların yerini alır |
| **UniTask** | OpenUPM | Async/await — tüm coroutine'lerin yerini alır |
| **New Input System** | Package Manager (`com.unity.inputsystem`) | Input — legacy API tamamen yasak |

### Opsiyonel

| Paket | Feature Flag | Açıklama |
|-------|-------------|----------|
| Addressables | `addressables` | `Resources.Load` yasak, async yükleme zorunlu |
| NSubstitute | `testing` | EditMode/PlayMode test altyapısı |
| Unity ECS DOTS | `ecs` | ECS klasör, asmdef ve kural seti |

---

## Klasör Yapısı

```
.codex/
├── core/
│   ├── agents/          coder, tester, reviewer, committer
│   ├── commands/        orchestrate, continue, dry-run, status, stop, validate
│   └── protocols/       checkpoint, event-journal, mailbox, progress
├── packs/
│   └── unity-game/
│       ├── agents/      29 Unity specialist agent
│       ├── commands/    48 Unity slash command
│       ├── rules/       10 kural dosyası
│       ├── guides/      7 kılavuz (guardrails dahil)
│       └── skills/      62 skill dosyası
├── project/             Projeye özgü overlay — her projede doldur
├── templates/           GDD, TDD, CODING_CONVENTIONS şablonları
└── manifests/           Import ve dönüşüm kararları
```

---

## Guardrails — Hook Karşılığı Kurallar

Codex'te Claude Code'un hook mekanizması yoktur. `.codex/packs/unity-game/guides/guardrails.md` bu boşluğu doldurur. Tüm agent ve command'lar bu dosyayı başlarken okur.

### BLOCK — Asla Yapma

| Kural | Neden |
|-------|-------|
| `git push` çalıştırma | Kullanıcı her zaman kendisi push eder |
| `.unity` / `.prefab` / `.asset` text edit | Serialized referansları kırar |
| `UnityEvent` kullanma | `IEventBus` kullan |
| `Time.timeScale` doğrudan atama | `IEventBus + PauseService` kullan |
| Static singleton (`static Instance`) | VContainer tek DI mekanizması |
| `UnityEditor` namespace `#if UNITY_EDITOR` guard'sız | Player build'ı çöker |
| Config dosyalarını zayıflatma | Kodu düzelt, config'i değil |

### WARN — İşaretle ve Devam Et

`async void`, `GetComponent` in Awake, legacy Input API, hot-path LINQ/allocation, `?.`/`??` Unity objelerinde, namespace format ihlali, naming convention ihlali, SerializeField rename without FormerlySerializedAs, test dosyası eksik.

### GATE — Koşul Doğrula

Director Gate geçilmeden pipeline başlamaz. Commit öncesi `unity-reviewer` zorunlu.

---

## Reviewer — Claude

Bu şablonda kod review'ı **Claude** (`unity-reviewer` agent) tarafından yapılır.

Review kapsamı:
- Unity derleme doğrulaması (MCP: `refresh_unity` + `read_console`)
- Runtime doğrulaması (MCP: Play mode açma/kapama, console error kontrolü)
- Mimari, UI compliance, performans, rendering/GPU, C# kalitesi, encapsulation
- Input System compliance (legacy API yasak, Enable/Disable eşleştirmesi)
- Kullanılmayan kod tespiti (private member, public member, using, parametre)
- PASS / FAIL verdict — Critical ve Major issue'lar FAIL'e yol açar

---

## Agent Listesi

### Core (`.codex/core/agents/`)

`coder` · `tester` · `reviewer` · `committer`

### Unity Specialist (`.codex/packs/unity-game/agents/`)

| Agent | Görev |
|-------|-------|
| `unity-coder` | MonoBehaviour, provider, installer, scene wiring |
| `unity-coder-lite` | Küçük C# değişiklikleri |
| `unity-fixer` | Bug — root cause + regression test + fix |
| `unity-fixer-lite` | Hızlı tek dosya fix |
| `unity-reviewer` | **Claude tabanlı tam reviewer** |
| `unity-tester` | EditMode / PlayMode test yazımı |
| `unity-test-runner` | Test çalıştırma ve raporlama |
| `unity-test-builder` | PlayMode test sahnesi oluşturma |
| `unity-developer` | Tam döngü: coder + tester + reviewer |
| `unity-setup` | Sahne, prefab, asset, Unity ayar kurulumu |
| `unity-scene-builder` | Sahne hiyerarşisi oluşturma |
| `unity-ui-builder` | UI Toolkit / UGUI panel ve view |
| `unity-shader-dev` | Shader Graph ve HLSL |
| `unity-network-dev` | Ağ katmanı |
| `unity-optimizer` | Performans profiling ve optimizasyon |
| `unity-linter` | Kod kalitesi ve kural uyumu |
| `unity-critic` | Mimari ve tasarım eleştirisi |
| `unity-verifier` | 3 iterasyonlu doğrulama döngüsü |
| `unity-scout` | Kod tabanı keşfi |
| `unity-prototyper` | Hızlı prototip |
| `unity-migrator` | Unity versiyon ve render pipeline migrasyonu |
| `unity-git-master` | Git operasyonları |
| `unity-build-runner` | Build pipeline |
| `unity-security-reviewer` | Güvenlik taraması |
| `debugger` | Debug süreci |
| `migrator` | Coroutine→UniTask, Singleton→VContainer pattern migrasyonu |
| `silent-failure-hunter` | Sessiz hata tespiti |
| `audio-clip-agent` | AudioClip import ayarları toplu uygulama |
| `graphics-setup-agent` | URP / grafik ayarları kurulumu |
| `package-analyzer` | Package bağımlılık analizi |

---

## Command Listesi

### Core

`/orchestrate` · `/continue` · `/dry-run` · `/status` · `/stop` · `/validate`

### Unity — Planlama

`/architect` · `/create-plan` · `/update-plan` · `/plan-workflow` · `/game-idea` · `/refine-gdd` · `/refine-tdd` · `/adr`

### Unity — İmplementasyon

`/implement` · `/add-feature` · `/new-module` · `/fix` · `/fix-deep` · `/scene-setup` · `/create-prefab-scene` · `/unity-scene-update` · `/update-scene-hierarchy` · `/setup-project`

### Unity — Test

`/generate-tests` · `/create-test` · `/qa` · `/debug-session`

### Unity — Review ve Kalite

`/review-code` · `/clean-slop` · `/performance-audit` · `/check-portability` · `/silent-failure-hunt`

### Unity — Git

`/smart-commit` · `/create-changelog`

### Unity — Yardımcı

`/catch-up` · `/learn` · `/discover` · `/search` · `/context-prime` · `/checkpoint` · `/migrate` · `/migrator` · `/graphics-setup` · `/audio-clip-setup` · `/instincts` · `/dump` · `/caveman` · `/five` · `/grill-me` · `/ralph` · `/mermaid`

---

## Kurallar ve Kılavuzlar

### Kurallar (`.codex/packs/unity-game/rules/`)

| Dosya | Kapsam |
|-------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputView, AppScope |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw call, UI canvas |
| `testing.md` | EditMode/PlayMode/ECS/NoTest karar ağacı, NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform define, lifecycle sırası |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent yasak, IEventBus vs Action vs C# event |
| `scene-hierarchy.md` | 6 zorunlu root container, prefab domain, logic/visual ayrımı |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | Resources.Load yasak, async yükleme, handle lifecycle |

### Kılavuzlar (`.codex/packs/unity-game/guides/`)

| Dosya | Kapsam |
|-------|--------|
| `guardrails.md` | **Hook karşılığı BLOCK/WARN/GATE kuralları** |
| `director-gates.md` | Pipeline gate'leri ve geçiş koşulları |
| `unity-mcp.md` | MCP araç kullanım rehberi |
| `input-system.md` | New Input System implementasyon rehberi |
| `serialization-safety.md` | Serialization güvenli değişim rehberi |
| `nsubstitute.md` | NSubstitute kullanım rehberi |
| `vcontainer.md` | VContainer DI rehberi |

---

## Yeni Proje Kurulumu

```bash
# 1. Bu repoyu klonla veya .codex/ ve AGENTS.md dosyalarını kopyala
git clone <this-repo> your-unity-project
cd your-unity-project

# 2. Codex ile aç ve kurulum komutunu çalıştır
/setup-project

# 3. Geliştirmeye başla
/implement <özellik açıklaması>
```

---

## Mimari Özet

```
Unity Scene
    └── LifetimeScope (VContainer)
            ├── AppScope          — uygulama geneli bağımlılıklar
            ├── ModuleInstaller   — modül kayıtları
            └── Providers         — Unity API köprüleri
                    │
                    ↓
            Pure C# Services      — IEventBus, business logic
                    │
                    ↓
            InputView             — New Input System → servis methodları
```

- **Singleton yok** — VContainer `Lifetime.Singleton`
- **Coroutine yok** — `async UniTask`
- **Legacy Input yok** — New Input System, InputView pattern
- **UnityEngine servis katmanında yok** — Provider pattern

---

## Lisans

MIT

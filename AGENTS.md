# Unity Codex AI Template

Bu repo, Unity projelerinde Codex CLI ile çalışmak için hazır bir şablon.
Tüm agent'lar, command'lar, kurallar ve kılavuzlar `.codex/` altında organize edilmiştir.

---

## Yapı

```
.codex/
├── core/          — Platform-agnostik agent ve command'lar
├── packs/
│   └── unity-game/   — Unity'e özgü agent, command, rule, guide, skill
├── project/       — Projeye özel overlay dosyaları (her projede doldur)
├── manifests/     — Import kararları ve dönüşüm notları
└── templates/     — Başlangıç şablonları
```

---

## Zorunlu Okumalar (Her Konuşma Başında)

Her agent ve command başlamadan önce şunları okur:

1. `AGENTS.md` — bu dosya
2. `.codex/packs/unity-game/guides/guardrails.md` — hook karşılığı tüm kurallar
3. `.codex/project/PROJECT.md` — proje kimliği ve kısıtları
4. `.codex/project/RULES.md` — proje hard rules

---

## Guardrails (Hook Karşılığı)

Codex'te hook mekanizması yoktur. `.codex/packs/unity-game/guides/guardrails.md`
bu boşluğu doldurur. **Tüm agent ve command'lar bu dosyayı içselleştirmelidir.**

Üç seviye:

| Seviye | Örnekler |
|--------|---------|
| **BLOCK** | `git push`, `.unity`/`.prefab` text edit, `UnityEvent`, `Time.timeScale`, static singleton, `UnityEditor` guard'sız |
| **WARN** | `async void`, `GetComponent` in Awake, legacy Input API, hot-path LINQ/alloc, null propagation Unity obj'ler üzerinde |
| **GATE** | Director Gate geçilmeden pipeline başlamaz; commit öncesi `unity-reviewer` zorunlu |

---

## Reviewer

Bu projede reviewer **Claude** (`unity-reviewer` agent).

- Tam checklist: derleme doğrulama (MCP), runtime doğrulama (Play mode), mimari, performans, encapsulation, input system, kullanılmayan kod tespiti
- Commit öncesi review **zorunlu**
- `unity-reviewer` agent: `.codex/packs/unity-game/agents/unity-reviewer.md`

---

## Agent Dizini

### Core Agents (`.codex/core/agents/`)

| Agent | Görev |
|-------|-------|
| `coder.md` | Genel implementasyon |
| `tester.md` | Test yazımı |
| `reviewer.md` | Genel review → Unity projeler için `unity-reviewer` kullan |
| `committer.md` | Commit ve versiyon işlemleri |

### Unity Specialist Agents (`.codex/packs/unity-game/agents/`)

| Agent | Görev |
|-------|-------|
| `unity-coder.md` | MonoBehaviour, provider, installer, scene wiring implementasyonu |
| `unity-coder-lite.md` | Küçük C# değişiklikleri, kural uyumu yüksek |
| `unity-fixer.md` | Bug düzeltme — root cause analizi + regression test |
| `unity-fixer-lite.md` | Hızlı tek dosya fix'leri |
| `unity-reviewer.md` | **Claude tabanlı tam reviewer** — compile + runtime doğrulama |
| `unity-tester.md` | EditMode / PlayMode test yazımı |
| `unity-test-runner.md` | Test çalıştırma ve sonuç raporlama |
| `unity-test-builder.md` | PlayMode test sahnesi oluşturma |
| `unity-developer.md` | Tam döngü geliştirici — coder + tester + reviewer |
| `unity-setup.md` | Sahne, prefab, asset, Unity ayar kurulumu |
| `unity-scene-builder.md` | Sahne hiyerarşisi oluşturma ve yapılandırma |
| `unity-ui-builder.md` | UI Toolkit / UGUI panel ve view oluşturma |
| `unity-shader-dev.md` | Shader Graph ve HLSL shader geliştirme |
| `unity-network-dev.md` | Ağ katmanı implementasyonu |
| `unity-optimizer.md` | Performans profiling ve optimizasyon |
| `unity-linter.md` | Kod kalitesi ve kural uyumu denetimi |
| `unity-critic.md` | Mimari ve tasarım eleştirisi |
| `unity-verifier.md` | 3 iterasyonlu doğrulama ve fix döngüsü |
| `unity-scout.md` | Kod tabanı keşfi ve analizi |
| `unity-prototyper.md` | Hızlı prototip implementasyonu |
| `unity-migrator.md` | Unity versiyon ve render pipeline migrasyonu |
| `unity-git-master.md` | Git operasyonları ve branch yönetimi |
| `unity-build-runner.md` | Build pipeline yönetimi |
| `unity-security-reviewer.md` | Güvenlik açığı taraması |
| `debugger.md` | Genel debug süreci |
| `migrator.md` | Kod pattern migrasyonu (Coroutine → UniTask, Singleton → VContainer) |
| `silent-failure-hunter.md` | Sessiz hata tespiti |
| `audio-clip-agent.md` | AudioClip import ayarları toplu uygulama |
| `graphics-setup-agent.md` | URP / grafik ayarları kurulumu |
| `package-analyzer.md` | Package bağımlılık analizi |

---

## Command Dizini

### Core Commands (`.codex/core/commands/`)

| Command | Görev |
|---------|-------|
| `/orchestrate` | Tam workflow pipeline çalıştırma |
| `/continue` | Kesilmiş pipeline'ı devam ettirme |
| `/dry-run` | Pipeline simülasyonu — dosya değiştirmez |
| `/status` | Mevcut workflow durumu |
| `/stop` | Pipeline durdurma |
| `/validate` | Tamamlanan işi doğrulama |

### Unity Commands (`.codex/packs/unity-game/commands/`)

#### Planlama ve Mimari
| Command | Görev |
|---------|-------|
| `/architect` | Mimari tasarım ve karar verme |
| `/create-plan` | Görev planı oluşturma |
| `/update-plan` | Mevcut planı güncelleme |
| `/plan-workflow` | Workflow tasarımı |
| `/game-idea` | Oyun fikri geliştirme |
| `/refine-gdd` | GDD iyileştirme |
| `/refine-tdd` | TDD iyileştirme |
| `/adr` | Architecture Decision Record yazma |

#### İmplementasyon
| Command | Görev |
|---------|-------|
| `/implement` | TDD pipeline ile feature implementasyonu |
| `/add-feature` | Mevcut sisteme feature ekleme |
| `/new-module` | Yeni modül iskelet oluşturma |
| `/fix` | Bug düzeltme pipeline'ı |
| `/fix-deep` | Derin root-cause analizi ile bug düzeltme |
| `/scene-setup` | Sahne kurulumu |
| `/create-prefab-scene` | Prefab ve sahne oluşturma |
| `/unity-scene-update` | Sahne güncelleme |
| `/update-scene-hierarchy` | Sahne hiyerarşi güncellemesi |
| `/setup-project` | Proje ilk kurulum |

#### Test
| Command | Görev |
|---------|-------|
| `/generate-tests` | Test dosyaları oluşturma |
| `/create-test` | Tek test oluşturma |
| `/qa` | QA doğrulama süreci |
| `/debug-session` | Interaktif debug oturumu |

#### Review ve Kalite
| Command | Görev |
|---------|-------|
| `/review-code` | Kod review (Claude reviewer) |
| `/clean-slop` | Gereksiz/düşük kaliteli kod temizleme |
| `/performance-audit` | Performans denetimi |
| `/check-portability` | Platform taşınabilirlik kontrolü |
| `/silent-failure-hunt` | Sessiz hata taraması |
| `/security-review` | Güvenlik denetimi |

#### Git ve Versiyon
| Command | Görev |
|---------|-------|
| `/smart-commit` | Akıllı commit mesajı ve staging |
| `/create-changelog` | Changelog oluşturma |
| `/adr` | Mimari karar kaydı |

#### Yardımcı
| Command | Görev |
|---------|-------|
| `/catch-up` | Kod tabanını öğren ve özetle |
| `/learn` | Belirli bir pattern veya sistemi öğren |
| `/discover` | Kod tabanını keşfet |
| `/search` | Kod içinde arama |
| `/context-prime` | Bağlam oluşturma |
| `/checkpoint` | Durum kaydetme |
| `/migrate` | Kod migrasyonu |
| `/migrator` | Pattern migrasyonu pipeline'ı |
| `/graphics-setup` | Grafik ayarları kurulumu |
| `/audio-clip-setup` | AudioClip import ayarları |
| `/instincts` | Proje içgüdüleri / öğrenilen patterns |
| `/dump` | Bağlam dump'ı |
| `/caveman` | Sade açıklama modü |
| `/five` | 5 dakikalık hızlı özet |
| `/grill-me` | Kod tabanı hakkında sorgu |
| `/ralph` | Retrospektif analiz |
| `/mermaid` | Mermaid diyagramı oluşturma |

---

## Kurallar (`.codex/packs/unity-game/rules/`)

| Dosya | Kapsam |
|-------|--------|
| `architecture.md` | VContainer DI, IEventBus, Provider, InputView, AppScope |
| `csharp-unity.md` | Naming, namespace, null check, UniTask, encapsulation |
| `performance.md` | Zero-alloc hot path, caching, pooling, draw call, UI canvas |
| `testing.md` | Test tipi kararı (EditMode/PlayMode/ECS/NoTest), NSubstitute, AAA |
| `unity-specifics.md` | Editor guard, platform define, lifecycle sırası |
| `serialization.md` | FormerlySerializedAs, Unity null, SerializeReference |
| `event-patterns.md` | UnityEvent yasak, IEventBus vs Action vs C# event karar ağacı |
| `scene-hierarchy.md` | 6 zorunlu root container, prefab domain, logic/visual ayrımı |
| `ecs-dots.md` | Authoring/Baker, ISystem+IJobEntity, ECB, Hybrid linking |
| `addressables.md` | Resources.Load yasak, async yükleme, handle lifecycle |

---

## Kılavuzlar (`.codex/packs/unity-game/guides/`)

| Dosya | Kapsam |
|-------|--------|
| `guardrails.md` | **Hook karşılığı tüm kurallar — BLOCK / WARN / GATE** |
| `director-gates.md` | Pipeline gate'leri ve geçiş koşulları |
| `unity-mcp.md` | MCP araç kullanım rehberi |
| `input-system.md` | New Input System implementasyon rehberi |
| `serialization-safety.md` | Serialization güvenli değişim rehberi |
| `nsubstitute.md` | NSubstitute kullanım rehberi |
| `vcontainer.md` | VContainer DI rehberi |

---

## Gerekli Stack

| Paket | Kaynak | Amaç |
|-------|--------|-------|
| **VContainer** | OpenUPM | DI — singleton yasak |
| **UniTask** | OpenUPM | Async/await — coroutine yasak |
| **New Input System** | Package Manager | Input — legacy API yasak |

## Opsiyonel Özellikler

| Paket | Feature Flag | Devre dışıysa |
|-------|-------------|----------------|
| Addressables | `addressables` | Addressables kuralları atlanır |
| NSubstitute | `testing` | Test hook'ları ve asmdef atlanır |
| Unity ECS DOTS | `ecs` | ECS klasör ve kuralları atlanır |

---

## Yeni Proje Kurulumu

```
/setup-project
```

veya manuel:

1. `.codex/project/PROJECT.md` doldur
2. `.codex/project/STRUCTURE.md` doldur
3. `.codex/project/TOOLING.md` doldur
4. `.codex/project/CODING_CONVENTIONS.md` doldur
5. `.codex/project/RULES.md` doldur
6. `/implement` ile geliştirmeye başla

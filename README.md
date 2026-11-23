# X08 Hub — Public Production Distribution

<div align="center">
  <img src="assets/x08-logo.png" alt="X08 Hub Logo" width="160" />
  <h3>Universal & Game-Specific Script Suite for Roblox</h3>
  <p>Production distribution repository for <strong>X08 Hub</strong>, optimized for high-speed multi-CDN delivery via jsDelivr, Raw GitHub, and Statically.</p>
</div>

---

## ⚡ How to Run in Roblox Executors

Copy any of the following loadstrings into your Roblox executor (Delta Mobile, Codex, Arceus X, Fluxus, Hydrogen, Synapse Z, Xeno, Wave):

### Option 1: Fast CDN (jsDelivr — High-Speed Edge Delivery)
```lua
loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/Xnoname008/X08-HUB@main/loader.lua"))()
```

### Option 2: Official GitHub Raw (Instant 0s Updates)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Xnoname008/X08-HUB/main/loader.lua"))()
```

### Option 3: Statically Edge CDN
```lua
loadstring(game:HttpGet("https://cdn.statically.io/gh/Xnoname008/X08-HUB/main/loader.lua"))()
```

---

## 🌟 Key Features
- **Instant Clean Startup:** Zero-stall initialization without screen-blocking splash animations (<0.05s startup).
- **Game-Exclusive Mode:** Allocates 100% execution resources to the active game (saves up to ~70% RAM on mobile).
- **Universal Exploit Suite (On-Demand):** Silent Aim, 2D/3D ESP, Tracers, Fly, Speed, Noclip, Click TP, Anti-AFK, Auto Clicker.
- **Airflow UI Framework:** Elegant dark-plum UI powered by 1,715+ official Lucide icons with 60 FPS mobile optimization.
- **Automated Multi-Language Localization:** Automatic OS/client locale detection supporting 12 languages (English, Indonesian, Spanish, Portuguese, Russian, Japanese, Korean, etc.).
- **Multi-CDN Checksum Invalidation:** Automated Adler-32 checksums ensure updates invalidate cached scripts in the background without freezing.

---

<!-- AUTO_GAMES_START -->

## 🎮 Supported Experiences (44 Games)

| No | Game Title | Place ID | Status |
|:---|:---|:---|:---|
| 1 | **+1 Venom Evolution** | `116448925875915` | 🟢 Active |
| 2 | **⚠️ ANOMALI MENDEKAT!** | `70575351571626` | 🟢 Active |
| 3 | **1 Speed Evolve** | `83569851223739` | 🟢 Active |
| 4 | **Anime Card Collection** | `76285745979410` | 🟢 Active |
| 5 | **Arsenal** | `286090429` | 🟢 Active |
| 6 | **Auto Equip Bait** | `98502499119821` | 🟢 Active |
| 7 | **Auto Farm** | `120219252362013` | 🟢 Active |
| 8 | **BedWars** | `6872265039` | 🟢 Active |
| 9 | **Blox Fruits** | `2753915549` | 🟢 Active |
| 10 | **Cast a Magnet** | `103265940798818` | 🟢 Active |
| 11 | **Deep Fishing** | `132239307080610` | 🟢 Active |
| 12 | **Defusal** | `79393329652220` | 🟢 Active |
| 13 | **Demonology** | `18199615050` | 🟢 Active |
| 14 | **Desert Detectors** | `73010525850196` | 🟢 Active |
| 15 | **Driving Empire** | `3351674303` | 🟢 Active |
| 16 | **Dueling Grounds** | `94217045453265` | 🟢 Active |
| 17 | **Eat Ice Cream** | `74316683163991` | 🟢 Active |
| 18 | **Farm a Fish** | `91296119701853` | 🟢 Active |
| 19 | **Fatal Baboons** | `93660722909304` | 🟢 Active |
| 20 | **Hook Status** | `138363592957250` | 🟢 Active |
| 21 | **Huss Valley** | `107535308163741` | 🟢 Active |
| 22 | **Illegal Soccer** | `126987974021910` | 🟡 Maintenance |
| 23 | **Lost Currents** | `106324368467440` | 🟢 Active |
| 24 | **Minesweeper Solver** | `7871169780` | 🟢 Active |
| 25 | **Movement** | `18687417158` | 🟢 Active |
| 26 | **Murder Mystery 2** | `142823291` | 🟢 Active |
| 27 | **Net a Fish** | `93898234979111` | 🟢 Active |
| 28 | **NGOBROL** | `120454553075568` | 🟢 Active |
| 29 | **Notice** | `90568084448279` | 🟢 Active |
| 30 | **Notoriety** | `21532277` | 🟢 Active |
| 31 | **Ragdoll Physics** | `121868512253414` | 🟢 Active |
| 32 | **Revolver Arena** | `108419873026523` | 🟢 Active |
| 33 | **RIVALS** | `17625359962` | 🟢 Active |
| 34 | **Run A Farm** | `79496881832552` | 🟢 Active |
| 35 | **Save the Krusty Krab** | `129332901430212` | 🟢 Active |
| 36 | **Sell a Million Sushi** | `125866884667103` | 🟢 Active |
| 37 | **Sell Lemons** | `79268393072444` | 🟢 Active |
| 38 | **Sniper Arena** | `122446657157717` | 🟢 Active |
| 39 | **Survive Ideas** | `77900175935766` | 🟢 Active |
| 40 | **Tower Slap** | `72250771850707` | 🟢 Active |
| 41 | **Violence District** | `93978595733734` | 🟢 Active |
| 42 | **Volleyball** | `73956553001240` | 🟢 Active |
| 43 | **Volleyball Main** | `94450914651792` | 🟡 Maintenance |
| 44 | **Warnetopia** | `106267220422944` | 🟢 Active |

<!-- AUTO_GAMES_END -->

---

<!-- AUTO_CHANGELOG_START -->

## 📝 Latest Changelog & Updates

### v2.6.5 — Minimalist Console Logs & Streamlined Text Interface (2026-11-22)
- Console (F9): Format ringkas 2 baris tanpa emoji.
- Prefix: Standarisasi log [X08 Hub] & [X08 Universal].
- Performa: Optimasi kecepatan emisi log & hemat memori.
- UI & Updates: Teks update dan notifikasi lebih singkat & jelas.
- Dual-Repo: Otomatisasi push ke X08-HUB-DECODE & X08-HUB.

### v2.6.4 — Airflow UI Notification Anti-Spam & Zero-Lag Engine (2026-11-22)
- Anti-Spam Deduplication: Identical notifications (Title + Content) within 2.0s are completely suppressed, preventing toast floods from repetitive events.
- Global Cadence & Rate Limiter: Enforced 0.35s minimum interval between notification popups with a smooth burst queue (max 2 slots) and overflow dropping to prevent GPU stalls.
- Screen Toast Cap: Enforced MaxNotifications = 3 on Airflow window configuration to eliminate CanvasGroup and shadow rendering bottlenecks.
- Hitlog Throttling: Added per-victim 0.3s cooldown on Hit Registered notifications in PlayerManager to prevent automatic weapon spray from lagging the UI.

### v2.6.3 — Coin Claim Merging, Tab Deduplication, and Universal Freeze/Lag Elimination (2026-11-21)
- NGOBROL Coin Claim Fix: Character now merges directly into the coin hitbox (continuous Stepped noclip & CanCollide disabled on coin and all limbs) eliminating physics bounce-off onto coin surface; triggers multi-part TouchInterest, ProximityPrompt, and ClickDetector.
- Tab Deduplication Guard: Enforced singleton tab verification in universal-main.lua and loader-ori.lua to completely prevent duplicate Universal Utilities tabs or dual downloads in Settings.
- Deprecation Warning Elimination: Silenced TextChatMessage.Text deprecation warnings in Developer Console by delegating chat monitoring cleanly to player.Chatted.
- Universal Suite Performance: Eliminated framedrops and freezes by throttling WallWalk raycasts (30 FPS), caching RaycastParams across PlayerManager, and introducing sliced non-blocking traversal in WorldManager (FreezeNPCs, FPSBoost restore, Radar).

### v2.6.2 — Comprehensive Security Hardening & Zero-RCE Architecture (2026-11-21)
- Supply Chain Defense: Eliminated remote dynamic loadstring execution; converted analytics to zero-execution safe HTTP POST.
- Third-Party Isolation: Removed untrusted external UI fallbacks; enforced 100% internal multi-CDN mirrors.
- Cryptographic Salt Encapsulation: Removed X08_SERVER_SALT from global scopes (_G and getgenv()); encapsulated in private SecurityCore closure.
- Anti-Tamper Cache Engine: Protected _G.X08_CacheEngine with table freezing and immutable X08_Protected proxy metatable.

### v2.6.1 — Framedrop Elimination, High-Throughput Startup & Engine Optimization (2026-11-21)
- Startup Speed Acceleration: Added 0.00ms in-memory cache hit, tuned initial crypto budget to 25ms, and reduced sync timeout to 0.15s.
- Framedrop Fixes: Throttled ESP and unthrottled loops in Universal Suite, MM2, BedWars, Blox Fruits, and Arsenal.
- Character Stability: Fixed upright standing physics & anti-ragdoll motor joints in NGOBROL (120454553075568).
- Bug Fix: Fixed duplicate tab download bug when clicking Universal Utilities in Settings.

### v2.6.0 — Standalone Multi-CDN Release & Airflow UI Framework (2026-11-20)
- Multi-CDN Distribution: Distributed across jsDelivr, GitHub Raw, and Statically with instant background invalidation.
- Airflow UI: Integrated dark-plum UI framework with 1,715 official Lucide icons & 60 FPS mobile optimization.
- Localization Engine: Added automatic language detection supporting 12 languages.
- Zero-Stall Manifest: Introduced Adler-32 fastChecksum verification manifest.

<!-- AUTO_CHANGELOG_END -->

---

## 🛡️ Executor Compatibility
🟢 Delta Mobile, Codex, Arceus X, Fluxus, Hydrogen, Xeno, Wave, Synapse Z (100% Compatible).

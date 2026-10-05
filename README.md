# OVERLORD ☢️

```
   ██████╗ ██╗   ██╗███████╗██████╗ ██╗      ██████╗ ██████╗ ██████╗ 
  ██╔═══██╗██║   ██║██╔════╝██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗
  ██║   ██║██║   ██║█████╗  ██████╔╝██║     ██║   ██║██████╔╝██║  ██║
  ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗██║     ██║   ██║██╔══██╗██║  ██║
  ╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████╗╚██████╔╝██║  ██║██████╔╝
   ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ 
        [ VAULT BUNKER 42 // TACTICAL COMMAND & EXPEDITION OS ]
```

[![Release: v0.1.0-alpha](https://img.shields.io/badge/Release-v0.1.0--alpha-red.svg)](https://github.com/0xCoderunknown/overlord-game/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline%20%7C%20No%20Trackers-brightgreen)](#-privacy--offline-pledge)
[![F-Droid](https://img.shields.io/badge/F--Droid-Ready-blue?logo=f-droid)](metadata/io.github.coder_unknown.overlord.yml)
[![Field Manual](https://img.shields.io/badge/Manual-GAMEPLAY.md-orange)](GAMEPLAY.md)

> ⚠️ **EARLY ALPHA NOTICE (v0.1.0):**  
> This game is an early-stage, experimental concept prototype. Balance, mechanics, and features are in active development.

**Overlord** is a post-apocalyptic expedition and scavenger management RPG rendered through an atmospheric, green-phosphor CRT retro-terminal. 

As the **Overseer of Vault Bunker 42**, you monitor expedition telemetry feeds, manage dweller stress and equipment, synthesize medical supplies, and issue tactical directives to survive the irradiated wasteland surface.

---

## 🎮 THE GAMEPLAY EXPERIENCE

### 🖥️ The Retro-Terminal Interface
The interface simulates an authentic late-20th-century bunker mainframe with monospaced typography, live incident tickers, visual glitch effects, and CRT-styled panel containers.

### 🧭 Autonomous Wasteland Expeditions
Dispatch dwellers into the irradiated ruins. The simulation engine runs minute-by-minute with a Master RNG Table resolving:
* **Over 30 Multi-Line Lore Sequences**: Environmental narratives and classic homage callbacks (*Fallout, Metro 2033, S.T.A.L.K.E.R., Dark Souls, Resident Evil*).
* **Survival Encounters**: Rad-storms, abandoned campsites, and contaminated puddles.
* **Wandering NPCs**: Caravan doctors offering field triage, neutral patrols, con artists, and muggers.

### ⚔️ Tactical Combat & Emergency Auto-Triage
* 2-round combat exchanges calculated against enemy damage profiles and dweller armor Damage Reduction (DR).
* **Pre-Combat Tactics**: Stealth ghosting, lethal player ambushes (150% damage), or dangerous enemy surprise attacks.
* **Auto-Medkit Protocol**: When dweller vitals plummet below 50% HP, combat stimulants automatically deploy to prevent flatlining.

### 🧠 The Sanity & Hallucination Engine
The wasteland erodes sanity. Dwellers accumulate stress during expeditions. Recruits may carry secret afflictions:
* **PTSD**: Screen burns crimson during trauma spikes.
* **Paranoia**: Dwellers violently refuse chemical injections at high stress levels.
* **Psychosis**: Text labels and live logs corrupt into scrambled zalgo/cyber-glyph runes.
* **The Gaslight Reset**: Returning to the command center immediately wipes the visual hallucination, leaving you to wonder if the glitch was real.

### 🛠️ Vault Engineering: The Medical Bay
Restore the ruined Medical Bay (`10,000 Caps`) to synthesize **Wasteland Medkits** using scavenged battlefield components:
$$\text{1x Used Syringe} + \text{2x Irradiated Herbs} + \text{1x Expired Chemicals} \xrightarrow{\text{4 Hours}} \text{2x Wasteland Medkits}$$

### 🎒 Auto-Equip & Armory Stash
* **Strict 10-Slot Backpacks**: Dwellers know when to quit; when weight reaches 10, they automatically head home.
* **Tactical Auto-Equip**: Finding higher-tier or higher-damage gear in the field automatically equips it, cycling older gear into the backpack.
* **50-Slot Armory**: Store weapons, armor, food, and craft materials, or liquidate stacks for Caps on the Requisition Market.

> 📖 **Looking for exact drop rates, combat math, enemy stat sheets, and complete weapon tables?**  
> Check out the complete [**Overseer Field Manual (GAMEPLAY.md)**](GAMEPLAY.md).

---

## 🕹️ COMMAND CENTER LAYOUT

```
                    ┌───────────────────────────────────┐
                    │     COMMAND CENTER (OVERSEER)     │
                    │   Treasury Caps  //  Armory Count │
                    └─────────────────┬─────────────────┘
                                      │
        ┌───────────────────┬─────────┴─────────┬───────────────────┐
        │                   │                   │                   │
┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│    [ROOMS]     │  │    [ROSTER]    │  │    [STASH]     │  │ [ACCESS MARKET]│
│  Medical Bay   │  │ Dwellers Roster│  │ 50-Slot Armory │  │ Requisition    │
│ Craft Medkits  │  │ Hire Recruits  │  │ Buy / Sell     │  │ Weapons/Armor  │
└────────────────┘  └───────┬────────┘  └────────────────┘  └────────────────┘
                            │
                    ┌───────▼────────┐
                    │ [DWELLER FEED] │
                    │ Live Terminal  │
                    │ Vitals & Gear  │
                    │ Deploy / Recall│
                    └────────────────┘
```

---

## 🔒 PRIVACY & OFFLINE PLEDGE

* **100% Offline**: Requires zero network connections. No `INTERNET` permission declared in release builds.
* **Zero Trackers & Zero Ads**: No Google Analytics, Firebase, Facebook SDK, or advertising trackers.
* **Zero Account Requirements**: No email sign-in or remote servers. Save states are stored exclusively on your device via local storage.
* **Built-in System Fonts**: Completely free of remote font downloads to prevent network leaks and comply with strict F-Droid packaging standards.
* **Open Source**: Licensed under the permissive [MIT License](LICENSE).

---

## 🛠️ BUILDING FROM SOURCE

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.4` or later)
* Android SDK (Target API 34+)
* Java Development Kit (JDK 17)

### 1. Clone & Dependencies
```bash
git clone https://github.com/0xCoderunknown/overlord-game.git
cd overlord-game

flutter pub get
```

### 2. Verify Code & Test Suite
```bash
# Static analysis (zero warnings)
flutter analyze

# Unit and widget test suite
flutter test
```

### 3. Run on Device / Emulator
```bash
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The compiled binary will be placed at:  
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📁 CODEBASE TOPOLOGY

```
lib/
├── content/                     # Static game databases
│   ├── character_database.dart  # Recruit templates (Jonny, Shina, Drifter, Robot)
│   ├── enemy_database.dart      # Enemies (Pests, Wastelanders, Lethal Encounters)
│   ├── incident_database.dart   # Narrative logs, combat texts, and event strings
│   ├── item_database.dart       # Weapons, armor, consumables, and crafting components
│   ├── lore_database.dart       # 30+ Environmental story events and easter eggs
│   └── poi_database.dart        # Points of interest (Kindergarten to AMI Base)
├── engine/                      # Core game logic
│   ├── exploration_engine.dart  # Master simulation loop & tick distribution
│   ├── game_manager.dart        # State management, SharedPreferences, lifecycle
│   ├── incident_handler.dart    # Combat resolution, tactical ambush, POI logic
│   └── loot_engine.dart         # Dynamic drop tables and backpack auto-equip
├── models/
│   └── game_models.dart         # Scavenger, Item, VaultFacility, ScavState
├── screens/                     # UI screens & terminal decks
│   ├── dweller_screen.dart      # Real-time scavenger telemetry, gear, and sanity glitch
│   ├── facility_screen.dart     # Medical bay chemical synthesizer
│   ├── market_screen.dart       # Bunker requisition storefront
│   ├── overseer_screen.dart     # Main command center dashboard
│   ├── roster_screen.dart       # Dweller management & contractor board
│   └── stash_screen.dart        # 50-slot vault armory & liquidation exchange
├── utils/
│   ├── app_theme.dart           # CRT terminal color palettes & retro typography
│   ├── engine_helpers.dart      # Safe RNG, time math, and corruption glitcher
│   └── game_config.dart         # Global constants (ticks, costs, limits)
└── widgets/                     # Reusable terminal UI components
```

---

## 🤝 CONTRIBUTING TO THE WASTELAND

Want to contribute a new weapon, dangerous mutant, wasteland lore, or bunker room?
Read our [**Contributing Guidelines**](CONTRIBUTING.md) and [**Code of Conduct**](CODE_OF_CONDUCT.md).

Content PRs are welcome:
* **New Items**: [`lib/content/item_database.dart`](lib/content/item_database.dart)
* **New Enemies**: [`lib/content/enemy_database.dart`](lib/content/enemy_database.dart)
* **Wasteland Lore**: [`lib/content/lore_database.dart`](lib/content/lore_database.dart)
* **Points of Interest**: [`lib/content/poi_database.dart`](lib/content/poi_database.dart)

---

## 📄 LICENSE

Copyright © 2026 0xCoderunknown.  
This project is open-source software licensed under the [MIT License](LICENSE).

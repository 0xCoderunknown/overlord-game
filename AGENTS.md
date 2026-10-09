# OVERLORD // Autonomous Agent Guidelines (`AGENTS.md`)

> **Document Version:** 1.0.0  
> **Target Audience:** AI Coding Agents & LLM Contributors  
> **App:** Overlord (Vault Bunker 42 Command Simulation)  
> **Tech Stack:** Flutter 3.x (Android API 34+) / Dart 3.13+ / Provider / SharedPreferences  

---

## 1. Project Manifesto & Core Directives

Overlord is a post-apocalyptic expedition and scavenger management RPG rendered through an atmospheric, green-phosphor CRT retro-terminal interface. All autonomous agents modifying or expanding this codebase **must strictly honor these directives**:

1. **100% Offline & Privacy Pledge**:
   - Never introduce remote network dependencies (`http`, `dio`, analytics SDKs, crashlytics, remote telemetry, or ad networks).
   - Never use Google Fonts runtime network downloads. Monospace typography uses the built-in system font family (`'monospace'`).
   - Never declare internet permissions in Android build configurations.
2. **Authentic CRT Retro Aesthetic**:
   - Never use generic Material 3 colors (Material Purple, Blue, etc.).
   - Always use theme tokens from [`AppTheme`](lib/utils/app_theme.dart) (`AppTheme.terminalGreen`, `AppTheme.alertRed`, `AppTheme.warningYellow`, `AppTheme.retroText()`, etc.).
   - Wrap UI panels in [`TerminalContainer`](lib/widgets/terminal_container.dart) and use [`TerminalButton`](lib/widgets/terminal_button.dart).
3. **Non-Negotiable Quality Gates**:
   - Every code modification **must** pass `flutter analyze` with **0 errors and 0 warnings**.
   - Every code modification **must** pass `flutter test` with **100% test pass rate**.

---

## 2. Immutable Gameplay Rules & Invariants

| Invariant | Constant / Location | Rule |
|---|---|---|
| **Backpack Capacity** | `GameConfig.maxBackpackWeight = 10` | Non-cap items count toward weight. `loot_caps` is weightless. Dwellers auto-return when weight $\ge 10$. |
| **Vault Stash Limit** | `GameConfig.maxStashSize = 50` | Maximum 50 unique/stacked slots in Armory. Excess loot prevents return until cleared. |
| **Return Travel Time** | `minutesExplored ~/ 2` | Calculated upon manual recall or automatic overcumbered return. |
| **Idle HP Recovery** | `+1 HP / minute` | Resting dwellers in `ScavState.idle` recover 1 HP per simulated minute up to `maxHp`. |
| **Emergency Auto-Medkit**| `hp <= (maxHp * 0.50)` | If dweller has `c_medkit` in backpack and vitals drop to $\le 50\%$ HP, 1 medkit is auto-consumed to restore 50% max HP. |
| **Medical Bay Crafting** | `GameConfig.medbayUnlockCost = 10000`, `medbayCraftingTime = 240` | Requires 10,000 Caps to unlock. Synthesis takes 240 minutes (4 hours) requiring `1x med_syringe`, `2x med_herb`, `1x chem_expired` to yield `2x c_medkit`. |
| **Offline Catch-Up Cap** | `GameConfig.maxOfflineMinutes = 4320` | Maximum 3 days (4,320 minutes) simulated on app resume. |
| **Revive Penalty** | `GameConfig.minReviveCost = 20` | Reviving a fallen dweller costs 10% of their carried caps (min 20 caps). Resets state to `returning` with 25% max HP. |

---

## 3. Architecture & Codebase Topology

```
lib/
├── content/                     # Static Game Data (Items, Enemies, Lore, POIs, Characters)
├── engine/                      # Core Mechanics (ExplorationEngine, IncidentHandler, LootEngine, GameManager)
├── models/                      # Domain Models (Item, Scavenger, VaultFacility, ScavState)
├── screens/                     # Full-Page Screens (Overseer, Dweller, Market, Roster, Stash, Facility)
├── utils/                       # Helpers (AppTheme, EngineHelpers, GameConfig)
└── widgets/                     # Reusable Terminal Components
```

### State Management Guidelines
- Root state is centralized in [`GameManager`](lib/engine/game_manager.dart) (`ChangeNotifier`).
- The simulation loop runs on a 60-second periodic timer triggering `processTicks(1)`.
- UI listens via `context.watch<GameManager>()` or `context.read<GameManager>()`.
- Always call `saveGame()` when mutating persistent game state.

### File Granularity & Modularization
- **Strict Limit:** Keep individual files under **400 lines of code**.
- If a screen grows beyond 400 lines, extract sheets, headers, and dialogs into dedicated widgets in `lib/widgets/`.

---

## 4. Testing & Deterministic RNG Guidelines

To test pure simulation and combat math deterministically, use the seedable RNG API in [`EngineHelpers`](lib/utils/engine_helpers.dart):

```dart
// In Unit Tests:
EngineHelpers.setRng(Random(42)); // Fixed seed for reproducible rolls

// Reset after tests:
EngineHelpers.resetRng(); // Restores true system Random()
```

### Test Directory Topology
```
test/
├── unit/
│   ├── models/
│   │   ├── item_test.dart
│   │   └── scavenger_test.dart
│   ├── engine/
│   │   ├── exploration_engine_test.dart
│   │   ├── incident_handler_test.dart
│   │   ├── loot_engine_test.dart
│   │   └── game_manager_test.dart
│   └── utils/
│       └── engine_helpers_test.dart
└── widget/
    └── widget_test.dart
```

---

## 5. Pre-Commit Verification Workflow

Before completing any task, execute:
```bash
# 1. Format code
flutter format .

# 2. Verify static analysis (MUST have 0 issues)
flutter analyze

# 3. Run all unit and widget tests (MUST have 100% passing tests)
flutter test
```

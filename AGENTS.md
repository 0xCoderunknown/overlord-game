# OVERLORD // Autonomous Agent Constitution & Guardrails (`AGENTS.md`)

> **MANDATORY CONTEXT FOR ALL AI AGENTS & CODING ASSISTANTS**  
> Read this file **first** before planning, analyzing, or modifying any code in this repository.  
> The human user is the **Strict Product Manager (PM) / Vault Overseer**. You are the **Senior Clinical & Game Systems Architect**.  
> **App:** Overlord (Vault Bunker 42 OS)  
> **Tech Stack:** Flutter 3.x / Dart 3.13+ / Provider / SharedPreferences (100% Offline)

---

## 🏛️ 1. Project Manifesto & Core Directives

Overlord is a post-apocalyptic expedition and scavenger management RPG rendered through an atmospheric, green-phosphor CRT retro-terminal. All autonomous agents modifying or expanding this codebase **must strictly honor these directives**:

1. **100% Offline & Privacy Pledge:**
   - **Never** introduce remote network dependencies (`http`, `dio`, analytics SDKs, crashlytics, remote telemetry, or ad networks).
   - **Never** use Google Fonts runtime network downloads. Monospace typography uses the built-in system font family (`'monospace'`).
   - **Never** declare internet permissions in Android build configurations.
2. **Authentic CRT Retro Aesthetic:**
   - **Never** use generic Material 3 colors (Material Purple, Blue, pastel pinks, etc.).
   - Always use theme tokens from [`AppTheme`](lib/utils/app_theme.dart) (`AppTheme.terminalGreen`, `AppTheme.alertRed`, `AppTheme.warningYellow`, `AppTheme.retroText()`, etc.).
   - Wrap UI panels in [`TerminalContainer`](lib/widgets/terminal_container.dart) and use [`TerminalButton`](lib/widgets/terminal_button.dart).
3. **Mandatory Indian Date Format (`DD-MM-YYYY`):**
   - **All dates displayed in UI, terminal logs, changelogs (`CHANGELOG.md`), and markdown documentation MUST strictly use Indian numerical date formatting (`DD-MM-YYYY` or `DD-MM-YY`).**
   - Never use `YYYY-MM-DD` or `MM/DD/YYYY` in human-facing text or documentation.

---

## ⚖️ 2. Immutable Gameplay Rules & Invariants

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

## 🏗️ 3. Architecture & Codebase Topology

```
lib/
├── content/                     # Static Game Data (Items, Enemies, Lore, POIs, Characters)
├── engine/                      # Core Mechanics (ExplorationEngine, IncidentHandler, LootEngine, GameManager)
├── models/                      # Domain Models (Item, Scavenger, VaultFacility, ScavState)
├── screens/                     # Full-Page Screens (Overseer, Dweller, Market, Roster, Stash, Facility)
├── utils/                       # Helpers (AppTheme, EngineHelpers, GameConfig)
└── widgets/                     # Reusable Terminal Components
test/
├── unit/                        # Engine, combat, model, and RNG unit tests
└── widget/                      # Screen and widget tests
docs/
└── MASTER_BACKLOG.md            # True product roadmap & anti-goals
```

### State Management & Code Granularity
- Root state is centralized in [`GameManager`](lib/engine/game_manager.dart) (`ChangeNotifier`).
- The simulation loop runs on a 60-second periodic timer triggering `processTicks(1)`.
- **Strict Line Limit:** Keep every presentation and screen file strictly under **400 lines of code**. Extract sheets, dialogs, and cards into `lib/widgets/`.

---

## 📋 4. Strict PM Interaction Protocol (How You Must Operate)

You are being managed by a strict Product Manager. Follow this exact workflow:

### Step 1: Clarify & Plan First (Never jump straight to mass edits)
- When given a feature request, provide:
  1. **User Flow & Acceptance Criteria**
  2. **Affected Files & Architecture Touchpoints**
  3. **Data Impact** (Are any save state schemas or constants changing? Provide exact diffs).
- Wait for PM approval before executing multi-file changes.

### Step 2: Respect Existing Conventions
- Use pure engine math with seedable RNG (`EngineHelpers.setRng(Random(seed))`) in `test/`.
- Maintain CRT retro aesthetic with green terminal tokens. Never introduce modern UI frameworks or Material 3 defaults.

### Step 3: Verification Gate
- After making changes, always run the automated gate:
  ```bash
  dart run tool/verify_invariants.dart
  ```
- Must pass with 100% clean formatting, <400 line limits, zero network packages, zero analyze issues, and 100% test pass rate.

---

## 🛑 5. Codebase Red Lines (Instant Failure Conditions)

- ❌ **Violating the 100% Offline Pledge** (Adding `http`, `dio`, analytics, Firebase, ad networks, or network permissions).
- ❌ **Using non-terminal / generic Material colors** instead of CRT phosphor tokens (`AppTheme`).
- ❌ **Adding presentation files exceeding 400 lines.**
- ❌ **Breaking core gameplay invariants** (10kg backpack cap, 50-slot stash cap, 2-round combat, emergency auto-medkit).
- ❌ **Using non-Indian date formats (`YYYY-MM-DD` or `MM/DD/YYYY`) in changelogs or markdown documentation.** (Must use `DD-MM-YYYY`).
- ❌ **Failing static analysis or breaking automated tests.**

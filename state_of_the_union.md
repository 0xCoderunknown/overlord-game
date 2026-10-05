# Project State Audit: State of the Union

## 1. Core Engine (GameManager & IncidentHandler)

### `processTicks` Logic (d100 Master RNG Table)
The core exploration loop evaluates each active scavenger minute-by-minute with a d100 roll:
*   **0-74 (75%)**: Lore / Atmosphere. Adds passive flavor text to the logs.
*   **75-89 (15%)**: Minor / Safe Encounter. Passive events that yield small amounts of caps or flavor text.
*   **90-96 (7%)**: Real Combat Encounter. Triggers combat with a Category 1 or 2 enemy from the database.
*   **97-99 (3%)**: High-Risk Event. Pauses the scavenger (State: `waitingForInput`) requiring the Overseer's manual intervention via the UI. If triggered, forces a Category 3 lethal enemy encounter.

### Combat Loop & Auto-Medkit Logic
The combat engine enforces a strict **2-round loop**:
1.  **Scavenger Attacks**: Damage rolled based on `equippedWeapon` bounds (minStat to maxStat). If enemy HP reaches 0, the scavenger wins.
2.  **Enemy Retaliates**: Random damage rolled minus the scavenger's `equippedArmor` block value. Damage taken is clamped at 0.
*   **Auto-Medkit Mechanism**: If the scavenger survives the round but their HP drops to 25 or below (and > 0), and they have at least 1 Medkit, an auto-inject triggers restoring 50% of `maxHp` (clamped to max). HP is strictly clamped to never drop below 0. 

### Loot Drop Economy
When an enemy is defeated, loot is rolled on a d100 Master Drop Table. If a scavenger survives a combat encounter but doesn't kill the enemy (partial survival), they suffer a penalty drop of just 1 Scrap Metal.
*   **0-59 (60%)**: Scrap Metal (x1-3 stackable).
*   **60-89 (30%)**: Medkit (x1 stackable).
*   **90-97 (8%)**: Raw Caps (5-19).
*   **98-99 (2%)**: Gear Drop Jackpot! Grants either a random Weapon or Armor (Tiers 1 & 2 only, Relics excluded).

---

## 2. Data Models (`game_models.dart`)

### `Scavenger` Class Properties
*   `String id`
*   `String name`
*   `int hp`
*   `int maxHp`
*   `int medkits`
*   `ScavState state`
*   `List<Item> backpack` (Capacity limit checked in engine logic)
*   `Item? equippedWeapon`
*   `Item? equippedArmor`
*   `int minutesExplored`
*   `int minutesToReturn`
*   `List<String> logs`
*   `List<String> loreQueue`

### `Item` Class Properties
*   `String id`
*   `String name`
*   `int value`
*   `bool isStackable`
*   `int quantity`
*   `String type` ('weapon', 'armor', 'scrap', 'misc')
*   `int tier` (1-3)
*   `int? minStat`
*   `int? maxStat`
*   `String? description`
*   `String? imagePath`

### `ScavState` Enums
*   `idle, exploring, returning, waitingForInput, dead`

---

## 3. Content Databases

*   **`ItemDatabase`**: Contains 12 items total.
    *   **Weapons**: 6 items broken down into Tier 1 (Desperate Measures), Tier 2 (Gunsmith), and Tier 3 (Pre-War Relics).
    *   **Armor**: 6 items broken down similarly into Tiers 1 to 3. 
*   **`IncidentDatabase` (Enemies)**: Contains 6 enemies total.
    *   **Category 1 (The Pests)**: Mutated Rat, Feral Hound.
    *   **Category 2 (The Wastelanders)**: Desperate Scrapper, Raider Enforcer.
    *   **Category 3 (Lethal Encounters)**: Security Drone, Featherless Turkey.
*   **`LoreDatabase`**: Contains `passiveLore`, an array of 6 distinct multi-line environmental story sequences.

---

## 4. UI Integration (Screens)

*   **`OverseerScreen`**: Acts as the command center dashboard. Lists active deployments and global summary stats. 
    *   **Engine Hooks**: Reads `caps` and `globalStash.length`. Includes a FAB that calls `processTicks(60)` for dev fast-forwarding time. Routes to Roster, Market, and Dweller screens.
*   **`DwellerScreen`**: The detailed live-view for an individual scavenger. Contains a vitals header, live terminal feed, and an action deck.
    *   **Engine Hooks**: Calls `sendToWasteland()` to deploy, `recallScavenger()` to abort exploration, and triggers `saveGame()` when updating equipment via the bottom sheet modal. Opens `EventModal` for resolving `waitingForInput` states.
*   **`MarketScreen`**: A purely visual storefront displaying the `ItemDatabase` listings for Weapons and Armor, segmented by Tier colors.
*   **`RosterScreen`**: Displays the full roster of all dwellers regardless of active state. 
    *   **Engine Hooks**: Calls dev macros `devResetRoster()` and `devSendAllToWasteland()`. Routes to `DwellerScreen`.

---

## 5. Missing Links & Stubs

*   **Infinite / Unused Engine Variables**: 
    *   `globalStash`: Currently an infinite `List<Item>` array appending everything non-scrap upon Scavenger return. It has no capacity limit and there is presently no UI/Screen mapped to view or extract its contents (only the raw count is displayed in `OverseerScreen`).
    *   `caps`: Although caps are generated via passive encounters and scrap auto-selling, there is **zero functional purchase logic wired up yet**. The `MarketScreen` exists but has no buy buttons or state mutation attached.
*   **Hardcoded / Placeholder Data**: 
    *   `freeGun` ('w_pipe_pistol') and `freeArmor` ('a_motorcycle') are hardcoded to the initial save state configuration in the `GameManager` constructor. 
    *   `devResetRoster()` hardcodes specific characters ("Jonny", "Shina", "Robot") with arbitrary starting stats (e.g., 150 HP for Robot) without referencing a baseline character database.

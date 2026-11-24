# Changelog

All notable changes to the Overlord project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), adhering to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Dates strictly follow the Indian numerical date standard (`DD-MM-YYYY`).

---

## [0.1.1] — 25-11-2026 — Architecture & Single Source of Truth Hardening

### Added
- **Item Visual Tokens Single Source of Truth**: Centralized `AppTheme.getItemTierColor(tier)` and `AppTheme.getItemTypeIcon(type)` across all inventory, stash, inspect, and market screens.
- **Dedicated Equipment Card Component**: Extracted `DwellerEquippedCard` (`lib/widgets/dweller_equipped_card.dart`), preemptively reducing `DwellerInventorySheet` from 398 to 271 lines.
- **Deterministic Seedable RNG Accessor**: Added `EngineHelpers.rng` getter, unifying recruit ID generation (`CharacterDatabase`) and item UUID generation (`Item.fromDatabase`) under controllable seedable RNG.
- **Expanded Automated Tests**: Added unit and widget tests for `DwellerEquippedCard`, `AppTheme` visual tokens, and `EngineHelpers.rng` (expanding test suite from 57 to 62 tests).

### Changed
- **Modularized Presentation Layer**: Decomposed `DwellerInventorySheet` to safely sit below the 300-line warning threshold (271 lines), eliminating invariant violation risks.
- **Unified Backpack Weight Invariant**: Replaced ad-hoc backpack weight filters with `scavenger.currentWeight` and `GameConfig.maxBackpackWeight`.

### Removed
- **Redundant Security Policy (`.github/SECURITY.md`)**: Removed unnecessary vulnerability disclosure file for a 100% offline, local client-side game.
- **Duplicate Visual Helpers**: Pruned redundant `_getItemColor` and `_getIconForType` methods duplicated across `DwellerInventorySheet`, `DwellerItemInspectDialog`, `ItemGridCard`, `StashScreen`, and `MarketScreen`.
- **Unused Math Import**: Pruned `dart:math` from `CharacterDatabase`.

---

## [0.1.0] — 21-11-2026 — Vault Bunker 42 OS Baseline Release

### Added
- **Core Wasteland Simulation**: Minute-by-minute simulation loop with passive lore, random survival acts, NPC encounters, and barricaded POI exploration.
- **Tactical Combat Loop**: 2-round reciprocal turn exchange with automatic emergency medkit triage when vitals drop $\le 50\%$ HP.
- **Vault Armory & Economy**: 50-slot Vault Armory stash, Requisition Market trading, and weightless Bottle Caps currency.
- **Medical Bay Synthesis**: Unlockable crafting facility (10,000 Caps) synthesizing emergency medkits (`2x c_medkit`) over 240 simulated minutes.
- **100% Offline & Tracker-Free Architecture**: Zero remote network SDKs, zero telemetry, local asset bundling, and clean production Android manifest.
- **AI Governance & Constitution (`AGENTS.md`)**: Comprehensive ClinicOS-grade operating constitution, strict PM protocol, and zero-legacy policy.
- **Automated Invariant Verification Gate (`tool/verify_invariants.dart`)**: Single-command verification covering Dart formatting, <400 presentation line limits, offline pledge checks, static analysis (0 warnings), and unit/widget test suite.
- **Comprehensive Automated Test Suite**: 57 unit and widget tests covering models, simulation engines, combat math, facilities, offline catch-up, and screens.
- **Deterministic RNG Testing**: Seedable pseudo-random generator API (`EngineHelpers.setRng()` / `EngineHelpers.resetRng()`) for reproducible simulation and combat tests.
- **Save State Versioning**: Robust local save system with `schemaVersion: 1` header in `overseer_save_data`.
- **First-Party `material_ui` Integration**: Integrated `package:material_ui` (v1.11.1) adhering to modern Flutter framework modularization.
- **Modern Android Build Pipeline**: Upgraded to Gradle 9.5.0, Android Gradle Plugin 9.3.1, and Built-in Kotlin (`android.builtInKotlin=true`).
- **Master Roadmap Backlog (`docs/MASTER_BACKLOG.md`)**: Centralized specification for Radio Beacon dweller recruitment, Armory sorting, and Hydroponics Greenhouse.

### Changed
- **Modernized Material Imports**: Migrated all presentation and widget test files from deprecated `package:flutter/material.dart` to `package:material_ui/material_ui.dart`.
- **Modularized Screen Architecture**: Decomposed monolithic screens into focused sub-400-line components (`DwellerVitalsCard`, `DwellerInventorySheet`, `DwellerItemInspectDialog`).
- **Target Platform Baseline**: Target modern Flutter 3.50+ / Dart 3.14+ / Android API 26+ environment with deterministic Java 24 toolchain isolation.
- **FOSS Documentation Topology**: Streamlined community guidelines and documentation into `.github/` and root routing table.
- **Strict Lint Profile**: Activated `unreachable_from_main`, `avoid_unused_constructor_parameters`, `cancel_subscriptions`, `close_sinks`, `unnecessary_late`, and `use_build_context_synchronously` in `analysis_options.yaml`.

### Removed
- **Dead Model Fields**: Pruned orphaned `medkits` counter from `Scavenger` model and character database (auto-medkit logic consumes physical `c_medkit` items from backpack).
- **Abandoned Palette Tokens**: Removed 6 unused color declarations (`red400`, `green900`, `grey800`, `grey700`, `grey600`, `lightBlueAccent`) from `AppTheme`.
- **Obsolete Android Qualifiers**: Deleted legacy Android 5.0 `drawable-v21` resource directory and unified `launch_background.xml` under base `drawable/`.
- **Legacy Kotlin Gradle Plugin**: Removed `id("kotlin-android")` in favor of AGP Built-in Kotlin.

### Fixed
- **Timer Lifecycle Leak**: Patched unmanaged timers in `IncidentHandler.handleCombatEncounter` and `GameManager.startGameLoop` with `_isDisposed` lifecycle guards.
- **Missing POI Fallback**: Added in-universe terminal CRT wireframe and radar scan animation when location art is unavailable.

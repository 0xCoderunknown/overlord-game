# Changelog

All notable changes to the Overlord project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-09

### Added
- **AI-Readiness Architecture**: Introduced `AGENTS.md` specifying immutable gameplay invariants, CRT design tokens, offline pledge, and development rules for autonomous AI maintenance.
- **Comprehensive Automated Test Suite**: Added 57 unit and widget tests across models, engines, utilities, and screens (combat DR, weight limits, facilities, offline catch-up, and serialization).
- **Deterministic Simulation**: Added `EngineHelpers.setRng()` and `EngineHelpers.resetRng()` for reproducible rolls in unit tests.
- **Save State Schema Versioning**: Added `schemaVersion: 1` header in `overseer_save_data` to ensure safe, backwards-compatible data migrations.
- **CRT Radar Fallback**: Added in-universe terminal wireframe/radar fallback for missing POI images in `EventModal`.
- **Lifecycle & Timer Teardown**: Added `GameManager.stopGameLoop()` and `_isDisposed` guards for clean background timer teardown.

### Changed
- **Modularized Dweller Screen**: Decomposed the 1,113-line monolithic `DwellerScreen` into bite-sized reusable components:
  - `DwellerVitalsCard` (vitals header, portrait, segmented HP bar, and sanity glitches)
  - `DwellerItemInspectDialog` (item inspection, consumption, equip, and stash transfers)
  - `DwellerInventorySheet` (equipment and 50-slot armory management sheet)
  - Reduced `DwellerScreen` from 1,113 lines down to 235 lines (< 400 line agent invariant).
- **Documentation Alignment**: Synchronized `state_of_the_union.md` with active game systems.

### Fixed
- Fixed unmanaged `Future.delayed` timer in `IncidentHandler.handleCombatEncounter` with `manager.isDisposed` lifecycle guards.

## [0.1.0] - 2026-10-09

### Added
- Initial open-source release of Vault Bunker 42 OS.
- Wasteland exploration loop with minute-by-minute incident simulation.
- 2-round tactical combat with auto-medkit emergency triage.
- 50-slot Vault Armory stash and Requisition Market.
- Medical Bay chemical synthesis system.
- 100% offline and tracker-free privacy architecture.

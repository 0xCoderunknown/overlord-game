# Changelog

All notable changes to the Overlord project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), adhering to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Dates strictly follow the Indian numerical date standard (`DD-MM-YYYY`).

---

## [0.2.1] — 29-10-2026 — AI Governance Constitution, Invariant Gate & Roadmap Backlog

### Added
- **Automated Invariant Verification Gate (`tool/verify_invariants.dart`):** Single-command verification checking repository Dart formatting, <400 line limits, 100% offline pledge (no network SDKs or internet permissions), `flutter analyze` (0 warnings), and full unit/widget test suite pass rate.
- **AI Maintainer Constitution (`AGENTS.md`):** Updated with ClinicOS-grade operating constitution, Strict PM Interaction Protocol (Clarify & Plan First -> Respect Conventions -> Verification Gate), and explicit Codebase Red Lines.
- **Master Roadmap Backlog (`docs/MASTER_BACKLOG.md`):** Single source of truth for unbuilt features (Radio Beacon Dweller Recruitment, 50-slot Armory quick-sort, procedural retro synthesizer SFX, Hydroponics Greenhouse, and explicit Anti-Goals).

---

## [0.2.0] — 09-10-2026 — Modular Architecture & Test Suite Expansion

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
- **Documentation & FOSS Alignment**: Streamlined repository documentation topology, relocated community files (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`) to `.github/`, clarified tactical simulation RPG tagline, and synchronized `GAMEPLAY.md` and `AGENTS.md`.

### Fixed
- Fixed unmanaged `Future.delayed` timer in `IncidentHandler.handleCombatEncounter` with `manager.isDisposed` lifecycle guards.

---

## [0.1.0] — 09-10-2026 — Initial Open Source Release

### Added
- Initial open-source release of Vault Bunker 42 OS.
- Wasteland exploration loop with minute-by-minute incident simulation.
- 2-round tactical combat with auto-medkit emergency triage.
- 50-slot Vault Armory stash and Requisition Market.
- Medical Bay chemical synthesis system.
- 100% offline and tracker-free privacy architecture.

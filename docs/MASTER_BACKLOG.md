# 🎯 OVERLORD // Vault Bunker 42 — Master Roadmap & Product Backlog

> **Single Source of Truth** for unbuilt game systems, terminal QOL enhancements, pending vault facilities, and non-negotiable atmospheric boundaries.  
> Shipped releases and version history are recorded chronologically in [`CHANGELOG.md`](../CHANGELOG.md).  
> Canonical gameplay invariants, CRT design tokens, and AI maintainer rules are defined in [`AGENTS.md`](../AGENTS.md).  
> **Date Standard:** All human-facing dates strictly follow Indian numerical formatting (`DD-MM-YYYY`).

---

## ⚡ Tier 1: Immediate Sprint Priorities (High-ROI Terminal Enhancements)

Targeted, self-contained mechanics that enhance Overseer decision-making without breaking the offline RPG architecture.

---

### FEAT-01: Vault Radio Beacon & Dweller Recruitment
- **Domain:** Vault Facilities / Population Expansion
- **Status:** Planned
- **Specification:**
  1. Build a Radio Beacon terminal panel inside `FacilityScreen`.
  2. Broadcasting on wasteland frequency requires 1,000 Caps per broadcast attempt.
  3. Cycle countdown runs over 360 simulated minutes (6 hours). When completed, rolls a chance to recruit a new randomized scavenger with base gear into the roster.
  4. Max active dweller roster cap enforced at 5 scavengers.

---

### FEAT-02: 50-Slot Armory Stash Quick-Sort & Type Filter
- **Domain:** Inventory Management / UI
- **Status:** Planned
- **Specification:**
  1. Add quick-filter chips on the 50-slot Stash sheet (`[ALL]`, `[WEAPON]`, `[ARMOR]`, `[CONSUMABLE]`, `[SCRAP]`).
  2. Add a 1-tap "Sort by Value" and "Sort by Weight" button.
  3. Ensure UI panel complies strictly with the < 400 lines file limit.

---

### FEAT-03: Procedural Retro Synthesizer Sound FX (100% Offline)
- **Domain:** Audio & Atmosphere
- **Status:** Planned
- **Specification:**
  1. Procedurally synthesize short 8-bit square/sine wave audio clicks for terminal keypresses, geiger counter clicks, and combat impacts.
  2. Must **never** require external audio asset streaming or remote CDNs. Pure local playback.
  3. Include a global MUTE toggle in the Overseer header.

---

## 🏭 Tier 2: Vault Facility Expansions

Substantive multi-step facility modules expanding Bunker 42 capabilities.

---

### FEAT-04: Hydroponics Greenhouse Facility
- **Domain:** Vault Facilities / Synthesis
- **Status:** Planned
- **Specification:**
  1. Unlockable after Medical Bay (Unlock Cost: 15,000 Caps).
  2. Cultivates `med_herb` passively over 720 simulated minutes (12 hours).
  3. Provides raw botanical materials directly feedable into Medical Bay medkit crafting cycles.

---

### FEAT-05: Munitions & Armor Plating Workshop
- **Domain:** Crafting & Equipment Upgrades
- **Status:** Planned
- **Specification:**
  1. Allows recycling 10x Scrap Metal to reinforce equipped weapons (+1 to +3 maxStat) or add +1 Damage Resistance (DR) to body armor.
  2. Caps max upgrade tier to prevent combat trivialization.

---

## ☢️ Tier 3: Wasteland POI & Atmospheric Events

Expansions to the exploration incident generator and world map.

---

### FEAT-06: Rad-Storms & Severe Atmospheric Weather
- **Domain:** Exploration Engine / Incidents
- **Status:** Planned
- **Specification:**
  1. Exploration loop periodically rolls environmental hazards (Acid Rain, Toxic Cloud, Radiation Storm).
  2. Dwellers without Rad-X or specialized armor take passive attrition damage (+2 HP loss per 10 minutes) unless recalled to the bunker.

---

### FEAT-07: Wandering Wasteland Caravans (Nomad Traders)
- **Domain:** Economy & Scavenging
- **Status:** Planned
- **Specification:**
  1. Random chance during exploration to encounter a friendly Nomad Caravan.
  2. Dwellers can trade gathered scrap directly in the field for emergency medkits or rare Tier 3 relic blueprints.

---

## 🚫 Product Anti-Goals (What Overlord Is NOT)

1. **NEVER an Online Multiplayer or Live-Service Game:** Overlord is a single-player, introspective, atmospheric retro simulation. No leaderboards, no guild servers, no cloud PVP.
2. **ZERO Remote Telemetry & Tracking:** No Firebase Analytics, Google Analytics, Facebook SDK, Crashlytics, or ad mediation networks. The app must run 100% offline in airplane mode.
3. **NO Generic Material 3 Themes:** No modern pastel colors, Google Fonts network fetches, or curved white Material Design cards. The aesthetic is strictly green-phosphor CRT retro-terminal.
4. **NO Pay-to-Win Microtransactions:** All caps, medkits, weapons, and facilities are earned exclusively through wasteland exploration and strategic management.

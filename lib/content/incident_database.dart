class IncidentDatabase {
  // ==========================================
  // COMBAT TEXTS
  // ==========================================
  static final Map<String, List<String>> combatLogs = {
    'setup': [
      "[COMBAT] Cornered by a {enemy}. Nowhere to run. Have to fight my way out.",
      "[COMBAT] Kicked open the door. A {enemy} is staring right at me. Weapons hot!",
      "[COMBAT] Locked eyes with a {enemy} in the ruins. Raising my {weapon}!",
      "[COMBAT] A {enemy} blocks the path forward. Engaging target.",
    ],
    'flawless': [
      "[RESOLVED] Dropped the {enemy} instantly with my {weapon}. Didn't even leave a scratch.",
      "[RESOLVED] A perfect strike with my {weapon}. The {enemy} didn't stand a chance.",
    ],
    'messy': [
      "[RESOLVED] Took a nasty hit for {damage} damage, but my {weapon} finally finished the job.",
      "[RESOLVED] The {enemy} bit me for {damage} damage before I caved its skull in.",
    ],
    'flee': [
      "[RETREAT] The {enemy} was too tough. Took {damage} damage and barely escaped with my life.",
      "[RETREAT] Armor took a beating. Lost {damage} HP and fell back. Not worth dying over.",
    ],
    'fatal': [
      "[KIA] Took a fatal hit from the {enemy}. Signal lost.",
      "[KIA] Armor breached by the {enemy}. Vitals flatlining...",
    ],
    'ambush_enemy': [
      "[AMBUSH] A {enemy} dropped from the ceiling! Took {damage} damage.",
      "[AMBUSH] Ambushed by a {enemy}! Ripped for {damage} damage before I could react.",
      "[AMBUSH] Caught off guard. A {enemy} struck me for {damage} damage.",
    ],
    'ambush_player': [
      "[AMBUSH] Got the drop on a {enemy}. Smashed it before it saw me.",
      "[AMBUSH] Sneaked up behind a {enemy} and landed a brutal first strike.",
    ],
    'stealth_success': [
      "[STEALTH] Spotted a {enemy} ahead. Held my breath and slipped past.",
      "[STEALTH] A {enemy} was patrolling. I managed to ghost right by it.",
    ],
  };

  // ==========================================
  // EXPLORATION & LOOT TEXTS
  // ==========================================
  static final Map<String, List<String>> eventLogs = {
    'minor_empty': [
      "Found an abandoned car. Trunk was rusted shut.",
      "Searched a collapsed tent. Nothing but irradiated dust.",
      "Followed a trail of footprints, but they led to a dead end.",
    ],
    'minor_caps': [
      "Pry-bar worked on a locked locker. Found {amount} caps.",
      "Checked a pre-war vending machine. Scraped together {amount} caps.",
    ],
    'minor_loot': [
      "[Event] Found an intact duffel bag in the rubble...",
      "[Event] Broke the lock on a sealed shipping crate...",
    ],
    'poi_locked': [
      "The entrance is completely collapsed. Moving on.",
      "Electronic lock is fused shut. No way inside.",
    ],
    'poi_breach': [
      "Breached the interior. Searching for salvage...",
      "Kicked the rusted door in. Flashlight clicked on.",
    ],
    'poi_boss_warn': [
      "[WARNING] Massive heat signature detected!",
      "[WARNING] Hearing incredibly heavy footsteps ahead...",
    ],
    'poi_trap': [
      "[TRAP] Tripped a rusted wire! Took {damage} damage.",
      "[TRAP] The floorboards gave way! Dropped into a spike pit for {damage} damage.",
    ],
    'trap_fatal': [
      "[FATAL] Bleeding out from trap shrapnel.",
      "[FATAL] The trap crushed my chest. Vitals failing...",
    ],
    'auto_heal': [
      "[CRITICAL] Vitals dropping. Auto-injected Medkit.",
      "[CRITICAL] Severe blood loss detected. Emergency Medkit deployed.",
    ],
    'loot_caps': [
      "Scraped together {amount} Caps from the ruins.",
      "Found a loose floorboard hiding {amount} Caps.",
    ],
    'loot_scrap': [
      "Scavenged {amount}x {item}.",
      "Searched some debris and found {amount}x {item}.",
    ],
    'loot_consumable': [
      "Scavenged supplies: {item}.",
      "Pryed loose an intact {item} from a wall cache.",
    ],
    'loot_gear_find': [
      "[JACKPOT] Found an intact equipment case!",
      "[JACKPOT] Uncovered a sealed pre-war weapon locker!",
    ],
    'loot_gear_get': [
      "Acquired: {item} (Tier {tier}).",
      "Pulled {item} (Tier {tier}) out of the dust.",
    ],
    'backpack_full': [
      "[Warning] Backpack full. Dropped {item}.",
      "[Warning] No inventory space. Had to leave {item} behind.",
    ],

    // ==========================================
    // NPC ENCOUNTERS
    // ==========================================
    'npc_doctor_success': [
      "[NPC] Paid a wandering doctor 20 Caps. Patched up (+{healAmount} HP).",
      "[NPC] Traded 20 Caps to a caravan medic for some clean bandages (+{healAmount} HP).",
    ],
    'npc_doctor_fail': [
      "[NPC] Saw a medical caravan, but couldn't afford their 20 Cap fee.",
      "[NPC] Begged a doctor for help, but they pointed a shotgun at me until I showed Caps.",
    ],
    'npc_neutral': [
      "[NPC] Passed a heavily armed patrol. Exchanged nods, no shots fired.",
      "[NPC] Saw a scavenger picking through a rusted car. Left them to it.",
      "[NPC] A drifter asked for directions to a settlement. I lied and walked away.",
    ],
    'npc_scam_success': [
      "[NPC] Bought 'purified water' from a drifter for {lostCaps} Caps. It was irradiated sand. Scammed.",
      "[NPC] Lost {lostCaps} Caps playing a rigged shell game with a caravan guard.",
    ],
    'npc_scam_fail': [
      "[NPC] Drifter tried to sell me garbage. Pushed past them.",
      "[NPC] Someone offered me a 'treasure map'. I laughed and kept walking.",
    ],
    'npc_mugging': [
      "[NPC] Ambushed by a thug! Fired a warning shot and ran. Scraped my knee (-{damage} HP).",
      "[NPC] A raider took a potshot at me! Dove into a ditch and twisted my ankle (-{damage} HP).",
    ],

    // ==========================================
    // SURVIVAL & SELF-ACTS
    // ==========================================
    'survival_rest': [
      "[SURVIVAL] Found an abandoned, secure campsite. Rested for an hour (+{healAmount} HP).",
      "[SURVIVAL] Found a clean spring and washed my wounds. Feeling refreshed (+{healAmount} HP).",
    ],
    'survival_neutral': [
      "[SURVIVAL] Rad-storm rolled in. Took shelter in a rusted car chassis until it passed.",
      "[SURVIVAL] Boot soles are wearing dangerously thin. Wrapped them in duct tape.",
      "[SURVIVAL] Found a pre-war comic book. Read it for ten minutes to stay sane.",
    ],
    'survival_hazard': [
      "[SURVIVAL] Drank from a seemingly clean puddle. Violently ill (-{damage} HP).",
      "[SURVIVAL] Didn't check my boots before putting them on. Rad-scorpion sting! (-{damage} HP).",
      "[SURVIVAL] Inhaled some toxic spores from a glowing fungus. Lungs are burning (-{damage} HP).",
    ],
  };
}

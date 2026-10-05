class ItemDatabase {
  static const List<Map<String, dynamic>> consumables = [
    {
      'id': 'c_medkit',
      'name': 'Wasteland Medkit',
      'type': 'consumable',
      'value': 100,
      'isStackable': true,
      'tier': 1,
      'isBuyable': true,
      'imagePath': 'assets/images/items/medkit.png',
      'description': 'Standard issue trauma kit. Instantly stabilizes vitals.',
    },
    {
      'id': 'f_dogfood',
      'name': 'Pre-War Dog Food',
      'type': 'food',
      'value': 25,
      'isStackable': true,
      'tier': 1,
      'minStat': -20,
      'maxStat': 30,
      'isBuyable': false,
      'imagePath': 'assets/images/items/can_food.png',
      'description': 'Smells terrible, but protein is protein.',
    },
  ];

  static const List<Map<String, dynamic>> scrap = [
    {
      'id': 'loot_caps',
      'name': 'Wasteland Caps',
      'type': 'scrap',
      'value': 1,
      'isStackable': true,
      'tier': 1,
      'isBuyable': false,
      'imagePath': 'assets/images/items/caps.png',
    },
    {
      'id': 'chem_expired',
      'name': 'Expired Chemicals',
      'type': 'material',
      'value': 5,
      'isStackable': true,
      'tier': 1,
      'isBuyable': false,
      'description': 'A cloudy vial. Essential for Medbay crafting.',
    },
    {
      'id': 'med_herb',
      'name': 'Irradiated Herb',
      'type': 'material',
      'value': 5,
      'isStackable': true,
      'tier': 1,
      'isBuyable': false,
      'description': 'Tough, bitter roots. Essential for Medbay crafting.',
    },
    {
      'id': 'med_syringe',
      'name': 'Used Syringe',
      'type': 'material',
      'value': 5,
      'isStackable': true,
      'tier': 1,
      'isBuyable': false,
      'description': 'Needs to be sterilized. Essential for Medbay crafting.',
    },
  ];

  static const List<Map<String, dynamic>> weapons = [
    // Tier 1: Desperate Measures
    {
      "id": "w_stapler",
      "name": "Heavy Duty Staple Gun",
      "type": "weapon",
      "tier": 1,
      "value": 75,
      "minStat": 3,
      "maxStat": 6,
      "description":
          "Requires getting uncomfortably close. Good for flyers, bad for armor.",
      "imagePath": "assets/images/items/mace.png",
    },
    {
      "id": "w_rebar",
      "name": "Rusted Rebar",
      "type": "weapon",
      "tier": 1,
      "value": 120,
      "minStat": 4,
      "maxStat": 9,
      "description":
          "A classic argument settler with dried blood on the heavy end.",
      "imagePath": "assets/images/items/staff.png",
    },

    // Tier 2: The Gunsmith
    {
      "id": "w_pipe_pistol",
      "name": "9mm Pipe Pistol",
      "type": "weapon",
      "tier": 2,
      "value": 350,
      "minStat": 8,
      "maxStat": 14,
      "description":
          "Jams 10% of the time, but it beats swinging a stick. Smells like sulfur.",
      "imagePath": "assets/images/items/pistol.png",
    },
    {
      "id": "w_nailgun",
      "name": "Modified Nailgun",
      "type": "weapon",
      "tier": 2,
      "value": 450,
      "minStat": 10,
      "maxStat": 18,
      "description":
          "Bypasses armor mostly because of the tetanus. Heavy battery pack attached.",
      "imagePath": "assets/images/items/weapon.png",
    },

    // Tier 3: Pre-War Relics
    {
      "id": "w_service_rifle",
      "name": "Pre-War Service Rifle",
      "type": "weapon",
      "tier": 3,
      "value": 1500,
      "minStat": 20,
      "maxStat": 35,
      "description":
          "Clean, oiled, and deadly accurate. A ghost from a functioning military.",
      "imagePath": "assets/images/items/weapon.png",
    },
    {
      "id": "w_plasma",
      "name": "Plasma Torch",
      "type": "weapon",
      "tier": 3,
      "value": 2500,
      "minStat": 30,
      "maxStat": 50,
      "description":
          "Originally meant for cutting ship bulkheads. Works just as well on raiders.",
      "imagePath": "assets/images/items/weapon.png",
    },
  ];

  static const List<Map<String, dynamic>> armor = [
    // Tier 1: Better Than Naked
    {
      "id": "a_phonebooks",
      "name": "Taped-Up Phonebooks",
      "type": "armor",
      "tier": 1,
      "value": 80,
      "minStat": 2,
      "maxStat": 6,
      "description":
          "Stops a knife. Barely slows down a bullet. Incredibly heavy when wet.",
      "imagePath": "assets/images/items/vest.png",
    },
    {
      "id": "a_leather",
      "name": "Boiled Leather Apron",
      "type": "armor",
      "tier": 1,
      "value": 150,
      "minStat": 4,
      "maxStat": 10,
      "description":
          "Smells terrible, but deflects minor mutant bites and shrapnel.",
      "imagePath": "assets/images/items/vest_2.png",
    },

    // Tier 2: The Scavenger
    {
      "id": "a_motorcycle",
      "name": "Motorcycle Leathers",
      "type": "armor",
      "tier": 2,
      "value": 400,
      "minStat": 8,
      "maxStat": 14,
      "description":
          "Reinforced with chains and road signs. Classic wasteland chic.",
      "imagePath": "assets/images/items/vest.png",
    },
    {
      "id": "a_scrap_plate",
      "name": "Welded Scrap Plate",
      "type": "armor",
      "tier": 2,
      "value": 600,
      "minStat": 12,
      "maxStat": 18,
      "description":
          "Clanks loudly, ruining stealth, but it protects the vital organs perfectly.",
      "imagePath": "assets/images/items/vest_2.png",
    },

    // Tier 3: High-Value
    {
      "id": "a_riot_gear",
      "name": "Pre-War Riot Suit",
      "type": "armor",
      "tier": 3,
      "value": 1800,
      "minStat": 18,
      "maxStat": 22,
      "description":
          "Pristine, terrifying, and certified kick-proof. The visor still tactical-glows.",
      "imagePath": "assets/images/items/vest.png",
    },
    {
      "id": "a_power_frame",
      "name": "Scrap-Iron Power Frame",
      "type": "armor",
      "tier": 3,
      "value": 3000,
      "minStat": 25,
      "maxStat": 35,
      "description":
          "Moves at 2 miles an hour, but makes the wearer practically immortal to small arms.",
      "imagePath": "assets/images/items/vest_2.png",
    },
  ];
}

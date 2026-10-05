class EnemyDatabase {
  // --- ENEMIES ---
  static const List<Map<String, dynamic>> enemies = [
    // Category 1: The Pests
    {
      "id": "e_rat",
      "name": "Mutated Rat",
      "category": 1,
      "hp": 5,
      "minDamage": 2,
      "maxDamage": 6,
      "description":
          "Ankle biters the size of a bulldog. Mostly just an annoyance unless they swarm.",
      "imagePath": "assets/images/enemies/e_rat.png",
    },
    {
      "id": "e_hound",
      "name": "Feral Hound",
      "category": 1,
      "hp": 12,
      "minDamage": 4,
      "maxDamage": 10,
      "description":
          "Fast, unpredictable, and goes straight for the unarmored spots.",
      "imagePath": "assets/images/enemies/e_hound.png",
    },

    // Category 2: The Wastelanders
    {
      "id": "e_scrapper",
      "name": "Desperate Scrapper",
      "category": 2,
      "hp": 20,
      "minDamage": 6,
      "maxDamage": 12,
      "description":
          "Swinging a crowbar wildly. Desperation makes them dangerous.",
      "imagePath": "assets/images/enemies/e_scrapper.png",
    },
    {
      "id": "e_raider",
      "name": "Raider Enforcer",
      "category": 2,
      "hp": 28,
      "minDamage": 10,
      "maxDamage": 16,
      "description":
          "Actually knows how to aim. You better have real armor for this one.",
      "imagePath": "assets/images/enemies/e_raider.png",
    },

    // Category 3: Lethal Encounters
    {
      "id": "e_drone",
      "name": "Security Drone",
      "category": 3,
      "hp": 45,
      "minDamage": 15,
      "maxDamage": 22,
      "description":
          "Cold, calculated, and doesn't miss. High-end armor required to survive contact.",
      "imagePath": "assets/images/enemies/e_drone.png",
    },
    {
      "id": "e_feral_family",
      "name": "Feral Family",
      "category": 3,
      "hp": 30,
      "minDamage": 8,
      "maxDamage": 16,
      "description": "GHOULS !!!",
      "imagePath": "assets/images/enemies/e_feral_family.png",
    },
    {
      "id": "e_turkey",
      "name": "Featherless Turkey",
      "category": 3,
      "hp": 60,
      "minDamage": 20,
      "maxDamage": 30,
      "description": "It knows martial arts. May God have mercy on your soul.",
      "imagePath": "assets/images/enemies/e_turkey.png",
    },

    // Category 4: Apex POI Guardians
    {
      "id": "e_titan",
      "name": "Pre-War Battlemech",
      "category": 4,
      "hp": 85,
      "minDamage": 22,
      "maxDamage": 38,
      "description":
          "A malfunctioning combat titan guarding underground vault complexes.",
      "imagePath": "assets/images/enemies/e_drone.png",
    },
    {
      "id": "e_behemoth",
      "name": "Irradiated Behemoth",
      "category": 4,
      "hp": 75,
      "minDamage": 20,
      "maxDamage": 35,
      "description":
          "A hulking, mutated mass of muscle and crude scrap-iron plating.",
      "imagePath": "assets/images/enemies/e_feral_family.png",
    },
  ];
}

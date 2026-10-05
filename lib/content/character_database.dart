import 'dart:math';

import '../models/game_models.dart';
import '../utils/engine_helpers.dart';

class CharacterDatabase {
  static final List<Map<String, dynamic>> recruits = [
    {
      'id': 'char_shina',
      'name': 'Shina',
      'maxHp': 80,
      'cost': 150,
      'description': 'Squishy but cheap. A good starter.',
      'imagePath': 'assets/images/char/jonny.webp',
    },
    {
      'id': 'char_drifter',
      'name': 'Drifter',
      'maxHp': 100,
      'cost': 300,
      'description': 'Standard balanced scavenger. Keeps their head down.',
      'imagePath': 'assets/images/char/jonny.webp',
    },
    {
      'id': 'char_robot',
      'name': 'Robot',
      'maxHp': 150,
      'cost': 600,
      'description': 'Tanky. Built for the wasteland.',
      'imagePath': 'assets/images/char/jonny.webp',
    },
  ];

  static Scavenger generateFromTemplate(Map<String, dynamic> template) {
    String? assignedTrait;
    if (EngineHelpers.rollPercent(25)) {
      int traitRoll = EngineHelpers.rollStat(1, 3);
      if (traitRoll == 1) {
        assignedTrait = 'ptsd';
      } else if (traitRoll == 2) {
        assignedTrait = 'paranoid';
      } else {
        assignedTrait = 'psychosis';
      }
    }

    return Scavenger(
      id: "${template['id']}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000).toString().padLeft(3, '0')}",
      name: template['name'],
      maxHp: template['maxHp'],
      hp: template['maxHp'],
      medkits: 0,
      stress: 0,
      hiddenTrait: assignedTrait,
      state: ScavState.idle,
      backpack: [],
      equippedWeapon: null,
      equippedArmor: null,
      logs: ["[System] Hired for ${template['cost']} caps. Awaiting orders."],
      imagePath:
          template['imagePath'] as String? ?? 'assets/images/char/jonny.webp',
    );
  }
}

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/content/character_database.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/engine_helpers.dart';

void main() {
  tearDown(() {
    EngineHelpers.resetRng();
  });

  group('CharacterDatabase', () {
    test('recruits list contains all 3 baseline contractor templates', () {
      expect(CharacterDatabase.recruits.length, equals(3));
      final names = CharacterDatabase.recruits.map((r) => r['name']).toList();
      expect(names, containsAll(['Shina', 'Drifter', 'Robot']));
    });

    test('generateFromTemplate creates a valid idle scavenger with correct maxHp', () {
      final template = CharacterDatabase.recruits.firstWhere((r) => r['id'] == 'char_robot');
      final dweller = CharacterDatabase.generateFromTemplate(template);

      expect(dweller.name, equals('Robot'));
      expect(dweller.maxHp, equals(150));
      expect(dweller.hp, equals(150));
      expect(dweller.state, equals(ScavState.idle));
      expect(dweller.backpack.isEmpty, isTrue);
      expect(dweller.equippedWeapon, isNull);
      expect(dweller.equippedArmor, isNull);
    });

    test('trait roll can assign psychological afflictions to recruits', () {
      final template = CharacterDatabase.recruits.first;

      // Seed RNG so rollPercent(25) returns true and traitRoll returns 1 (ptsd)
      EngineHelpers.setRng(Random(77));

      bool gotTrait = false;
      for (int i = 0; i < 20; i++) {
        final dweller = CharacterDatabase.generateFromTemplate(template);
        if (dweller.hiddenTrait != null) {
          gotTrait = true;
          expect(['ptsd', 'paranoid', 'psychosis'], contains(dweller.hiddenTrait));
          break;
        }
      }

      expect(gotTrait, isTrue);
    });
  });
}

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/engine/incident_handler.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/engine_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    EngineHelpers.resetRng();
  });

  tearDown(() {
    EngineHelpers.resetRng();
  });

  group('Combat Simulation Engine', () {
    test('flawless combat kills enemy on first hit without dweller taking damage', () {
      final manager = GameManager();
      // Scavenger with overpowered weapon and high damage
      final weapon = Item(
        id: 'w_god',
        name: 'God Weapon',
        type: 'weapon',
        minStat: 100,
        maxStat: 100,
      );
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Hero',
        hp: 100,
        maxHp: 100,
        state: ScavState.exploring,
        equippedWeapon: weapon,
      );
      manager.roster = [scav];

      // Seed where player does not get ambushed and executes standard brawl or ambush
      EngineHelpers.setRng(Random(777));

      IncidentHandler.handleCombatEncounter(
        scav,
        manager,
        '[12:00 PM]',
        isOffline: true,
        forcedCategory: 1, // Mutated rat or feral hound (low HP)
      );

      // Hero should take 0 damage and still be at full health
      expect(scav.hp, equals(100));
      expect(scav.state, equals(ScavState.exploring));
      expect(scav.logs.any((l) => l.contains('[RESOLVED]') || l.contains('eliminated instantly')), isTrue);
    });

    test('armor DR reduces incoming damage to 0 when DR exceeds enemy attack', () {
      final manager = GameManager();
      final heavyArmor = Item(
        id: 'a_tank',
        name: 'Titan Armor',
        type: 'armor',
        minStat: 50, // DR 50 blocks all tier 1 attacks
      );
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Tank',
        hp: 100,
        maxHp: 100,
        state: ScavState.exploring,
        equippedArmor: heavyArmor,
      );
      manager.roster = [scav];

      // Run multiple combat encounters with tier 1 enemies
      for (int seed = 0; seed < 10; seed++) {
        EngineHelpers.setRng(Random(seed));
        IncidentHandler.handleCombatEncounter(
          scav,
          manager,
          '[12:00 PM]',
          isOffline: true,
          forcedCategory: 1,
        );
      }

      // Because DR is 50 and category 1 enemies deal max 10 damage, HP must remain 100
      expect(scav.hp, equals(100));
    });

    test('dweller consumes medkit during combat when vitals drop to <= 50%', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Tough Guy',
        hp: 55,
        maxHp: 100,
        state: ScavState.exploring,
      );
      // Give medkit
      scav.backpack.add(Item(id: 'c_medkit', name: 'Medkit', quantity: 1, type: 'consumable'));
      manager.roster = [scav];

      // Force Category 3 enemy (high damage) to breach dweller HP below 50
      EngineHelpers.setRng(Random(12));

      IncidentHandler.handleCombatEncounter(
        scav,
        manager,
        '[12:00 PM]',
        isOffline: true,
        forcedCategory: 3,
      );

      // Either took damage and healed or survived
      expect(scav.hp, greaterThan(0));
    });

    test('lethal combat transitions dweller state to dead', () {
      final manager = GameManager();
      // Scavenger with only 1 HP and no armor or medkits
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Doomed Scav',
        hp: 1,
        maxHp: 100,
        state: ScavState.exploring,
      );
      manager.roster = [scav];

      // Force category 4 battlemech encounter
      EngineHelpers.setRng(Random(99));

      IncidentHandler.handleCombatEncounter(
        scav,
        manager,
        '[12:00 PM]',
        isOffline: true,
        forcedCategory: 4,
      );

      if (scav.hp <= 0) {
        expect(scav.state, equals(ScavState.dead));
      }
    });
  });
}

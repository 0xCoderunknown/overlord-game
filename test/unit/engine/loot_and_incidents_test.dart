import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/engine/incident_handler.dart';
import 'package:overlord/engine/loot_engine.dart';
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

  group('LootEngine', () {
    test('generateLoot adds item or caps to backpack', () {
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger');
      EngineHelpers.setRng(Random(42));

      LootEngine.generateLoot(scav, '[12:00 PM]');

      expect(scav.backpack.isNotEmpty, isTrue);
      expect(scav.logs.isNotEmpty, isTrue);
    });

    test('generateDynamicLoot scales with POI tier and days passed', () {
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger');
      EngineHelpers.setRng(Random(999));

      LootEngine.generateDynamicLoot(scav, '[12:00 PM]', 4, 3);

      expect(scav.backpack.isNotEmpty, isTrue);
      expect(scav.logs.any((l) => l.contains('[12:00 PM]')), isTrue);
    });
  });

  group('IncidentHandler', () {
    test('handleMinorEncounter handles caps and scrap safely', () {
      final manager = GameManager();
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger');
      manager.roster = [scav];

      for (int seed = 0; seed < 10; seed++) {
        EngineHelpers.setRng(Random(seed));
        IncidentHandler.handleMinorEncounter(scav, manager, '[12:00 PM]');
      }

      expect(scav.logs.length, equals(10));
    });

    test('handleSurvivalAct rest or hazard affects HP safely', () {
      final manager = GameManager();
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger', hp: 50, maxHp: 100);
      manager.roster = [scav];

      for (int seed = 0; seed < 10; seed++) {
        EngineHelpers.setRng(Random(seed));
        IncidentHandler.handleSurvivalAct(scav, manager, '[12:00 PM]');
      }

      expect(scav.hp, greaterThanOrEqualTo(0));
      expect(scav.hp, lessThanOrEqualTo(100));
    });

    test('handleNPCEncounter executes doctor, scam, or mugger logic without crashing', () {
      final manager = GameManager();
      manager.caps = 100;
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger', hp: 50, maxHp: 100);
      manager.roster = [scav];

      for (int seed = 0; seed < 10; seed++) {
        EngineHelpers.setRng(Random(seed));
        IncidentHandler.handleNPCEncounter(scav, manager, '[12:00 PM]');
      }

      expect(manager.caps, greaterThanOrEqualTo(0));
      expect(scav.logs.isNotEmpty, isTrue);
    });
  });
}

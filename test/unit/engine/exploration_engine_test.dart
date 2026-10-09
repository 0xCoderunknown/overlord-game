import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/exploration_engine.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/engine_helpers.dart';
import 'package:overlord/utils/game_config.dart';
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

  group('ExplorationEngine', () {
    test('idle dweller regenerates +1 HP per simulated minute', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_test',
        name: 'Resting Scav',
        hp: 50,
        maxHp: 100,
        state: ScavState.idle,
      );
      manager.roster = [scav];

      ExplorationEngine.processTicks(manager, 10, isOffline: true);

      expect(scav.hp, equals(60));
    });

    test('idle dweller HP does not exceed maxHp', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_test',
        name: 'Full Health Scav',
        hp: 98,
        maxHp: 100,
        state: ScavState.idle,
      );
      manager.roster = [scav];

      ExplorationEngine.processTicks(manager, 10, isOffline: true);

      expect(scav.hp, equals(100));
    });

    test('exploring dweller auto-returns when backpack reaches weight limit', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_test',
        name: 'Pack Scav',
        hp: 100,
        maxHp: 100,
        state: ScavState.exploring,
        minutesExplored: 40,
      );

      // Fill backpack to limit (10 items)
      for (int i = 0; i < GameConfig.maxBackpackWeight; i++) {
        scav.backpack.add(Item(id: 'item_$i', name: 'Item $i', type: 'misc'));
      }
      manager.roster = [scav];

      // Process 1 tick
      ExplorationEngine.processTicks(manager, 1, isOffline: true);

      expect(scav.state, equals(ScavState.returning));
      expect(scav.minutesToReturn, greaterThan(0));
    });

    test('returning dweller deposits caps and stashes items upon arrival', () {
      final manager = GameManager();
      manager.caps = 100;
      manager.globalStash = [];

      final scav = Scavenger(
        id: 'scav_test',
        name: 'Returning Scav',
        hp: 100,
        state: ScavState.returning,
        minutesToReturn: 2,
        minutesExplored: 30,
      );

      scav.backpack.add(Item(id: 'loot_caps', name: 'Caps', quantity: 45, type: 'scrap'));
      scav.backpack.add(Item(id: 'w_rebar', name: 'Rusted Rebar', type: 'weapon'));
      manager.roster = [scav];

      // Process 2 ticks (returning countdown reaching 0)
      ExplorationEngine.processTicks(manager, 2, isOffline: true);

      expect(scav.state, equals(ScavState.idle));
      expect(scav.backpack.isEmpty, isTrue);
      expect(manager.caps, equals(145)); // 100 + 45
      expect(manager.globalStash.length, equals(1));
      expect(manager.globalStash.first.id, equals('w_rebar'));
    });

    test('medbay crafting countdown decrements and sets outputReady', () {
      final manager = GameManager();
      manager.medbay.isUnlocked = true;
      manager.medbay.isCrafting = true;
      manager.medbay.minutesRemaining = 5;
      manager.medbay.outputReady = false;

      ExplorationEngine.processTicks(manager, 5, isOffline: true);

      expect(manager.medbay.isCrafting, isFalse);
      expect(manager.medbay.outputReady, isTrue);
      expect(manager.medbay.minutesRemaining, lessThanOrEqualTo(0));
    });
  });
}

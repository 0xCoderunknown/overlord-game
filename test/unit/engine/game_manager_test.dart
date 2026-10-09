import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameManager Economy & Transactions', () {
    test('buyItem deducts caps and adds to globalStash', () {
      final manager = GameManager();
      manager.caps = 500;
      manager.globalStash.clear();

      final weapon = Item(id: 'w_nailgun', name: 'Nailgun', value: 450, type: 'weapon');
      final success = manager.buyItem(weapon);

      expect(success, isTrue);
      expect(manager.caps, equals(50)); // 500 - 450
      expect(manager.globalStash.length, equals(1));
    });

    test('buyItem fails if player has insufficient caps', () {
      final manager = GameManager();
      manager.caps = 100;

      final expensiveWeapon = Item(id: 'w_sniper', name: 'Sniper', value: 800, type: 'weapon');
      final success = manager.buyItem(expensiveWeapon);

      expect(success, isFalse);
      expect(manager.caps, equals(100));
    });

    test('sellItem removes item and credits caps', () {
      final manager = GameManager();
      manager.caps = 100;
      final scrap = Item(id: 'scrap_plate', name: 'Scrap Plate', value: 15, type: 'scrap', quantity: 1);
      manager.globalStash = [scrap];

      manager.sellItem(scrap);

      expect(manager.caps, equals(115));
      expect(manager.globalStash.isEmpty, isTrue);
    });

    test('sellItem decrements quantity for stackable items', () {
      final manager = GameManager();
      manager.caps = 50;
      final medkits = Item(
        id: 'c_medkit',
        name: 'Medkit',
        value: 100,
        type: 'consumable',
        isStackable: true,
        quantity: 3,
      );
      manager.globalStash = [medkits];

      manager.sellItem(medkits); // Sells 1 of 3

      expect(manager.caps, equals(150));
      expect(manager.globalStash.length, equals(1));
      expect(manager.globalStash.first.quantity, equals(2));
    });
  });

  group('GameManager Stash & Equipment Transfers', () {
    test('moveItemStashToBackpack moves item correctly', () {
      final manager = GameManager();
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger');
      manager.roster = [scav];

      final item = Item(id: 'w_stapler', name: 'Stapler', type: 'weapon', quantity: 1);
      manager.globalStash = [item];

      final moved = manager.moveItemStashToBackpack(scav, item);

      expect(moved, isTrue);
      expect(manager.globalStash.isEmpty, isTrue);
      // Because scav had no weapon, auto-equip immediately equipped it!
      expect(scav.equippedWeapon?.id, equals('w_stapler'));
    });

    test('moveItemBackpackToStash moves item and frees backpack space', () {
      final manager = GameManager();
      manager.globalStash.clear();

      final scav = Scavenger(id: 'scav_1', name: 'Scavenger');
      final miscItem = Item(id: 'junk_fan', name: 'Desk Fan', type: 'misc', quantity: 1);
      scav.backpack = [miscItem];
      manager.roster = [scav];

      final moved = manager.moveItemBackpackToStash(scav, miscItem);

      expect(moved, isTrue);
      expect(scav.backpack.isEmpty, isTrue);
      expect(manager.globalStash.length, equals(1));
      expect(manager.globalStash.first.id, equals('junk_fan'));
    });

    test('unequipItem moves weapon to globalStash', () {
      final manager = GameManager();
      manager.globalStash.clear();

      final weapon = Item(id: 'w_pipe', name: 'Pipe Pistol', type: 'weapon');
      final scav = Scavenger(id: 'scav_1', name: 'Scavenger', equippedWeapon: weapon);
      manager.roster = [scav];

      manager.unequipItem(scav, 'weapon');

      expect(scav.equippedWeapon, isNull);
      expect(manager.globalStash.length, equals(1));
      expect(manager.globalStash.first.id, equals('w_pipe'));
    });
  });

  group('GameManager Vault Facilities & Crafting', () {
    test('unlockMedbay checks cost and sets unlocked', () {
      final manager = GameManager();
      manager.caps = GameConfig.medbayUnlockCost + 500;
      manager.medbay.isUnlocked = false;

      final unlocked = manager.unlockMedbay();

      expect(unlocked, isTrue);
      expect(manager.medbay.isUnlocked, isTrue);
      expect(manager.caps, equals(500));
    });

    test('startMedbayCrafting consumes materials from stash', () {
      final manager = GameManager();
      manager.medbay.isUnlocked = true;
      manager.medbay.isCrafting = false;
      manager.medbay.outputReady = false;

      // Add required recipe items to stash
      manager.globalStash = [
        Item(id: 'med_syringe', name: 'Syringe', isStackable: true, quantity: 1),
        Item(id: 'med_herb', name: 'Herb', isStackable: true, quantity: 2),
        Item(id: 'chem_expired', name: 'Chemicals', isStackable: true, quantity: 1),
      ];

      final started = manager.startMedbayCrafting();

      expect(started, isTrue);
      expect(manager.medbay.isCrafting, isTrue);
      expect(manager.medbay.minutesRemaining, equals(GameConfig.medbayCraftingTime));
      expect(manager.globalStash.isEmpty, isTrue); // All consumed
    });

    test('claimMedbayOutput deposits 2x medkits into stash', () {
      final manager = GameManager();
      manager.globalStash.clear();
      manager.medbay.outputReady = true;

      final claimed = manager.claimMedbayOutput();

      expect(claimed, isTrue);
      expect(manager.medbay.outputReady, isFalse);
      expect(manager.globalStash.length, equals(1));
      expect(manager.globalStash.first.id, equals('c_medkit'));
      expect(manager.globalStash.first.quantity, equals(2));
    });
  });

  group('GameManager Roster Protocols', () {
    test('sendToWasteland transitions idle dweller to exploring', () {
      final manager = GameManager();
      final scav = Scavenger(id: 'scav_1', name: 'Jonny', state: ScavState.idle);
      manager.roster = [scav];

      manager.sendToWasteland(scav);

      expect(scav.state, equals(ScavState.exploring));
      expect(scav.logs.last, contains('Deployment authorized'));
    });

    test('recallScavenger calculates return travel time', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Jonny',
        state: ScavState.exploring,
        minutesExplored: 60,
      );
      manager.roster = [scav];

      manager.recallScavenger(scav);

      expect(scav.state, equals(ScavState.returning));
      expect(scav.minutesToReturn, equals(30)); // 60 ~/ 2
    });

    test('reviveScavenger revives fallen dweller and docks fee', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Fallen Hero',
        state: ScavState.dead,
        maxHp: 100,
        hp: 0,
        minutesExplored: 40,
      );
      // Give dweller 100 caps in backpack
      scav.backpack.add(Item(id: 'loot_caps', name: 'Caps', quantity: 100, type: 'scrap'));
      manager.roster = [scav];

      manager.reviveScavenger(scav);

      expect(scav.state, equals(ScavState.returning));
      expect(scav.hp, equals(25)); // 25% maxHp
      expect(scav.minutesToReturn, equals(20)); // 40 ~/ 2

      // Fee is 10% of 100 = 10, but minReviveCost is 20 -> 100 - 20 = 80
      final remainingCaps = scav.backpack.firstWhere((i) => i.id == 'loot_caps').quantity;
      expect(remainingCaps, equals(80));
    });
  });
}

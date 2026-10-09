import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/game_config.dart';

void main() {
  group('Item Model', () {
    test('toJson and fromJson round-trip accurately', () {
      final original = Item(
        id: 'w_test',
        name: 'Test Rifle',
        value: 250,
        isStackable: false,
        quantity: 1,
        type: 'weapon',
        tier: 2,
        minStat: 10,
        maxStat: 20,
        description: 'A test rifle.',
        imagePath: 'assets/images/items/pistol.png',
      );

      final json = original.toJson();
      final reconstructed = Item.fromJson(json);

      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.name, equals(original.name));
      expect(reconstructed.value, equals(original.value));
      expect(reconstructed.isStackable, equals(original.isStackable));
      expect(reconstructed.type, equals(original.type));
      expect(reconstructed.tier, equals(original.tier));
      expect(reconstructed.minStat, equals(original.minStat));
      expect(reconstructed.maxStat, equals(original.maxStat));
    });

    test('Item.fromDatabase builds item with unique ID if requested', () {
      final data = {
        'id': 'w_stapler',
        'name': 'Heavy Duty Staple Gun',
        'type': 'weapon',
        'tier': 1,
        'value': 75,
        'minStat': 3,
        'maxStat': 6,
      };

      final itemA = Item.fromDatabase(data, generateUniqueId: true);
      final itemB = Item.fromDatabase(data, generateUniqueId: true);

      expect(itemA.id, isNot(equals(itemB.id)));
      expect(itemA.name, equals('Heavy Duty Staple Gun'));
      expect(itemA.minStat, equals(3));
    });
  });

  group('Scavenger Model', () {
    test('currentWeight excludes loot_caps', () {
      final scav = Scavenger(id: 'scav_1', name: 'Test Scav');

      scav.backpack.add(Item(id: 'loot_caps', name: 'Caps', quantity: 50, type: 'scrap'));
      scav.backpack.add(Item(id: 'scrap_metal', name: 'Scrap', quantity: 2, type: 'scrap'));
      scav.backpack.add(Item(id: 'c_medkit', name: 'Medkit', quantity: 1, type: 'consumable'));

      // 3 items in list, but caps are weightless -> weight should be 2
      expect(scav.currentWeight, equals(2));
    });

    test('addItemToBackpack auto-equips first weapon', () {
      final scav = Scavenger(id: 'scav_1', name: 'Test Scav');
      final weapon = Item(
        id: 'w_pipe',
        name: 'Pipe Pistol',
        type: 'weapon',
        tier: 1,
        minStat: 5,
        maxStat: 10,
      );

      final added = scav.addItemToBackpack(weapon);

      expect(added, isTrue);
      expect(scav.equippedWeapon, equals(weapon));
      expect(scav.backpack.isEmpty, isTrue);
    });

    test('addItemToBackpack swaps weapon when higher tier or better average damage', () {
      final scav = Scavenger(id: 'scav_1', name: 'Test Scav');
      final weakWeapon = Item(
        id: 'w_weak',
        name: 'Weak Weapon',
        type: 'weapon',
        tier: 1,
        minStat: 2,
        maxStat: 4, // avg 3
      );
      final strongWeapon = Item(
        id: 'w_strong',
        name: 'Strong Weapon',
        type: 'weapon',
        tier: 1,
        minStat: 8,
        maxStat: 12, // avg 10
      );

      scav.addItemToBackpack(weakWeapon);
      expect(scav.equippedWeapon?.id, equals('w_weak'));

      scav.addItemToBackpack(strongWeapon);
      expect(scav.equippedWeapon?.id, equals('w_strong'));
      expect(scav.backpack.length, equals(1));
      expect(scav.backpack.first.id, equals('w_weak'));
    });

    test('addItemToBackpack auto-equips armor and swaps for higher DR', () {
      final scav = Scavenger(id: 'scav_1', name: 'Test Scav');
      final lightArmor = Item(
        id: 'a_light',
        name: 'Light Armor',
        type: 'armor',
        tier: 1,
        minStat: 2, // DR = 2
      );
      final heavyArmor = Item(
        id: 'a_heavy',
        name: 'Heavy Armor',
        type: 'armor',
        tier: 2,
        minStat: 6, // DR = 6
      );

      scav.addItemToBackpack(lightArmor);
      expect(scav.equippedArmor?.id, equals('a_light'));

      scav.addItemToBackpack(heavyArmor);
      expect(scav.equippedArmor?.id, equals('a_heavy'));
      expect(scav.backpack.first.id, equals('a_light'));
    });

    test('addItemToBackpack respects maxBackpackWeight limit of 10', () {
      final scav = Scavenger(id: 'scav_1', name: 'Test Scav');

      for (int i = 0; i < GameConfig.maxBackpackWeight; i++) {
        final item = Item(id: 'item_$i', name: 'Item $i', type: 'misc');
        final added = scav.addItemToBackpack(item);
        expect(added, isTrue);
      }

      expect(scav.currentWeight, equals(GameConfig.maxBackpackWeight));

      // 11th non-cap item should be rejected
      final overflowItem = Item(id: 'item_overflow', name: 'Overflow Item', type: 'misc');
      final addedOverflow = scav.addItemToBackpack(overflowItem);
      expect(addedOverflow, isFalse);
      expect(scav.backpack.length, equals(GameConfig.maxBackpackWeight));

      // Caps can still be added even when backpack is full
      final caps = Item(id: 'loot_caps', name: 'Caps', type: 'scrap', quantity: 100);
      final addedCaps = scav.addItemToBackpack(caps);
      expect(addedCaps, isTrue);
    });

    test('consumeMedkit triggers at or below 50% HP and restores 50% maxHp', () {
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Injured Scav',
        hp: 50,
        maxHp: 100,
      );
      scav.backpack.add(Item(id: 'c_medkit', name: 'Medkit', quantity: 2, type: 'consumable'));

      // HP is 50/100 (50%) -> should consume medkit
      final consumed = scav.consumeMedkit();
      expect(consumed, isTrue);
      expect(scav.hp, equals(100)); // 50 + 50
      expect(scav.backpack.first.quantity, equals(1));

      // Now at 100/100 -> should not consume medkit
      final secondTry = scav.consumeMedkit();
      expect(secondTry, isFalse);
    });

    test('toJson and fromJson round-trip preserves all scavenger fields', () {
      final scav = Scavenger(
        id: 'scav_json',
        name: 'Json Scav',
        hp: 75,
        maxHp: 120,
        state: ScavState.exploring,
        minutesExplored: 60,
        minutesToReturn: 30,
        stress: 40,
        hiddenTrait: 'ptsd',
      );

      final json = scav.toJson();
      final reconstructed = Scavenger.fromJson(json);

      expect(reconstructed.id, equals(scav.id));
      expect(reconstructed.name, equals(scav.name));
      expect(reconstructed.hp, equals(scav.hp));
      expect(reconstructed.maxHp, equals(scav.maxHp));
      expect(reconstructed.state, equals(ScavState.exploring));
      expect(reconstructed.minutesExplored, equals(60));
      expect(reconstructed.minutesToReturn, equals(30));
      expect(reconstructed.stress, equals(40));
      expect(reconstructed.hiddenTrait, equals('ptsd'));
    });
  });

  group('VaultFacility Model', () {
    test('toJson and fromJson round-trip accurately', () {
      final medbay = VaultFacility(
        id: 'fac_medbay',
        isUnlocked: true,
        isCrafting: true,
        minutesRemaining: 180,
        outputReady: false,
      );

      final json = medbay.toJson();
      final reconstructed = VaultFacility.fromJson(json);

      expect(reconstructed.id, equals('fac_medbay'));
      expect(reconstructed.isUnlocked, isTrue);
      expect(reconstructed.isCrafting, isTrue);
      expect(reconstructed.minutesRemaining, equals(180));
      expect(reconstructed.outputReady, isFalse);
    });
  });
}

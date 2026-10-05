import '../content/incident_database.dart';
import '../content/item_database.dart';
import '../models/game_models.dart';
import '../utils/engine_helpers.dart';

class LootEngine {
  static Item _generateCaps(int amount) {
    var capData = ItemDatabase.scrap.firstWhere(
      (s) => s['id'] == 'loot_caps',
      orElse: () => ItemDatabase.scrap.first,
    );
    return Item.fromDatabase(capData, quantity: amount);
  }

  static void generateDynamicLoot(
    Scavenger scav,
    String timeStr,
    int poiTier,
    int daysPassed,
  ) {
    int categoryRoll = EngineHelpers.rollStat(1, 100);
    int lootBonus = (poiTier * 5) + (daysPassed * 2);
    int finalScore = categoryRoll + lootBonus;

    if (finalScore < 60) {
      int capsFound = EngineHelpers.rollStat(10, 10 + (20 * poiTier) - 1);
      Item caps = _generateCaps(capsFound);

      addToBackpack(scav, caps, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_caps', {'amount': capsFound.toString()})}",
      );
    } else if (finalScore < 90) {
      var consumableData =
          ItemDatabase.consumables[EngineHelpers.rollIndex(
            ItemDatabase.consumables.length,
          )];
      var consumable = Item.fromDatabase(consumableData);

      addToBackpack(scav, consumable, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_consumable', {'item': '*${consumable.name}*'})}",
      );
    } else {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_gear_find', {})}",
      );

      int targetTier = 1;
      int qualityRoll =
          EngineHelpers.rollStat(1, 100) + (poiTier * 10) + daysPassed;

      if (qualityRoll > 100) {
        targetTier = 3;
      } else if (qualityRoll > 70) {
        targetTier = 2;
      }

      bool isWeapon = EngineHelpers.rollPercent(50);
      List<Map<String, dynamic>> validGear = isWeapon
          ? ItemDatabase.weapons.where((w) => w['tier'] == targetTier).toList()
          : ItemDatabase.armor.where((a) => a['tier'] == targetTier).toList();

      if (validGear.isEmpty) {
        validGear = isWeapon ? ItemDatabase.weapons : ItemDatabase.armor;
      }

      if (validGear.isNotEmpty) {
        var gearData = validGear[EngineHelpers.rollIndex(validGear.length)];
        Item foundGear = Item.fromDatabase(gearData, generateUniqueId: true);

        addToBackpack(scav, foundGear, timeStr);
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_gear_get', {'item': '*${foundGear.name}*', 'tier': foundGear.tier.toString()})}",
        );
      } else {
        addToBackpack(scav, _generateCaps(50), timeStr);
        scav.logs.add(
          "$timeStr Box was mostly rusted out. Salvaged 50 Caps instead.",
        );
      }
    }
  }

  static void generateLoot(Scavenger scav, String timeStr) {
    int roll = EngineHelpers.rollStat(0, 99);

    if (roll < 70) {
      var genericScraps = ItemDatabase.scrap
          .where((s) => s['id'] != 'loot_caps')
          .toList();
      if (genericScraps.isEmpty) genericScraps = ItemDatabase.scrap;

      var scrapData =
          genericScraps[EngineHelpers.rollIndex(genericScraps.length)];
      var scrap = Item.fromDatabase(
        scrapData,
        quantity: EngineHelpers.rollStat(3, 6),
      );

      addToBackpack(scav, scrap, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_scrap', {'amount': scrap.quantity.toString(), 'item': '*${scrap.name}*'})}",
      );
    } else if (roll < 90) {
      int capAmount = EngineHelpers.rollStat(12, 25);
      Item capsItem = _generateCaps(capAmount);

      addToBackpack(scav, capsItem, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_caps', {'amount': capAmount.toString()})}",
      );
    } else if (roll < 97) {
      var consumableData =
          ItemDatabase.consumables[EngineHelpers.rollIndex(
            ItemDatabase.consumables.length,
          )];
      var consumable = Item.fromDatabase(consumableData);

      addToBackpack(scav, consumable, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_consumable', {'item': '*${consumable.name}*'})}",
      );
    } else {
      bool getWeapon = EngineHelpers.rollPercent(50);
      var dbList = getWeapon ? ItemDatabase.weapons : ItemDatabase.armor;
      var validItems = dbList
          .where((item) => (item['tier'] as int) == 1)
          .toList();

      if (validItems.isNotEmpty) {
        var randomItemData =
            validItems[EngineHelpers.rollIndex(validItems.length)];
        var gear = Item.fromDatabase(randomItemData, generateUniqueId: true);

        addToBackpack(scav, gear, timeStr);
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'loot_gear_get', {'item': '*${gear.name}*', 'tier': gear.tier.toString()})}",
        );
      } else {
        addToBackpack(scav, _generateCaps(25), timeStr);
        scav.logs.add(
          "$timeStr Found an empty stash box. Salvaged 25 Caps instead.",
        );
      }
    }
  }

  static void addToBackpack(Scavenger scav, Item newItem, String timeStr) {
    int initialLogCount = scav.logs.length;
    scav.addItemToBackpack(newItem);

    for (int i = initialLogCount; i < scav.logs.length; i++) {
      if (!scav.logs[i].startsWith(timeStr)) {
        scav.logs[i] = "$timeStr ${scav.logs[i]}";
      }
    }
  }
}

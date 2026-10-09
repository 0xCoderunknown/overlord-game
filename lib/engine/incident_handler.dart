import 'dart:async';
import 'dart:math';

import '../content/enemy_database.dart';
import '../content/incident_database.dart';
import '../content/item_database.dart';
import '../content/poi_database.dart';
import '../models/game_models.dart';
import '../utils/engine_helpers.dart';
import '../utils/game_config.dart';
import 'game_manager.dart';
import 'loot_engine.dart';

class IncidentHandler {
  static void handleMinorEncounter(
    Scavenger scav,
    GameManager manager,
    String timeStr,
  ) {
    int roll = EngineHelpers.rollStat(0, 99);
    if (roll < 50) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'minor_empty', {})}",
      );
    } else if (roll < 95) {
      int capsFound = EngineHelpers.rollStat(1, 4);
      var capData = ItemDatabase.scrap.firstWhere(
        (s) => s['id'] == 'loot_caps',
        orElse: () => ItemDatabase.scrap.first,
      );
      var capsItem = Item(
        id: capData['id'],
        name: capData['name'],
        type: capData['type'],
        value: capData['value'],
        isStackable: capData['isStackable'],
        quantity: capsFound,
        tier: capData['tier'],
      );
      LootEngine.addToBackpack(scav, capsItem, timeStr);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'minor_caps', {'amount': capsFound.toString()})}",
      );
    } else {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'minor_loot', {})}",
      );
      LootEngine.generateLoot(scav, timeStr);
    }
  }

  static String preRollPOI(int daysPassed) {
    List<Map<String, dynamic>> validPOIs = [];
    for (var poi in POIDatabase.locations) {
      if (poi['tier'] <= (daysPassed + 1)) validPOIs.add(poi);
    }
    if (validPOIs.isEmpty) validPOIs.add(POIDatabase.locations.first);
    return validPOIs[EngineHelpers.rollIndex(validPOIs.length)]['id'];
  }

  static void handlePOIEncounter(
    Scavenger scav,
    GameManager manager,
    String timeStr, {
    required bool isOffline,
    String? preSelectedPoiId,
  }) {
    int daysPassed = scav.minutesExplored ~/ GameConfig.minutesPerDay;
    Map<String, dynamic> selectedPOI;

    if (preSelectedPoiId != null) {
      selectedPOI = POIDatabase.locations.firstWhere(
        (poi) => poi['id'] == preSelectedPoiId,
        orElse: () => POIDatabase.locations.first,
      );
    } else {
      String generatedId = preRollPOI(daysPassed);
      selectedPOI = POIDatabase.locations.firstWhere(
        (poi) => poi['id'] == generatedId,
      );
    }

    scav.logs.add("$timeStr [POI] Approaching ${selectedPOI['name']}...");
    scav.logs.add("$timeStr ${selectedPOI['flavorText']}");

    int lockChance = 15 + ((selectedPOI['tier'] as int) * 5);
    if (EngineHelpers.rollPercent(lockChance)) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'poi_locked', {})}",
      );
      return;
    }

    scav.logs.add(
      "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'poi_breach', {})}",
    );

    int bossChance = selectedPOI['tier'] == 4 ? 15 : (daysPassed * 2);
    int trapChance = 20;
    int roll = EngineHelpers.rollStat(0, 99);

    if (roll < bossChance) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'poi_boss_warn', {})}",
      );
      handleCombatEncounter(
        scav,
        manager,
        timeStr,
        isOffline: isOffline,
        forcedCategory: 4,
        isPoiCombat: true,
        poiTier: selectedPOI['tier'],
        daysPassed: daysPassed,
      );
    } else if (roll < bossChance + trapChance) {
      int dmg = max(5, scav.maxHp ~/ 10);
      scav.hp -= dmg;
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'poi_trap', {'damage': dmg.toString()})}",
      );

      if (scav.consumeMedkit()) {
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'auto_heal', {'item': 'Medkit'})}",
        );
      }

      if (scav.hp <= 0) {
        scav.state = ScavState.dead;
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'trap_fatal', {})}",
        );
      } else {
        LootEngine.generateDynamicLoot(
          scav,
          timeStr,
          selectedPOI['tier'],
          daysPassed,
        );
      }
    } else {
      handleCombatEncounter(
        scav,
        manager,
        timeStr,
        isOffline: isOffline,
        forcedCategory: selectedPOI['tier'],
        isPoiCombat: true,
        poiTier: selectedPOI['tier'],
        daysPassed: daysPassed,
      );
    }
  }

  static void handleCombatEncounter(
    Scavenger scav,
    GameManager manager,
    String timeStr, {
    bool isOffline = false,
    int? forcedCategory,
    bool isPoiCombat = false,
    int poiTier = 1,
    int daysPassed = 0,
  }) {
    int targetCategory =
        forcedCategory ?? (EngineHelpers.rollPercent(70) ? 1 : 2);
    var validEnemies = EnemyDatabase.enemies
        .where((e) => e['category'] == targetCategory)
        .toList();
    if (validEnemies.isEmpty) {
      for (int cat = targetCategory; cat >= 1; cat--) {
        validEnemies = EnemyDatabase.enemies
            .where((e) => e['category'] == cat)
            .toList();
        if (validEnemies.isNotEmpty) break;
      }
      if (validEnemies.isEmpty) validEnemies = EnemyDatabase.enemies;
    }
    if (validEnemies.isEmpty) return;

    final enemyData =
        validEnemies[EngineHelpers.rollIndex(validEnemies.length)];
    String enemyName = enemyData['name'] as String;
    int enemyHp = (enemyData['hp'] as int?) ?? 10;
    int enemyMinDmg = (enemyData['minDamage'] as int?) ?? 2;
    int enemyMaxDmg = (enemyData['maxDamage'] as int?) ?? 5;

    String weaponName = scav.equippedWeapon?.name ?? "Bare Hands";
    int pMinDmg = scav.equippedWeapon?.minStat ?? 1;
    int pMaxDmg = scav.equippedWeapon?.maxStat ?? 2;
    int armorDR = scav.equippedArmor?.minStat ?? 0;

    if (isOffline) {
      _resolveDynamicCombatMath(
        scav,
        manager,
        timeStr,
        enemyName,
        enemyHp,
        enemyMinDmg,
        enemyMaxDmg,
        weaponName,
        pMinDmg,
        pMaxDmg,
        armorDR,
        isPoiCombat,
        poiTier,
        daysPassed,
      );
    } else {
      Future.delayed(const Duration(seconds: 5), () {
        if (manager.isDisposed ||
            !manager.roster.any((s) => s.id == scav.id) ||
            scav.state == ScavState.dead) {
          return;
        }
        _resolveDynamicCombatMath(
          scav,
          manager,
          timeStr,
          enemyName,
          enemyHp,
          enemyMinDmg,
          enemyMaxDmg,
          weaponName,
          pMinDmg,
          pMaxDmg,
          armorDR,
          isPoiCombat,
          poiTier,
          daysPassed,
        );
        if (!manager.isDisposed) {
          manager.notifyStateChanged();
          manager.saveGame();
        }
      });
    }
  }

  static void _resolveDynamicCombatMath(
    Scavenger scav,
    GameManager manager,
    String timeStr,
    String enemyName,
    int enemyHp,
    int eMin,
    int eMax,
    String weaponName,
    int pMin,
    int pMax,
    int armorDR,
    bool isPoiCombat,
    int poiTier,
    int daysPassed,
  ) {
    int encounterRoll = EngineHelpers.rollStat(0, 99);

    if (encounterRoll < 20) {
      int ambushDamage = (EngineHelpers.rollStat(eMin, eMax) * 1.2).toInt();
      int damageTaken = max(0, ambushDamage - armorDR);
      scav.hp = max(0, scav.hp - damageTaken);

      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'ambush_enemy', {'enemy': enemyName, 'damage': damageTaken.toString()})}",
      );

      _checkHealthAndMedkit(scav, timeStr);
      if (scav.state == ScavState.dead) return;

      _executeStandardBrawl(
        scav,
        manager,
        timeStr,
        enemyName,
        enemyHp,
        eMin,
        eMax,
        weaponName,
        pMin,
        pMax,
        armorDR,
        isPoiCombat,
        poiTier,
        daysPassed,
      );
      return;
    }

    int tacticRoll = EngineHelpers.rollStat(0, 99);

    if (tacticRoll < 10) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'stealth_success', {'enemy': enemyName})}",
      );
      return;
    }

    if (tacticRoll >= 10 && tacticRoll < 20) {
      int ambushStrike = (EngineHelpers.rollStat(pMin, pMax) * 1.5).toInt();
      enemyHp -= ambushStrike;

      if (enemyHp <= 0) {
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'ambush_player', {'enemy': enemyName})} Target eliminated instantly.",
        );
        _grantLoot(scav, manager, timeStr, isPoiCombat, poiTier, daysPassed);
        return;
      }

      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'ambush_player', {'enemy': enemyName})} Landed a heavy blow, but it's still standing.",
      );
      _executeStandardBrawl(
        scav,
        manager,
        timeStr,
        enemyName,
        enemyHp,
        eMin,
        eMax,
        weaponName,
        pMin,
        pMax,
        armorDR,
        isPoiCombat,
        poiTier,
        daysPassed,
      );
      return;
    }

    scav.logs.add(
      "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'setup', {'enemy': enemyName, 'weapon': weaponName})}",
    );
    _executeStandardBrawl(
      scav,
      manager,
      timeStr,
      enemyName,
      enemyHp,
      eMin,
      eMax,
      weaponName,
      pMin,
      pMax,
      armorDR,
      isPoiCombat,
      poiTier,
      daysPassed,
    );
  }

  static void _executeStandardBrawl(
    Scavenger scav,
    GameManager manager,
    String timeStr,
    String enemyName,
    int enemyHp,
    int eMin,
    int eMax,
    String weaponName,
    int pMin,
    int pMax,
    int armorDR,
    bool isPoiCombat,
    int poiTier,
    int daysPassed,
  ) {
    int firstHit = EngineHelpers.rollStat(pMin, pMax);
    enemyHp -= firstHit;
    if (enemyHp <= 0) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'flawless', {'enemy': enemyName, 'weapon': weaponName})}",
      );
      _grantLoot(scav, manager, timeStr, isPoiCombat, poiTier, daysPassed);
      return;
    }

    int enemyHit = EngineHelpers.rollStat(eMin, eMax);
    int damageTaken = max(0, enemyHit - armorDR);
    scav.hp = max(0, scav.hp - damageTaken);

    _checkHealthAndMedkit(scav, timeStr);
    if (scav.state == ScavState.dead) return;

    int secondHit = EngineHelpers.rollStat(pMin, pMax);
    enemyHp -= secondHit;
    if (enemyHp <= 0) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'messy', {'enemy': enemyName, 'weapon': weaponName, 'damage': damageTaken.toString()})}",
      );
      _grantLoot(scav, manager, timeStr, isPoiCombat, poiTier, daysPassed);
    } else {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.combatLogs, 'flee', {'enemy': enemyName, 'damage': damageTaken.toString()})}",
      );
    }
  }

  static void _checkHealthAndMedkit(Scavenger scav, String timeStr) {
    if (scav.consumeMedkit()) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'auto_heal', {'item': 'Medkit'})}",
      );
    }
    if (scav.hp <= 0) {
      scav.state = ScavState.dead;
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'trap_fatal', {})}",
      );
    }
  }

  static void _grantLoot(
    Scavenger scav,
    GameManager manager,
    String timeStr,
    bool isPoiCombat,
    int poiTier,
    int daysPassed,
  ) {
    if (isPoiCombat) {
      LootEngine.generateDynamicLoot(scav, timeStr, poiTier, daysPassed);
    } else {
      LootEngine.generateLoot(scav, timeStr);
    }
  }

  static void handleNPCEncounter(
    Scavenger scav,
    GameManager manager,
    String timeStr,
  ) {
    int roll = EngineHelpers.rollStat(0, 99);

    if (roll < 30) {
      if (manager.caps >= 20 && scav.hp < scav.maxHp) {
        manager.caps -= 20;
        int healAmount = scav.maxHp ~/ 2;
        scav.hp = min(scav.maxHp, scav.hp + healAmount);
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_doctor_success', {'healAmount': healAmount.toString()})}",
        );
      } else {
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_doctor_fail', {})}",
        );
      }
    } else if (roll < 60) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_neutral', {})}",
      );
    } else if (roll < 85) {
      int lostCaps = min(manager.caps, EngineHelpers.rollStat(15, 34));
      if (lostCaps > 0) {
        manager.caps -= lostCaps;
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_scam_success', {'lostCaps': lostCaps.toString()})}",
        );
      } else {
        scav.logs.add(
          "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_scam_fail', {})}",
        );
      }
    } else {
      int dmg = EngineHelpers.rollStat(5, 10);
      scav.hp -= dmg;
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'npc_mugging', {'damage': dmg.toString()})}",
      );
      _checkHealthAndMedkit(scav, timeStr);
    }
  }

  static void handleSurvivalAct(
    Scavenger scav,
    GameManager manager,
    String timeStr,
  ) {
    int roll = EngineHelpers.rollStat(0, 99);

    if (roll < 30) {
      int heal = 10;
      scav.hp = min(scav.maxHp, scav.hp + heal);
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'survival_rest', {'healAmount': heal.toString()})}",
      );
    } else if (roll < 60) {
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'survival_neutral', {})}",
      );
    } else {
      int dmg = EngineHelpers.rollStat(10, 20);
      scav.hp -= dmg;
      scav.logs.add(
        "$timeStr ${EngineHelpers.parseLog(IncidentDatabase.eventLogs, 'survival_hazard', {'damage': dmg.toString()})}",
      );
      _checkHealthAndMedkit(scav, timeStr);
    }
  }
}

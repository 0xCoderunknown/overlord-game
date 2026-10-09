import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/character_database.dart';
import '../content/item_database.dart';
import '../models/game_models.dart';
import '../utils/engine_helpers.dart';
import '../utils/game_config.dart';
import 'exploration_engine.dart';
import 'incident_handler.dart';

class GameManager extends ChangeNotifier with WidgetsBindingObserver {
  // --- THE NEW TIGHTENED ECONOMY ---
  int caps = 100;
  List<Scavenger> roster = [];
  List<Item> globalStash = [];

  VaultFacility medbay = VaultFacility(id: 'fac_medbay');

  DateTime? lastSavedTime;
  Timer? _gameTimer;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  GameManager() {
    WidgetsBinding.instance.addObserver(this);
    loadGame();
  }

  // ==========================================
  // INVISIBLE ONBOARDING
  // ==========================================
  void _injectStartingJonny() {
    Scavenger jonny = Scavenger(
      id: 'scav_jonny_01',
      name: 'Jonny',
      imagePath: 'assets/images/char/jonny.webp',
      hp: 100,
      maxHp: 100,
      stress: 0,
      state: ScavState.idle,
    );

    var wData = ItemDatabase.weapons.firstWhere((w) => w['id'] == 'w_stapler');
    Item starterWeapon = Item.fromDatabase(wData, generateUniqueId: true);

    var aData = ItemDatabase.armor.firstWhere((a) => a['id'] == 'a_phonebooks');
    Item starterArmor = Item.fromDatabase(aData, generateUniqueId: true);

    jonny.addItemToBackpack(starterWeapon);
    jonny.addItemToBackpack(starterArmor);

    roster.add(jonny);
  }

  // ==========================================
  // STASH LOGIC HELPERS
  // ==========================================
  int _getStashQuantity(String id) {
    var item = globalStash.where((i) => i.id == id).firstOrNull;
    return item?.quantity ?? 0;
  }

  void _removeStashQuantity(String id, int qty) {
    int idx = globalStash.indexWhere((i) => i.id == id);
    if (idx != -1) {
      globalStash[idx].quantity -= qty;
      if (globalStash[idx].quantity <= 0) {
        globalStash.removeAt(idx);
      }
    }
  }

  void addItemToStash(Item item, {bool generateNewId = false}) {
    if (item.isStackable) {
      int existingIndex = globalStash.indexWhere((i) => i.id == item.id);
      if (existingIndex != -1) {
        globalStash[existingIndex].quantity += item.quantity;
        return;
      }
    }

    if (generateNewId && !item.isStackable) {
      Item newItem = Item(
        id: "${item.id}_${DateTime.now().millisecondsSinceEpoch}",
        name: item.name,
        type: item.type,
        value: item.value,
        isStackable: item.isStackable,
        tier: item.tier,
        minStat: item.minStat,
        maxStat: item.maxStat,
        description: item.description,
        imagePath: item.imagePath,
        quantity: item.quantity,
      );
      globalStash.add(newItem);
    } else {
      globalStash.add(item);
    }
  }

  // ==========================================
  // FACILITY & CRAFTING LOGIC
  // ==========================================
  bool unlockMedbay() {
    if (caps >= GameConfig.medbayUnlockCost && !medbay.isUnlocked) {
      caps -= GameConfig.medbayUnlockCost;
      medbay.isUnlocked = true;
      notifyListeners();
      saveGame();
      return true;
    }
    return false;
  }

  bool startMedbayCrafting() {
    if (!medbay.isUnlocked || medbay.isCrafting || medbay.outputReady) {
      return false;
    }

    if (_getStashQuantity('med_syringe') >= 1 &&
        _getStashQuantity('med_herb') >= 2 &&
        _getStashQuantity('chem_expired') >= 1) {
      _removeStashQuantity('med_syringe', 1);
      _removeStashQuantity('med_herb', 2);
      _removeStashQuantity('chem_expired', 1);

      medbay.isCrafting = true;
      medbay.minutesRemaining = GameConfig.medbayCraftingTime;

      notifyListeners();
      saveGame();
      return true;
    }
    return false;
  }

  bool claimMedbayOutput() {
    if (!medbay.outputReady) return false;

    bool isExisting = globalStash.any((i) => i.id == 'c_medkit');
    if (!isExisting && globalStash.length >= GameConfig.maxStashSize) {
      return false;
    }

    var medkitData = ItemDatabase.consumables.firstWhere(
      (i) => i['id'] == 'c_medkit',
    );
    Item output = Item.fromDatabase(medkitData, quantity: 2);
    addItemToStash(output);

    medbay.outputReady = false;
    notifyListeners();
    saveGame();
    return true;
  }

  // ==========================================
  // ECONOMY & RECRUITMENT LOGIC
  // ==========================================
  bool buyItem(Item item) {
    if (caps < item.value) return false;

    bool isExistingStack =
        item.isStackable && globalStash.any((i) => i.id == item.id);
    if (!isExistingStack && globalStash.length >= GameConfig.maxStashSize) {
      return false;
    }

    caps -= item.value;
    addItemToStash(item, generateNewId: true);

    notifyListeners();
    saveGame();
    return true;
  }

  void sellItem(Item item, {bool sellEntireStack = false}) {
    if (!globalStash.contains(item)) return;
    if (sellEntireStack || !item.isStackable) {
      int totalValue = item.value * item.quantity;
      caps += totalValue;
      globalStash.remove(item);
    } else {
      caps += item.value;
      item.quantity--;

      if (item.quantity <= 0) {
        globalStash.remove(item);
      }
    }

    notifyListeners();
    saveGame();
  }

  // ==========================================
  // CONSUMABLES & FOOD
  // ==========================================
  void consumeItem(
    Scavenger scavenger,
    Item item, {
    required bool isFromStash,
  }) {
    String timeStr = EngineHelpers.getRealTimeStr();

    if (scavenger.hiddenTrait == 'paranoid' &&
        scavenger.stress >= 80 &&
        (item.type == 'consumable' || item.id == 'c_medkit')) {
      scavenger.logs.add(
        "$timeStr [WARNING] Subject is experiencing severe paranoia. Violently refused chemical injection.",
      );
      notifyListeners();
      return;
    }

    if (item.type == 'consumable' || item.id == 'c_medkit') {
      int healAmount = scavenger.maxHp ~/ 2;
      scavenger.hp = min(scavenger.maxHp, scavenger.hp + healAmount);
      scavenger.logs.add(
        "$timeStr [MANUAL] Injected ${item.name}. Vitals stabilized (+$healAmount HP).",
      );
    } else if (item.type == 'food') {
      int minS = item.minStat ?? -10;
      int maxS = item.maxStat ?? 20;
      int outcome = EngineHelpers.rollStat(minS, maxS);

      if (outcome < 0) {
        int damage = outcome.abs();
        scavenger.hp = max(0, scavenger.hp - damage);
        scavenger.logs.add(
          "$timeStr [SICK] That ${item.name} was rancid! Lost $damage HP.",
        );

        if (scavenger.hp <= 0) {
          scavenger.state = ScavState.dead;
          scavenger.logs.add(
            "$timeStr [FATAL] Succumbed to severe food poisoning.",
          );
        }
      } else if (outcome > 0) {
        scavenger.hp = min(scavenger.maxHp, scavenger.hp + outcome);
        scavenger.logs.add(
          "$timeStr [MANUAL] Ate ${item.name}. Fills the stomach (+$outcome HP).",
        );
      } else {
        scavenger.logs.add(
          "$timeStr [MANUAL] Ate ${item.name}. Tasted like ash. No effect.",
        );
      }
    }

    if (isFromStash) {
      _removeStashQuantity(item.id, 1);
    } else {
      int packIndex = scavenger.backpack.indexWhere((i) => i.id == item.id);
      if (packIndex != -1) {
        scavenger.backpack[packIndex].quantity--;
        if (scavenger.backpack[packIndex].quantity <= 0) {
          scavenger.backpack.removeAt(packIndex);
        }
      }
    }

    notifyListeners();
    saveGame();
  }

  bool hireScavenger(Map<String, dynamic> template) {
    int cost = template['cost'] as int;
    if (caps >= cost) {
      caps -= cost;
      roster.add(CharacterDatabase.generateFromTemplate(template));
      notifyListeners();
      saveGame();
      return true;
    }
    return false;
  }

  void hardResetGame() {
    caps = 100;
    roster.clear();
    globalStash.clear();
    medbay = VaultFacility(id: 'fac_medbay');

    _injectStartingJonny();

    saveGame();
    notifyListeners();
  }

  // ==========================================
  // APP LIFECYCLE & SAVING
  // ==========================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _gameTimer?.cancel();
      saveGame();
    } else if (state == AppLifecycleState.resumed) {
      if (lastSavedTime != null) {
        processOfflineProgress(DateTime.now());
      }
      startGameLoop();
    }
  }

  Future<void> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saveData = prefs.getString('overseer_save_data');
    if (saveData != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(saveData);
        caps = data['caps'] as int? ?? 100;
        if (data['lastSavedTime'] != null) {
          lastSavedTime = DateTime.parse(data['lastSavedTime']);
        }
        if (data['roster'] != null) {
          roster = (data['roster'] as List<dynamic>)
              .map((e) => Scavenger.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (data['medbay'] != null) {
          medbay = VaultFacility.fromJson(
            data['medbay'] as Map<String, dynamic>,
          );
        }

        if (data['globalStash'] != null) {
          globalStash = (data['globalStash'] as List<dynamic>)
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        if (roster.isEmpty) {
          _injectStartingJonny();
          saveGame();
        }

        if (lastSavedTime != null) {
          processOfflineProgress(DateTime.now());
        }
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading game: $e");
        if (roster.isEmpty) _injectStartingJonny();
      }
    } else {
      _injectStartingJonny();
      saveGame();
      notifyListeners();
    }
    if (_isDisposed) return;
    startGameLoop();
  }

  void stopGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void startGameLoop() {
    if (_isDisposed) return;
    if (_gameTimer != null && _gameTimer!.isActive) return;

    _gameTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      bool isCurrentlyBackground =
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;

      if (lastSavedTime != null) {
        int minutesPassed = DateTime.now().difference(lastSavedTime!).inMinutes;
        if (minutesPassed > 0) {
          minutesPassed = min(minutesPassed, GameConfig.maxOfflineMinutes);
          processTicks(
            minutesPassed,
            isOffline: minutesPassed > 1 || isCurrentlyBackground,
          );
        }
      } else {
        processTicks(1, isOffline: isCurrentlyBackground);
      }
    });
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    lastSavedTime = DateTime.now();
    final data = {
      'schemaVersion': 1,
      'caps': caps,
      'lastSavedTime': lastSavedTime!.toIso8601String(),
      'roster': roster.map((s) => s.toJson()).toList(),
      'medbay': medbay.toJson(),
      'globalStash': globalStash.map((i) => i.toJson()).toList(),
    };
    await prefs.setString('overseer_save_data', jsonEncode(data));
  }

  void processOfflineProgress(DateTime currentTime) {
    if (lastSavedTime == null) return;
    int minutesPassed = currentTime.difference(lastSavedTime!).inMinutes;
    if (minutesPassed > 0) {
      minutesPassed = min(minutesPassed, GameConfig.maxOfflineMinutes);
      processTicks(minutesPassed, isOffline: true);
      lastSavedTime = DateTime.now();
      saveGame();
    }
  }

  // ==========================================
  // ROSTER CONTROLS
  // ==========================================
  void reviveScavenger(Scavenger scavenger) {
    if (scavenger.state == ScavState.dead) {
      int capIndex = scavenger.backpack.indexWhere(
        (item) => item.id == 'loot_caps',
      );
      int scavCaps = 0;
      if (capIndex != -1) {
        scavCaps = scavenger.backpack[capIndex].quantity;
      }

      int calculatedFee = (scavCaps * 0.10).toInt();
      if (calculatedFee < GameConfig.minReviveCost) {
        calculatedFee = GameConfig.minReviveCost;
      }

      int reviveCost = scavCaps < calculatedFee ? scavCaps : calculatedFee;

      if (capIndex != -1 && reviveCost > 0) {
        scavenger.backpack[capIndex].quantity -= reviveCost;
        if (scavenger.backpack[capIndex].quantity <= 0) {
          scavenger.backpack.removeAt(capIndex);
        }
      }

      scavenger.hp = max(1, scavenger.maxHp ~/ 4);
      scavenger.stress = 0;
      scavenger.hiddenTrait = null;
      scavenger.state = ScavState.returning;
      scavenger.minutesToReturn = scavenger.minutesExplored ~/ 2;
      scavenger.pendingPoiId = null;

      scavenger.logs.add(
        "${EngineHelpers.getRealTimeStr()} [CARAVAN] Looted $reviveCost caps from pockets for trauma care. Staggering back to base. ETA: ${scavenger.formattedEta}.",
      );

      notifyListeners();
      saveGame();
    }
  }

  void sendToWasteland(Scavenger scavenger) {
    if (scavenger.state == ScavState.idle) {
      scavenger.state = ScavState.exploring;
      scavenger.logs.clear();

      scavenger.logs.add(
        "${EngineHelpers.getRealTimeStr()} Deployment authorized. Sent to wasteland.",
      );
      notifyListeners();
      saveGame();
    }
  }

  void devSendAllToWasteland() {
    String timeStr = EngineHelpers.getRealTimeStr();
    for (var scavenger in roster) {
      if (scavenger.state == ScavState.idle) {
        scavenger.state = ScavState.exploring;
        scavenger.hp = scavenger.maxHp;
        scavenger.stress = 0;
        scavenger.hiddenTrait = null;
        scavenger.logs.clear();
        scavenger.logs.add("$timeStr [System] Forced deployment initiated.");
      }
    }
    startGameLoop();
    notifyListeners();
    saveGame();
  }

  void devResetRoster() {
    hardResetGame();
  }

  void recallScavenger(Scavenger scavenger) {
    if (scavenger.state == ScavState.exploring) {
      scavenger.state = ScavState.returning;
      scavenger.minutesToReturn = scavenger.minutesExplored ~/ 2;
      // THE FIX: Converted raw minutes to formattedEta
      scavenger.logs.add(
        "${EngineHelpers.getRealTimeStr()} Recalled manually. Returning in ${scavenger.formattedEta}.",
      );
      notifyListeners();
      saveGame();
    }
  }

  void resolveManualEncounter(Scavenger scavenger, bool shouldBreach) {
    if (scavenger.state != ScavState.waitingForInput) return;
    String timeStr = EngineHelpers.getRealTimeStr();

    if (!shouldBreach) {
      scavenger.logs.add("$timeStr Skipped location. Resuming exploration.");
      scavenger.state = ScavState.exploring;
      scavenger.pendingPoiId = null;
    } else {
      scavenger.state = ScavState.exploring;
      IncidentHandler.handlePOIEncounter(
        scavenger,
        this,
        timeStr,
        isOffline: false,
        preSelectedPoiId: scavenger.pendingPoiId,
      );
      scavenger.pendingPoiId = null;
    }

    notifyListeners();
    saveGame();
  }

  void notifyStateChanged() {
    notifyListeners();
  }

  void equipItem(Scavenger scavenger, Item item, {required bool isFromStash}) {
    if (item.type == 'weapon') {
      if (scavenger.equippedWeapon != null) {
        if (isFromStash) {
          globalStash.add(scavenger.equippedWeapon!);
        } else {
          scavenger.backpack.add(scavenger.equippedWeapon!);
        }
      }
      scavenger.equippedWeapon = item;
    } else if (item.type == 'armor') {
      if (scavenger.equippedArmor != null) {
        if (isFromStash) {
          globalStash.add(scavenger.equippedArmor!);
        } else {
          scavenger.backpack.add(scavenger.equippedArmor!);
        }
      }
      scavenger.equippedArmor = item;
    }

    if (isFromStash) {
      globalStash.removeWhere((i) => i.id == item.id);
    } else {
      scavenger.backpack.removeWhere((i) => i.id == item.id);
    }

    notifyListeners();
    saveGame();
  }

  void unequipItem(Scavenger scavenger, String slotType) {
    if (slotType == 'weapon' && scavenger.equippedWeapon != null) {
      globalStash.add(scavenger.equippedWeapon!);
      scavenger.equippedWeapon = null;
    } else if (slotType == 'armor' && scavenger.equippedArmor != null) {
      globalStash.add(scavenger.equippedArmor!);
      scavenger.equippedArmor = null;
    }
    notifyListeners();
    saveGame();
  }

  bool moveItemStashToBackpack(Scavenger scavenger, Item item) {
    Item backpackItem = Item(
      id: item.id,
      name: item.name,
      type: item.type,
      value: item.value,
      isStackable: item.isStackable,
      quantity: 1,
      tier: item.tier,
      imagePath: item.imagePath,
      minStat: item.minStat,
      maxStat: item.maxStat,
      description: item.description,
    );
    if (scavenger.addItemToBackpack(backpackItem)) {
      item.quantity--;
      if (item.quantity <= 0) {
        globalStash.removeWhere((i) => i.id == item.id);
      }
      notifyListeners();
      saveGame();
      return true;
    }
    return false;
  }

  bool moveItemBackpackToStash(Scavenger scavenger, Item item) {
    bool isExistingStack =
        item.isStackable && globalStash.any((i) => i.id == item.id);
    if (!isExistingStack && globalStash.length >= GameConfig.maxStashSize) {
      return false;
    }

    Item stashItem = Item(
      id: item.id,
      name: item.name,
      type: item.type,
      value: item.value,
      isStackable: item.isStackable,
      quantity: 1,
      tier: item.tier,
      imagePath: item.imagePath,
      minStat: item.minStat,
      maxStat: item.maxStat,
      description: item.description,
    );
    int stashIndex = globalStash.indexWhere((i) => i.id == item.id);
    if (stashIndex != -1 && item.isStackable) {
      globalStash[stashIndex].quantity++;
    } else {
      globalStash.add(stashItem);
    }
    item.quantity--;
    if (item.quantity <= 0) {
      scavenger.backpack.removeWhere((i) => i.id == item.id);
    }
    notifyListeners();
    saveGame();
    return true;
  }

  // ==========================================
  // THE MASTER GAME LOOP
  // ==========================================
  void processTicks(int minutesPassed, {bool isOffline = false}) {
    ExplorationEngine.processTicks(this, minutesPassed, isOffline: isOffline);
    notifyListeners();
    saveGame();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _gameTimer = null;
    super.dispose();
  }
}

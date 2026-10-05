import 'dart:math';

import '../utils/engine_helpers.dart';
import '../utils/game_config.dart';

enum ScavState { idle, exploring, returning, waitingForInput, dead }

class Item {
  final String id;
  final String name;
  final int value;
  final bool isStackable;
  int quantity;
  final String type;
  final int tier;
  final int? minStat;
  final int? maxStat;
  final String? description;
  final String? imagePath;

  Item({
    required this.id,
    required this.name,
    this.value = 0,
    this.isStackable = false,
    this.quantity = 1,
    this.type = 'misc',
    this.tier = 1,
    this.minStat,
    this.maxStat,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'value': value,
    'isStackable': isStackable,
    'quantity': quantity,
    'type': type,
    'tier': tier,
    'minStat': minStat,
    'maxStat': maxStat,
    'description': description,
    'imagePath': imagePath,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    name: json['name'] as String,
    value: json['value'] as int? ?? 0,
    isStackable: json['isStackable'] as bool? ?? false,
    quantity: json['quantity'] as int? ?? 1,
    type: json['type'] as String? ?? 'misc',
    tier: json['tier'] as int? ?? 1,
    minStat: json['minStat'] as int?,
    maxStat: json['maxStat'] as int?,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
  );

  factory Item.fromDatabase(
    Map<String, dynamic> data, {
    int quantity = 1,
    bool generateUniqueId = false,
  }) {
    return Item(
      id: generateUniqueId
          ? "${data['id']}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000).toString().padLeft(3, '0')}"
          : data['id'],
      name: data['name'],
      type: data['type'] ?? 'misc',
      value: data['value'] ?? 0,
      isStackable: data['isStackable'] ?? false,
      quantity: quantity,
      tier: data['tier'] ?? 1,
      minStat: data['minStat'],
      maxStat: data['maxStat'],
      description: data['description'],
      imagePath: data['imagePath'],
    );
  }
}

class Scavenger {
  final String id;
  String name;
  String imagePath;
  int hp;
  int maxHp;
  int medkits;
  ScavState state;
  String? pendingPoiId;
  List<Item> backpack;
  Item? equippedWeapon;
  Item? equippedArmor;
  int minutesExplored;
  int minutesToReturn;
  List<String> logs;
  List<String> loreQueue;
  int stress;
  String? hiddenTrait;

  Scavenger({
    required this.id,
    required this.name,
    this.imagePath = 'assets/images/char/overseer.webp',
    this.hp = 100,
    this.maxHp = 100,
    this.medkits = 0,
    this.state = ScavState.idle,
    this.pendingPoiId,
    List<Item>? backpack,
    this.equippedWeapon,
    this.equippedArmor,
    this.minutesExplored = 0,
    this.minutesToReturn = 0,
    this.stress = 0,
    this.hiddenTrait,
    List<String>? logs,
    List<String>? loreQueue,
  }) : backpack = backpack ?? [],
       logs = logs ?? [],
       loreQueue = loreQueue ?? [];

  String get formattedDurationExplored =>
      EngineHelpers.formatDuration(minutesExplored);

  String get formattedEta => EngineHelpers.formatDuration(minutesToReturn);

  int get currentWeight => backpack.where((i) => i.id != 'loot_caps').length;

  bool consumeMedkit() {
    if (hp > 0 && hp <= (maxHp * 0.50)) {
      int medkitIndex = backpack.indexWhere((i) => i.id == 'c_medkit');
      if (medkitIndex != -1) {
        backpack[medkitIndex].quantity -= 1;
        if (backpack[medkitIndex].quantity <= 0) {
          backpack.removeAt(medkitIndex);
        }
        hp = min(maxHp, hp + (maxHp ~/ 2));
        return true;
      }
    }
    return false;
  }

  bool addItemToBackpack(Item newItem) {
    // ==========================================
    // 1. THE AUTO-EQUIP LOGIC
    // ==========================================
    if (newItem.type == 'weapon') {
      if (equippedWeapon == null) {
        equippedWeapon = newItem;
        logs.add("[AUTO-EQUIP] Equipped ${newItem.name}.");
        return true; // Item consumed as equipment, no backpack space used.
      } else {
        // Calculate average damage to determine if it's actually better
        double currentAvg =
            ((equippedWeapon!.minStat ?? 0) + (equippedWeapon!.maxStat ?? 0)) /
            2;
        double newAvg = ((newItem.minStat ?? 0) + (newItem.maxStat ?? 0)) / 2;

        if (newItem.tier > equippedWeapon!.tier ||
            (newItem.tier == equippedWeapon!.tier && newAvg > currentAvg)) {
          Item oldWeapon = equippedWeapon!;
          equippedWeapon = newItem;
          logs.add(
            "[AUTO-EQUIP] Swapped ${oldWeapon.name} for ${newItem.name}.",
          );
          newItem = oldWeapon; // The old weapon now tries to enter the backpack
        }
      }
    } else if (newItem.type == 'armor') {
      if (equippedArmor == null) {
        equippedArmor = newItem;
        logs.add("[AUTO-EQUIP] Donned ${newItem.name}.");
        return true;
      } else {
        int currentDR = equippedArmor!.minStat ?? 0;
        int newDR = newItem.minStat ?? 0;

        if (newItem.tier > equippedArmor!.tier ||
            (newItem.tier == equippedArmor!.tier && newDR > currentDR)) {
          Item oldArmor = equippedArmor!;
          equippedArmor = newItem;
          logs.add(
            "[AUTO-EQUIP] Swapped ${oldArmor.name} for ${newItem.name}.",
          );
          newItem = oldArmor; // The old armor now tries to enter the backpack
        }
      }
    }

    // ==========================================
    // 2. STANDARD BACKPACK LOGIC
    // ==========================================
    if (newItem.isStackable) {
      int existingIndex = backpack.indexWhere((i) => i.id == newItem.id);
      if (existingIndex != -1) {
        backpack[existingIndex].quantity += newItem.quantity;
        return true;
      }
    }

    // THE FIX: Changed limit from 15 to 10 to perfectly match your UI limits
    if (currentWeight < GameConfig.maxBackpackWeight ||
        newItem.id == 'loot_caps') {
      backpack.add(newItem);
      return true;
    } else {
      logs.add("[OVERCUMBERED] Backpack full. Dropped ${newItem.name}.");
      return false;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'hp': hp,
    'maxHp': maxHp,
    'medkits': medkits,
    'state': state.name,
    'pendingPoiId': pendingPoiId,
    'backpack': backpack.map((i) => i.toJson()).toList(),
    'equippedWeapon': equippedWeapon?.toJson(),
    'equippedArmor': equippedArmor?.toJson(),
    'minutesExplored': minutesExplored,
    'minutesToReturn': minutesToReturn,
    'logs': logs,
    'loreQueue': loreQueue,
    'stress': stress,
    'hiddenTrait': hiddenTrait,
  };

  factory Scavenger.fromJson(Map<String, dynamic> json) => Scavenger(
    id: json['id'] as String,
    name: json['name'] as String,
    imagePath:
        json['imagePath'] as String? ?? 'assets/images/char/overseer.webp',
    hp: json['hp'] as int? ?? 100,
    maxHp: json['maxHp'] as int? ?? 100,
    medkits: json['medkits'] as int? ?? 0,
    state: ScavState.values.firstWhere(
      (e) => e.name == json['state'],
      orElse: () => ScavState.idle,
    ),
    pendingPoiId: json['pendingPoiId'] as String?,
    backpack: (json['backpack'] as List<dynamic>?)
        ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList(),
    equippedWeapon: json['equippedWeapon'] != null
        ? Item.fromJson(json['equippedWeapon'] as Map<String, dynamic>)
        : null,
    equippedArmor: json['equippedArmor'] != null
        ? Item.fromJson(json['equippedArmor'] as Map<String, dynamic>)
        : null,
    minutesExplored: json['minutesExplored'] as int? ?? 0,
    minutesToReturn: json['minutesToReturn'] as int? ?? 0,
    logs: (json['logs'] as List<dynamic>?)?.map((e) => e as String).toList(),
    loreQueue: (json['loreQueue'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    stress: json['stress'] as int? ?? 0,
    hiddenTrait: json['hiddenTrait'] as String?,
  );
}

// ==========================================
// THE NEW VAULT FACILITY SYSTEM
// ==========================================
class VaultFacility {
  final String id;
  bool isUnlocked;
  bool isCrafting;
  int minutesRemaining;
  bool outputReady;

  VaultFacility({
    required this.id,
    this.isUnlocked = false,
    this.isCrafting = false,
    this.minutesRemaining = 0,
    this.outputReady = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'isCrafting': isCrafting,
    'minutesRemaining': minutesRemaining,
    'outputReady': outputReady,
  };

  factory VaultFacility.fromJson(Map<String, dynamic> json) => VaultFacility(
    id: json['id'] as String,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isCrafting: json['isCrafting'] as bool? ?? false,
    minutesRemaining: json['minutesRemaining'] as int? ?? 0,
    outputReady: json['outputReady'] as bool? ?? false,
  );
}

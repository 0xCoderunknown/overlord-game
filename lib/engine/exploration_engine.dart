import 'dart:math';

import '../content/lore_database.dart';
import '../models/game_models.dart';
import '../utils/engine_helpers.dart';
import '../utils/game_config.dart';
import 'game_manager.dart';
import 'incident_handler.dart';

class ExplorationEngine {
  static void processTicks(
    GameManager manager,
    int minutesPassed, {
    bool isOffline = false,
  }) {
    if (minutesPassed <= 0) return;

    for (int tick = 0; tick < minutesPassed; tick++) {
      String timeStr = EngineHelpers.getSimulationTimeStr(minutesPassed, tick);

      if (manager.medbay.isCrafting) {
        manager.medbay.minutesRemaining--;
        if (manager.medbay.minutesRemaining <= 0) {
          manager.medbay.isCrafting = false;
          manager.medbay.outputReady = true;
        }
      }

      for (var scavenger in manager.roster) {
        if (scavenger.state == ScavState.dead ||
            scavenger.state == ScavState.waitingForInput) {
          continue;
        }

        if (scavenger.state == ScavState.exploring) {
          scavenger.minutesExplored++;

          if (scavenger.minutesExplored % 60 == 0 && scavenger.stress < 100) {
            scavenger.stress += 1;
          }

          int globalRoll = EngineHelpers.rollStat(1, 100);

          if (globalRoll > 50) {
            if (scavenger.loreQueue.isNotEmpty) {
              String nextLore = scavenger.loreQueue.removeAt(0);
              scavenger.logs.add("$timeStr [Lore] $nextLore");
            } else {
              int splitRoll = EngineHelpers.rollStat(1, 100);

              if (splitRoll <= 50) {
                var entry =
                    passiveLore[EngineHelpers.rollIndex(passiveLore.length)];
                scavenger.logs.add("$timeStr [Lore] ${entry.first}");
                if (entry.length > 1) {
                  scavenger.loreQueue.addAll(entry.sublist(1));
                }
              } else {
                int actionRoll = EngineHelpers.rollStat(1, 100);

                if (actionRoll <= 40) {
                  IncidentHandler.handleCombatEncounter(
                    scavenger,
                    manager,
                    timeStr,
                    isOffline: isOffline,
                  );
                } else if (actionRoll <= 65) {
                  IncidentHandler.handleMinorEncounter(
                    scavenger,
                    manager,
                    timeStr,
                  );
                } else if (actionRoll <= 80) {
                  IncidentHandler.handleNPCEncounter(
                    scavenger,
                    manager,
                    timeStr,
                  );
                } else if (actionRoll <= 95) {
                  IncidentHandler.handleSurvivalAct(
                    scavenger,
                    manager,
                    timeStr,
                  );
                } else {
                  if (isOffline) {
                    IncidentHandler.handlePOIEncounter(
                      scavenger,
                      manager,
                      timeStr,
                      isOffline: true,
                    );
                  } else {
                    scavenger.state = ScavState.waitingForInput;
                    scavenger.pendingPoiId = IncidentHandler.preRollPOI(
                      scavenger.minutesExplored ~/ GameConfig.minutesPerDay,
                    );
                    scavenger.logs.add(
                      "$timeStr [SYSTEM] Found a barricaded structure. Waiting for Overseer directive.",
                    );
                  }
                }
              }
            }
          }

          int currentWeight = scavenger.backpack
              .where((i) => i.id != 'loot_caps')
              .length;

          if (scavenger.state == ScavState.exploring &&
              currentWeight >= GameConfig.maxBackpackWeight) {
            scavenger.state = ScavState.returning;
            scavenger.minutesToReturn = scavenger.minutesExplored ~/ 2;
            scavenger.logs.add(
              "$timeStr [SYSTEM] Backpack full! Automatically returning. ETA: ${scavenger.formattedEta}.",
            );
          }
        } else if (scavenger.state == ScavState.returning) {
          if (scavenger.minutesToReturn > 0) {
            scavenger.minutesToReturn--;
          }

          if (scavenger.minutesToReturn <= 0) {
            int incomingNewSlots = scavenger.backpack.where((item) {
              if (item.id == 'loot_caps') return false;
              if (item.isStackable &&
                  manager.globalStash.any(
                    (stashItem) => stashItem.id == item.id,
                  )) {
                return false;
              }
              return true;
            }).length;

            if (manager.globalStash.length + incomingNewSlots >
                GameConfig.maxStashSize) {
              if (scavenger.logs.isEmpty ||
                  !scavenger.logs.last.contains("Stash full")) {
                scavenger.logs.add(
                  "$timeStr [WARNING] Stash full! Clear space to let me in.",
                );
              }
              continue;
            }

            scavenger.state = ScavState.idle;
            int capsEarned = 0;

            for (var item in scavenger.backpack) {
              if (item.id == 'loot_caps') {
                manager.caps += item.quantity;
                capsEarned += item.quantity;
              } else {
                manager.addItemToStash(item);
              }
            }

            scavenger.backpack.clear();
            scavenger.minutesExplored = 0;
            scavenger.minutesToReturn = 0;

            scavenger.stress = 0;
            scavenger.hiddenTrait = null;

            if (capsEarned > 0) {
              scavenger.logs.add(
                "$timeStr [SYSTEM] Returned safely. Secured $capsEarned Caps. Hardware and materials stashed.",
              );
            } else {
              scavenger.logs.add(
                "$timeStr [SYSTEM] Returned safely. Hardware and materials stashed.",
              );
            }
          }
        } else if (scavenger.state == ScavState.idle) {
          scavenger.hp = min(scavenger.maxHp, scavenger.hp + 1);
        }
      }
    }

    for (var scavenger in manager.roster) {
      if (scavenger.logs.length > 60) {
        int overflow = scavenger.logs.length - 60;
        scavenger.logs.removeRange(0, overflow);
      }
    }
  }
}

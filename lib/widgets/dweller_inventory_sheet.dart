import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/game_config.dart';
import 'dweller_equipped_card.dart';
import 'dweller_item_inspect_dialog.dart';
import 'item_grid_card.dart';

const _kGearTypes = {'weapon', 'armor', 'consumable', 'food', 'material'};

class DwellerInventorySheet extends StatelessWidget {
  final Scavenger scavenger;

  const DwellerInventorySheet({super.key, required this.scavenger});

  void _openInspectDialog(
    BuildContext context,
    Item item,
    bool isFromStash,
    Scavenger liveScavenger,
    GameManager manager,
    StateSetter setModalState,
  ) {
    showDialog(
      context: context,
      builder: (_) => DwellerItemInspectDialog(
        item: item,
        isFromStash: isFromStash,
        scavenger: liveScavenger,
        manager: manager,
        onStateMutated: () => setModalState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        final manager = context.watch<GameManager>();
        final liveScavenger = manager.roster.firstWhere(
          (s) => s.id == scavenger.id,
          orElse: () => scavenger,
        );
        final stashGear = manager.globalStash
            .where((i) => _kGearTypes.contains(i.type))
            .toList();
        final displayBackpackItems = liveScavenger.backpack
            .where((i) => i.id != 'loot_caps')
            .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: AppTheme.bgDark,
            border: Border(
              top: BorderSide(color: AppTheme.green, width: 2),
              left: BorderSide(color: AppTheme.green, width: 2),
              right: BorderSide(color: AppTheme.green, width: 2),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "EQUIPMENT & STASH",
                  style: AppTheme.retroText(
                    color: AppTheme.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Divider(color: AppTheme.green, height: 1, thickness: 2),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppTheme.panelDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "[ EQUIPPED ]",
                              style: AppTheme.retroText(
                                color: AppTheme.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DwellerEquippedCard(
                                    scavenger: liveScavenger,
                                    manager: manager,
                                    slotType: "weapon",
                                    item: liveScavenger.equippedWeapon,
                                    onUnequip: () => setModalState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DwellerEquippedCard(
                                    scavenger: liveScavenger,
                                    manager: manager,
                                    slotType: "armor",
                                    item: liveScavenger.equippedArmor,
                                    onUnequip: () => setModalState(() {}),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: AppTheme.green,
                        height: 1,
                        thickness: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "[ BACKPACK ]",
                              style: AppTheme.retroText(
                                color: AppTheme.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${liveScavenger.currentWeight} / ${GameConfig.maxBackpackWeight}",
                              style: AppTheme.retroText(
                                color: AppTheme.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      displayBackpackItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                "NO LOOT ACQUIRED YET.",
                                style: AppTheme.retroText(
                                  color: AppTheme.terminalGreen,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: displayBackpackItems.length,
                              itemBuilder: (context, index) => ItemGridCard(
                                item: displayBackpackItems[index],
                                isEquipped:
                                    displayBackpackItems[index] ==
                                        liveScavenger.equippedWeapon ||
                                    displayBackpackItems[index] ==
                                        liveScavenger.equippedArmor,
                                onTap: () => _openInspectDialog(
                                  context,
                                  displayBackpackItems[index],
                                  false,
                                  liveScavenger,
                                  manager,
                                  setModalState,
                                ),
                              ),
                            ),
                      if (liveScavenger.state == ScavState.idle) ...[
                        const SizedBox(height: 16),
                        const Divider(
                          color: AppTheme.green,
                          height: 1,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "[ VAULT ARMORY ]",
                                style: AppTheme.retroText(
                                  color: AppTheme.warningYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${stashGear.length} ITEMS",
                                style: AppTheme.retroText(
                                  color: AppTheme.warningYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        stashGear.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  "NO GEAR IN STASH.",
                                  style: AppTheme.retroText(
                                    color: AppTheme.grey,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemCount: stashGear.length,
                                itemBuilder: (context, index) => ItemGridCard(
                                  item: stashGear[index],
                                  isEquipped:
                                      stashGear[index] ==
                                          liveScavenger.equippedWeapon ||
                                      stashGear[index] ==
                                          liveScavenger.equippedArmor,
                                  onTap: () => _openInspectDialog(
                                    context,
                                    stashGear[index],
                                    true,
                                    liveScavenger,
                                    manager,
                                    setModalState,
                                  ),
                                ),
                              ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

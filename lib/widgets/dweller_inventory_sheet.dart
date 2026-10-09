import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import 'dweller_item_inspect_dialog.dart';
import 'item_grid_card.dart';

class DwellerInventorySheet extends StatelessWidget {
  final Scavenger scavenger;

  const DwellerInventorySheet({super.key, required this.scavenger});

  Color _getItemColor(int tier) {
    switch (tier) {
      case 1:
        return AppTheme.grey;
      case 2:
        return AppTheme.blueAccent;
      case 3:
        return AppTheme.orangeAccent;
      default:
        return AppTheme.terminalGreen;
    }
  }

  IconData _getIconForType(String? type) {
    if (type == 'consumable' || type == 'food') return Icons.medical_services;
    if (type == 'armor') return Icons.security;
    if (type == 'scrap') return Icons.recycling;
    if (type == 'material') return Icons.science;
    return Icons.handyman;
  }

  Widget _buildEquippedCard(
    BuildContext context,
    Scavenger liveScavenger,
    GameManager manager,
    String slotType,
    Item? item,
    StateSetter setModalState,
  ) {
    if (item == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(
            color: AppTheme.green.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            "NO ${slotType.toUpperCase()}",
            style: AppTheme.retroText(
              color: AppTheme.green.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    String statText = item.type == 'weapon'
        ? "DMG: ${item.minStat}-${item.maxStat}"
        : "DR: ${item.minStat}";
    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    return InkWell(
      onTap: () {
        if (liveScavenger.state == ScavState.idle) {
          manager.unequipItem(liveScavenger, item.type);
          setModalState(() {});
        }
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(color: AppTheme.terminalGreen, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name.toUpperCase(),
              style: AppTheme.retroText(
                color: _getItemColor(item.tier),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getIconForType(item.type),
                    color: _getItemColor(item.tier).withValues(alpha: 0.8),
                    size: 40,
                  ),
                ),
              ),
            ),
            Text(
              statText,
              style: AppTheme.retroText(
                color: AppTheme.terminalGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (liveScavenger.state == ScavState.idle)
              Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                color: AppTheme.orangeAccent.withValues(alpha: 0.2),
                child: Text(
                  "TAP TO UNEQUIP",
                  style: AppTheme.retroText(
                    color: AppTheme.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
            .where(
              (i) =>
                  i.type == 'weapon' ||
                  i.type == 'armor' ||
                  i.type == 'consumable' ||
                  i.type == 'food' ||
                  i.type == 'material',
            )
            .toList();
        final displayBackpackItems = liveScavenger.backpack
            .where((i) => i.id != 'loot_caps')
            .toList();
        int trueWeight = displayBackpackItems.length;

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
                                  child: _buildEquippedCard(
                                    context,
                                    liveScavenger,
                                    manager,
                                    "weapon",
                                    liveScavenger.equippedWeapon,
                                    setModalState,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildEquippedCard(
                                    context,
                                    liveScavenger,
                                    manager,
                                    "armor",
                                    liveScavenger.equippedArmor,
                                    setModalState,
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
                              "$trueWeight / 10",
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

import 'package:flutter/material.dart';
import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import 'terminal_container.dart';

class DwellerItemInspectDialog extends StatefulWidget {
  final Item item;
  final bool isFromStash;
  final Scavenger scavenger;
  final GameManager manager;
  final VoidCallback onStateMutated;

  const DwellerItemInspectDialog({
    super.key,
    required this.item,
    required this.isFromStash,
    required this.scavenger,
    required this.manager,
    required this.onStateMutated,
  });

  @override
  State<DwellerItemInspectDialog> createState() => _DwellerItemInspectDialogState();
}

class _DwellerItemInspectDialogState extends State<DwellerItemInspectDialog> {
  bool _isInjecting = false;

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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scav = widget.scavenger;
    final manager = widget.manager;

    bool isLockedDown = !widget.isFromStash &&
        (scav.state == ScavState.returning || scav.state == ScavState.dead);

    String lockReason = scav.state == ScavState.dead
        ? "[ SUBJECT DECEASED ]"
        : "[ UNAVAILABLE EN ROUTE ]";

    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    return Dialog(
      backgroundColor: AppTheme.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: TerminalContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _getItemColor(item.tier),
                      width: 1,
                    ),
                    color: AppTheme.bgBlack,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      _getIconForType(item.type),
                      color: _getItemColor(item.tier),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.toUpperCase(),
                        style: AppTheme.retroText(
                          color: _getItemColor(item.tier),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "TIER ${item.tier} ${item.type.toUpperCase()}",
                        style: AppTheme.retroText(
                          color: AppTheme.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              item.description ?? "No description available.",
              style: AppTheme.retroText(
                color: AppTheme.green.shade300,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            if (item.type == 'consumable' || item.type == 'food') ...[
              Builder(
                builder: (context) {
                  bool needsHealing = scav.hp < scav.maxHp;
                  String btnLabel = item.type == 'food'
                      ? "[ CONSUME ]"
                      : "[ INJECT INSTANTLY ]";
                  String activeLabel = item.type == 'food'
                      ? "[ EATING... ]"
                      : "[ INJECTING... ]";

                  return ElevatedButton(
                    onPressed: (needsHealing && !_isInjecting && !isLockedDown)
                        ? () async {
                            setState(() => _isInjecting = true);
                            await Future.delayed(const Duration(seconds: 1));
                            manager.consumeItem(
                              scav,
                              item,
                              isFromStash: widget.isFromStash,
                            );
                            if (context.mounted && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            widget.onStateMutated();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: (needsHealing && !isLockedDown)
                            ? AppTheme.terminalGreen
                            : AppTheme.grey,
                        width: 2,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      isLockedDown
                          ? lockReason
                          : _isInjecting
                              ? activeLabel
                              : needsHealing
                                  ? btnLabel
                                  : "[ HP OPTIMAL ]",
                      style: AppTheme.retroText(
                        color: (needsHealing && !isLockedDown)
                            ? AppTheme.terminalGreen
                            : AppTheme.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (widget.isFromStash && scav.state == ScavState.idle)
                ElevatedButton(
                  onPressed: !_isInjecting
                      ? () {
                          if (manager.moveItemStashToBackpack(scav, item)) {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            widget.onStateMutated();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bgBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppTheme.warningYellow,
                      width: 2,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "[ MOVE 1 TO BACKPACK ]",
                    style: AppTheme.retroText(
                      color: AppTheme.warningYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              if (!widget.isFromStash && scav.state == ScavState.idle)
                ElevatedButton(
                  onPressed: !_isInjecting
                      ? () {
                          manager.moveItemBackpackToStash(scav, item);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          widget.onStateMutated();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bgBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppTheme.orangeAccent,
                      width: 2,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "[ RETURN 1 TO STASH ]",
                    style: AppTheme.retroText(
                      color: AppTheme.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ] else ...[
              ElevatedButton(
                onPressed: !isLockedDown
                    ? () {
                        manager.equipItem(
                          scav,
                          item,
                          isFromStash: widget.isFromStash,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        widget.onStateMutated();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bgBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: !isLockedDown
                        ? AppTheme.warningYellow
                        : AppTheme.grey,
                    width: 2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  isLockedDown ? lockReason : "[ EQUIP ]",
                  style: AppTheme.retroText(
                    color: !isLockedDown
                        ? AppTheme.warningYellow
                        : AppTheme.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

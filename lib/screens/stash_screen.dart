import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/game_config.dart';
import '../widgets/item_grid_card.dart'; // THE NEW IMPORT

class StashScreen extends StatelessWidget {
  const StashScreen({super.key});

  // Helpers kept exclusively for the Inspection Modal Header
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
    if (type == 'material') return Icons.science;
    return Icons.handyman;
  }

  // =========================================================================
  // THE DUAL-ACTION INSPECTION MODAL (Kept intact for Sell Logic)
  // =========================================================================
  void _showItemInspectionModal(BuildContext context, Item item) {
    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            // Recalculate values every time the state refreshes
            int currentQty = item.quantity;
            int singleValue = item.value;
            int bulkValue = singleValue * currentQty;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.panelDark,
                border: Border(
                  top: BorderSide(color: AppTheme.green, width: 2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getIconForType(item.type),
                              color: _getItemColor(item.tier),
                              size: 40,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
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
                            SizedBox(height: 4),
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
                  SizedBox(height: 20),

                  Text(
                    item.description ?? "Standard wasteland salvage.",
                    style: AppTheme.retroText(
                      color: AppTheme.green.shade300,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),

                  // SINGLE SELL BUTTON
                  if (item.isStackable && currentQty > 1) ...[
                    ElevatedButton(
                      onPressed: () {
                        // Sell just one and update the modal visually
                        modalContext.read<GameManager>().sellItem(
                          item,
                          sellEntireStack: false,
                        );
                        setLocalState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.bgBlack,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppTheme.orangeAccent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        "SELL 1 [ +$singleValue CAPS ]",
                        style: AppTheme.retroText(
                          color: AppTheme.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  // BULK SELL BUTTON
                  ElevatedButton(
                    onPressed: () {
                      // Sell the whole stack and close the modal since the item is gone
                      modalContext.read<GameManager>().sellItem(
                        item,
                        sellEntireStack: true,
                      );
                      Navigator.pop(modalContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.alertRed, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      currentQty > 1
                          ? "SELL ALL ($currentQty) [ +$bulkValue CAPS ]"
                          : "SELL [ +$singleValue CAPS ]",
                      style: AppTheme.retroText(
                        color: AppTheme.alertRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final gameManager = context.watch<GameManager>();
    final stash = gameManager.globalStash;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        iconTheme: const IconThemeData(color: AppTheme.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "VAULT STASH ",
              style: AppTheme.retroText(
                color: AppTheme.green,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              "${stash.length} / ${GameConfig.maxStashSize}",
              style: AppTheme.retroText(
                color: stash.length >= GameConfig.maxStashSize
                    ? AppTheme.alertRed
                    : AppTheme.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: stash.isEmpty
          ? Center(
              child: Text(
                "[ STASH IS EMPTY ]",
                style: AppTheme.retroText(
                  color: AppTheme.green,
                  letterSpacing: 2,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: stash.length,
              itemBuilder: (context, index) {
                // THE FIX: ONE LINE TO RULE THEM ALL
                return ItemGridCard(
                  item: stash[index],
                  onTap: () => _showItemInspectionModal(context, stash[index]),
                );
              },
            ),
    );
  }
}

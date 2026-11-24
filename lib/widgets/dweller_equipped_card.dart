import 'package:material_ui/material_ui.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class DwellerEquippedCard extends StatelessWidget {
  final Scavenger scavenger;
  final GameManager manager;
  final String slotType;
  final Item? item;
  final VoidCallback onUnequip;

  const DwellerEquippedCard({
    super.key,
    required this.scavenger,
    required this.manager,
    required this.slotType,
    required this.item,
    required this.onUnequip,
  });

  @override
  Widget build(BuildContext context) {
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

    final currentItem = item!;
    final statText = currentItem.type == 'weapon'
        ? "DMG: ${currentItem.minStat}-${currentItem.maxStat}"
        : "DR: ${currentItem.minStat}";
    final imagePath =
        currentItem.imagePath ?? 'assets/images/items/${currentItem.id}.png';
    final tierColor = AppTheme.getItemTierColor(currentItem.tier);

    return InkWell(
      onTap: () {
        if (scavenger.state == ScavState.idle) {
          manager.unequipItem(scavenger, currentItem.type);
          onUnequip();
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
              currentItem.name.toUpperCase(),
              style: AppTheme.retroText(
                color: tierColor,
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
                    AppTheme.getItemTypeIcon(currentItem.type),
                    color: tierColor.withValues(alpha: 0.8),
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
            if (scavenger.state == ScavState.idle)
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
}

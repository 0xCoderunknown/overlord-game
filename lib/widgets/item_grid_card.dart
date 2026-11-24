import 'package:material_ui/material_ui.dart';

import '../models/game_models.dart';
import '../utils/app_theme.dart';
import 'terminal_container.dart';

class ItemGridCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final bool isEquipped;

  const ItemGridCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isEquipped = false,
  });

  @override
  Widget build(BuildContext context) {
    Color itemColor = AppTheme.getItemTierColor(item.tier);
    String statText = "";
    if (item.type == 'consumable') {
      statText = "HEAL: 50%";
    } else if (item.type == 'food') {
      statText = "RANGE: ${item.minStat}/${item.maxStat}";
    } else if (item.type == 'weapon') {
      statText = "DMG: ${item.minStat}-${item.maxStat}";
    } else if (item.type == 'armor') {
      statText = "DR: ${item.minStat}";
    } else if (item.type == 'scrap') {
      statText = "VALUE: ${item.value}";
    } else if (item.type == 'material') {
      statText = "CRAFTING";
    }

    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    return InkWell(
      onTap: onTap,
      child: TerminalContainer(
        padding: const EdgeInsets.all(8),
        borderColor: isEquipped
            ? AppTheme.alertRed
            : itemColor.withValues(alpha: 0.5),
        borderWidth: isEquipped ? 2.0 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name.toUpperCase(),
              style: AppTheme.retroText(
                color: itemColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          AppTheme.getItemTypeIcon(item.type),
                          color: itemColor.withValues(alpha: 0.8),
                          size: 48,
                        );
                      },
                    ),
                  ),
                  if (item.isStackable && item.quantity > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        color: AppTheme.bgBlack,
                        child: Text(
                          "x${item.quantity}",
                          style: AppTheme.retroText(
                            color: itemColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (isEquipped)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        color: AppTheme.alertRed,
                        child: Text(
                          "EQ",
                          style: AppTheme.retroText(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              statText,
              style: AppTheme.retroText(
                color: AppTheme.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

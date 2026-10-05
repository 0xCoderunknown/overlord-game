import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../screens/dweller_screen.dart';
import '../utils/app_theme.dart';

class ScavengerListCard extends StatelessWidget {
  final Scavenger scavenger;

  const ScavengerListCard({super.key, required this.scavenger});

  @override
  Widget build(BuildContext context) {
    // UNIFIED STATUS LOGIC
    String statusText = "";
    Color statusColor = AppTheme.green;

    if (scavenger.state == ScavState.idle) {
      statusText = "IDLE / READY";
      statusColor = AppTheme.green[300]!;
    } else if (scavenger.state == ScavState.exploring) {
      statusText = "EXPLORING: ${scavenger.formattedDurationExplored}";
      statusColor = AppTheme.terminalGreen;
    } else if (scavenger.state == ScavState.returning) {
      statusText = "RETURNING: ETA ${scavenger.formattedEta}";
      statusColor = AppTheme.orangeAccent;
    } else if (scavenger.state == ScavState.waitingForInput) {
      statusText = "AWAITING ORDERS";
      statusColor = AppTheme.alertRed;
    } else if (scavenger.state == ScavState.dead) {
      statusText = "KIA";
      statusColor = AppTheme.red[900]!;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DwellerScreen(scavenger: scavenger),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(
            color: statusColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // MINI PORTRAIT
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: statusColor, width: 1),
                    color: AppTheme.bgBlack,
                  ),
                  child: Image.asset(
                    scavenger.imagePath, // NO MORE MANUAL NULL CHECKS!
                    fit: BoxFit.cover,
                    color: statusColor,
                    colorBlendMode: BlendMode.modulate,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: statusColor),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  scavenger.name.toUpperCase(),
                  style: AppTheme.retroText(
                    color: AppTheme.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              statusText,
              style: AppTheme.retroText(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

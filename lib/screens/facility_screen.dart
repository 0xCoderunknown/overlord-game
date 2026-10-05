import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/game_config.dart';

class FacilityScreen extends StatelessWidget {
  const FacilityScreen({super.key});

  // Helper to safely count items in the global stash
  int _getStashCount(GameManager manager, String itemId) {
    var item = manager.globalStash.where((i) => i.id == itemId).firstOrNull;
    return item?.quantity ?? 0;
  }

  // Helper to format the remaining minutes into H:M
  String _formatTime(int totalMinutes) {
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return "${h}H ${m.toString().padLeft(2, '0')}M";
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<GameManager>();
    final medbay = manager.medbay;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'VAULT FACILITIES',
          style: AppTheme.retroText(
            color: AppTheme.green,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.green),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "[ ENGINEERING DECK ]",
                style: AppTheme.retroText(
                  color: AppTheme.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 16),

              // =========================================================
              // THE MEDBAY WIDGET
              // =========================================================
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgBlack,
                  border: Border.all(
                    color: medbay.isUnlocked
                        ? AppTheme.green
                        : AppTheme.red[900]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: medbay.isUnlocked
                          ? AppTheme.green.withValues(alpha: 0.2)
                          : AppTheme.red[900]!.withValues(alpha: 0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "MEDICAL BAY",
                            style: AppTheme.retroText(
                              color: medbay.isUnlocked
                                  ? AppTheme.terminalGreen
                                  : AppTheme.alertRed,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            medbay.isUnlocked ? "LVL 1" : "OFFLINE",
                            style: AppTheme.retroText(
                              color: medbay.isUnlocked
                                  ? AppTheme.terminalGreen
                                  : AppTheme.alertRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // BODY CONTENT
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: medbay.isUnlocked
                          ? _buildUnlockedMedbay(context, manager, medbay)
                          : _buildLockedMedbay(context, manager),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // STATE 1: LOCKED MEDBAY
  // =========================================================
  Widget _buildLockedMedbay(BuildContext context, GameManager manager) {
    bool canAfford = manager.caps >= GameConfig.medbayUnlockCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, color: AppTheme.alertRed, size: 48),
        SizedBox(height: 16),
        Text(
          "Facility requires complete reconstruction. Restores the ability to synthesize Wasteland Medkits from raw chemical salvage.",
          textAlign: TextAlign.center,
          style: AppTheme.retroText(color: AppTheme.grey, fontSize: 14),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: canAfford ? () => manager.unlockMedbay() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.bgBlack,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: BorderSide(
              color: canAfford ? AppTheme.warningYellow : AppTheme.grey[800]!,
              width: 2,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(
            canAfford
                ? "[ PAY 10,000 CAPS TO RESTORE ]"
                : "[ REQUIRES 10,000 CAPS ]",
            style: AppTheme.retroText(
              color: canAfford ? AppTheme.warningYellow : AppTheme.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STATE 2: ACTIVE MEDBAY
  // =========================================================
  Widget _buildUnlockedMedbay(
    BuildContext context,
    GameManager manager,
    VaultFacility medbay,
  ) {
    // Calculate current stock
    int syrCount = _getStashCount(manager, 'med_syringe');
    int herbCount = _getStashCount(manager, 'med_herb');
    int chemCount = _getStashCount(manager, 'chem_expired');

    // Check if player has enough for 1 batch
    bool hasSyringe = syrCount >= 1;
    bool hasHerb = herbCount >= 2;
    bool hasChem = chemCount >= 1;
    bool canCraft = hasSyringe && hasHerb && hasChem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "SYNTHESIS RECIPE: 2x MEDKIT",
          style: AppTheme.retroText(
            color: AppTheme.terminalGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),

        // THE RESOURCE LIST
        _buildResourceRow("Used Syringe", syrCount, 1, hasSyringe),
        SizedBox(height: 8),
        _buildResourceRow("Irradiated Herb", herbCount, 2, hasHerb),
        SizedBox(height: 8),
        _buildResourceRow("Expired Chemicals", chemCount, 1, hasChem),

        SizedBox(height: 24),
        const Divider(color: AppTheme.green, height: 1, thickness: 1),
        SizedBox(height: 24),

        // THE STATE MACHINE BUTTONS
        if (medbay.outputReady)
          ElevatedButton(
            onPressed: () => manager.claimMedbayOutput(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.warningYellow, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              "[ EXTRACT 2x MEDKITS ]",
              style: AppTheme.retroText(
                color: AppTheme.warningYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        else if (medbay.isCrafting)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "SYNTHESIZING... ETA: ${_formatTime(medbay.minutesRemaining)}",
                textAlign: TextAlign.center,
                style: AppTheme.retroText(
                  color: AppTheme.terminalGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: (240 - medbay.minutesRemaining) / 240,
                // 4 hours = 240 min
                backgroundColor: AppTheme.green[900],
                color: AppTheme.terminalGreen,
                minHeight: 12,
              ),
            ],
          )
        else
          ElevatedButton(
            onPressed: canCraft ? () => manager.startMedbayCrafting() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgBlack,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: canCraft ? AppTheme.terminalGreen : AppTheme.grey[800]!,
                width: 2,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              canCraft
                  ? "[ INITIATE SYNTHESIS (4H) ]"
                  : "[ INSUFFICIENT MATERIALS ]",
              style: AppTheme.retroText(
                color: canCraft ? AppTheme.terminalGreen : AppTheme.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  // Helper for the resource UI rows
  Widget _buildResourceRow(String name, int current, int required, bool isMet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "> $name",
          style: AppTheme.retroText(color: AppTheme.grey, fontSize: 14),
        ),
        Text(
          "[ $current / $required ]",
          style: AppTheme.retroText(
            color: isMet ? AppTheme.green : AppTheme.alertRed,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

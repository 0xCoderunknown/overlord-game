import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/item_database.dart';
import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../widgets/item_grid_card.dart';
import '../widgets/terminal_button.dart';
import '../widgets/terminal_container.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  // =========================================================================
  // THE INSPECTION MODAL
  // =========================================================================
  void _showItemInspectionModal(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      builder: (modalContext) {
        return TerminalContainer(
          padding: const EdgeInsets.all(20),
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
                        color: item.tier == 3
                            ? AppTheme.orangeAccent
                            : item.tier == 2
                            ? AppTheme.blueAccent
                            : AppTheme.grey,
                        width: 1,
                      ),
                      color: AppTheme.bgBlack,
                    ),
                    child: Image.asset(
                      item.imagePath ?? 'assets/images/items/${item.id}.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          item.type == 'consumable'
                              ? Icons.medical_services
                              : item.type == 'armor'
                              ? Icons.security
                              : Icons.handyman,
                          color: AppTheme.green,
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
                            color: item.tier == 3
                                ? AppTheme.orangeAccent
                                : item.tier == 2
                                ? AppTheme.blueAccent
                                : AppTheme.grey,
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
                item.description ?? "No description available.",
                style: AppTheme.retroText(
                  color: AppTheme.green.shade300,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgBlack,
                  border: Border.all(
                    color: AppTheme.alertRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item.type == 'consumable'
                      ? "RESTORES 50% MAX HP"
                      : item.type == 'weapon'
                      ? "BASE DAMAGE: ${item.minStat} to ${item.maxStat}"
                      : "DAMAGE REDUCTION (DR): ${item.minStat}",
                  style: AppTheme.retroText(
                    color: AppTheme.alertRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              TerminalButton(
                text: "REQUISITION [ ${item.value} CAPS ]",
                borderColor: AppTheme.warningYellow,
                textColor: AppTheme.warningYellow,
                onPressed: () {
                  bool success = modalContext.read<GameManager>().buyItem(item);
                  Navigator.pop(modalContext);

                  ScaffoldMessenger.of(context).clearSnackBars();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.green[900],
                        content: Text(
                          "> ACQUIRED: ${item.name.toUpperCase()}",
                          style: AppTheme.retroText(
                            color: AppTheme.terminalGreen,
                          ),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.red[900],
                        content: Text(
                          "> ERROR: INSUFFICIENT CAPS OR STASH FULL",
                          style: AppTheme.retroText(color: AppTheme.white),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // MAIN BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    int currentCaps = context.watch<GameManager>().caps;

    // We map the raw database maps into actual Item models on the fly!
    final availableWeapons = ItemDatabase.weapons
        .where((item) => item['isBuyable'] != false)
        .map((data) => Item.fromDatabase(data))
        .toList();

    final availableArmor = ItemDatabase.armor
        .where((item) => item['isBuyable'] != false)
        .map((data) => Item.fromDatabase(data))
        .toList();

    final availableConsumables = ItemDatabase.consumables
        .where((item) => item['isBuyable'] != false)
        .map((data) => Item.fromDatabase(data))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(
          backgroundColor: AppTheme.bgDark,
          iconTheme: const IconThemeData(color: AppTheme.green),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "EXCHANGE",
                style: AppTheme.retroText(
                  color: AppTheme.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                "CAPS: $currentCaps",
                style: AppTheme.retroText(
                  color: AppTheme.warningYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.warningYellow,
            indicatorWeight: 3,
            labelColor: AppTheme.warningYellow,
            unselectedLabelColor: AppTheme.green,
            labelStyle: AppTheme.retroText(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: const [
              Tab(text: "// WEAPONRY"),
              Tab(text: "// ARMOR & GEAR"),
              Tab(text: "// MEDICAL"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableWeapons.length,
              itemBuilder: (context, index) => ItemGridCard(
                item: availableWeapons[index],
                onTap: () =>
                    _showItemInspectionModal(context, availableWeapons[index]),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableArmor.length,
              itemBuilder: (context, index) => ItemGridCard(
                item: availableArmor[index],
                onTap: () =>
                    _showItemInspectionModal(context, availableArmor[index]),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableConsumables.length,
              itemBuilder: (context, index) => ItemGridCard(
                item: availableConsumables[index],
                onTap: () => _showItemInspectionModal(
                  context,
                  availableConsumables[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

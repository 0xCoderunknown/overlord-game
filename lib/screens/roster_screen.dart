import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../content/character_database.dart';
import '../engine/game_manager.dart';
import '../utils/app_theme.dart';
import '../widgets/scavenger_list_card.dart';
import '../widgets/terminal_container.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameManager = context.watch<GameManager>();
    final roster = gameManager.roster;
    final currentCaps = gameManager.caps;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        iconTheme: const IconThemeData(color: AppTheme.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "ROSTER & RECRUIT",
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- ACTIVE ROSTER SECTION ---
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "// ACTIVE PERSONNEL",
              style: AppTheme.retroText(
                color: AppTheme.green,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: roster.isEmpty
                ? Center(
                    child: Text(
                      "[ BASE IS EMPTY. HIRE A SCAVENGER. ]",
                      style: AppTheme.retroText(color: AppTheme.alertRed),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: roster.length,
                    itemBuilder: (context, index) => ScavengerListCard(
                      scavenger: roster[index],
                    ), // ONE LINE!
                  ),
          ),

          const Divider(color: AppTheme.green, height: 1, thickness: 2),

          // --- RECRUITMENT BOARD SECTION ---
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "// AVAILABLE CONTRACTS",
              style: AppTheme.retroText(
                color: AppTheme.green,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Builder(
              builder: (context) {
                final availableRecruits = CharacterDatabase.recruits
                    .where(
                      (recruit) => !roster.any(
                        (scav) => scav.id.startsWith(recruit['id']),
                      ),
                    )
                    .toList();

                if (availableRecruits.isEmpty) {
                  return Center(
                    child: Text(
                      "[ NO CONTRACTS AVAILABLE ]",
                      style: AppTheme.retroText(color: AppTheme.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableRecruits.length,
                  itemBuilder: (context, index) {
                    final recruit = availableRecruits[index];
                    final String recruitImagePath =
                        recruit['imagePath'] ??
                        'assets/images/char/overseer.webp';

                    return InkWell(
                      onTap: () =>
                          _showRecruitModal(context, recruit, recruitImagePath),
                      child: TerminalContainer(
                        padding: const EdgeInsets.all(8),
                        borderColor: AppTheme.green.withValues(alpha: 0.5),
                        borderWidth: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.terminalGreen,
                                      width: 1,
                                    ),
                                    color: AppTheme.bgBlack,
                                  ),
                                  child: Image.asset(
                                    recruitImagePath,
                                    fit: BoxFit.cover,
                                    color: AppTheme.terminalGreen,
                                    colorBlendMode: BlendMode.modulate,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.person,
                                          color: AppTheme.green,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  recruit['name'].toString().toUpperCase(),
                                  style: AppTheme.retroText(
                                    color: AppTheme.terminalGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "[ ${recruit['cost']} CAPS ]",
                              style: AppTheme.retroText(
                                color: AppTheme.warningYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRecruitModal(
    BuildContext context,
    Map<String, dynamic> recruit,
    String imagePath,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return TerminalContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.terminalGreen,
                        width: 1,
                      ),
                      color: AppTheme.bgBlack,
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      color: AppTheme.terminalGreen,
                      colorBlendMode: BlendMode.modulate,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.person, color: AppTheme.green, size: 40),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recruit['name'].toString().toUpperCase(),
                          style: AppTheme.retroText(
                            color: AppTheme.terminalGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "BASE HEALTH: ${recruit['maxHp']} HP",
                          style: AppTheme.retroText(
                            color: AppTheme.alertRed,
                            fontWeight: FontWeight.bold,
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
                "// DOSSIER",
                style: AppTheme.retroText(
                  color: AppTheme.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                recruit['description'],
                style: AppTheme.retroText(
                  color: AppTheme.green.shade300,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  bool success = modalContext.read<GameManager>().hireScavenger(
                    recruit,
                  );
                  if (success) {
                    Navigator.pop(modalContext);
                  } else {
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.red[900],
                        content: Text(
                          "> ERROR: INSUFFICIENT CAPS",
                          style: AppTheme.retroText(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.bgBlack,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppTheme.warningYellow, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  "[ AUTHORIZE CONTRACT : ${recruit['cost']} CAPS ]",
                  style: AppTheme.retroText(
                    color: AppTheme.warningYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

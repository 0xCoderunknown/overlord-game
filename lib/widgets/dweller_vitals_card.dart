import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/engine_helpers.dart';
import 'terminal_container.dart';

class DwellerVitalsCard extends StatelessWidget {
  final Scavenger scavenger;
  final bool isHallucinating;
  final Color baseColor;
  final Color terminalColor;

  const DwellerVitalsCard({
    super.key,
    required this.scavenger,
    required this.isHallucinating,
    required this.baseColor,
    required this.terminalColor,
  });

  Color _getStateColor(ScavState state) {
    if (isHallucinating) return terminalColor;
    switch (state) {
      case ScavState.exploring:
        return AppTheme.terminalGreen;
      case ScavState.waitingForInput:
        return AppTheme.red;
      case ScavState.returning:
        return AppTheme.orangeAccent;
      case ScavState.dead:
        return AppTheme.red900;
      case ScavState.idle:
        return AppTheme.green300;
    }
  }

  @override
  Widget build(BuildContext context) {
    int scavHP = scavenger.hp.clamp(0, scavenger.maxHp);
    int capsFound = scavenger.backpack
        .where((item) => item.id == 'loot_caps')
        .fold(0, (sum, item) => sum + item.quantity);
    int trueWeight = scavenger.backpack
        .where((item) => item.id != 'loot_caps')
        .length;

    String displayName = isHallucinating
        ? EngineHelpers.corruptText(scavenger.name.toUpperCase())
        : scavenger.name.toUpperCase();

    return TerminalContainer(
      height: 130,
      borderColor: baseColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: baseColor, width: 2),
              ),
            ),
            child: ColorFiltered(
              colorFilter: isHallucinating
                  ? ColorFilter.mode(baseColor, BlendMode.modulate)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Image.asset(
                scavenger.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, color: baseColor, size: 50),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayName,
                        style: AppTheme.retroText(
                          color: terminalColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        isHallucinating ? "??" : '$scavHP / ${scavenger.maxHp}',
                        style: AppTheme.retroText(
                          color: baseColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(10, (index) {
                      double hpPercent = scavenger.maxHp > 0
                          ? scavenger.hp / scavenger.maxHp
                          : 0;
                      int filledBlocks = (hpPercent * 10).ceil();
                      bool isFilled = index < filledBlocks;

                      double blockHeight = isHallucinating
                          ? EngineHelpers.rollStat(6, 16).toDouble()
                          : 12.0;

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < 9 ? 2.0 : 0,
                          ),
                          height: blockHeight,
                          decoration: BoxDecoration(
                            color: isFilled
                                ? terminalColor
                                : baseColor.withValues(alpha: 0.3),
                            border: Border.all(
                              color: isFilled ? terminalColor : baseColor,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Text(
                    "> ${scavenger.state.name.toUpperCase()} [${scavenger.state == ScavState.returning ? scavenger.formattedEta : scavenger.formattedDurationExplored}]",
                    style: AppTheme.retroText(
                      color: _getStateColor(scavenger.state),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "BACKPACK:",
                        style: AppTheme.retroText(
                          fontWeight: FontWeight.w900,
                          color: baseColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$trueWeight/10",
                        style: AppTheme.retroText(
                          color: baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "CAPS:",
                        style: AppTheme.retroText(
                          fontWeight: FontWeight.w900,
                          color: isHallucinating
                              ? baseColor
                              : AppTheme.warningYellow,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$capsFound",
                        style: AppTheme.retroText(
                          color: isHallucinating
                              ? baseColor
                              : AppTheme.warningYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

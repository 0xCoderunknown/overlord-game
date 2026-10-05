import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/engine_helpers.dart';

class TerminalLogLine extends StatelessWidget {
  final String logText;
  final bool isHallucinating;
  final Color baseColor;
  final Color terminalColor;

  const TerminalLogLine({
    super.key,
    required this.logText,
    this.isHallucinating = false,
    required this.baseColor,
    required this.terminalColor,
  });

  // =========================================================================
  // THE MASTER COLOR REGISTRY
  // =========================================================================
  static final Map<String, Color> _tagThemeRegistry = {
    '[COMBAT]': AppTheme.alertRed,
    '[AMBUSH]': AppTheme.alertRed,
    '[FATAL]': AppTheme.alertRed,
    '[KIA]': AppTheme.alertRed,
    '[TRAP]': AppTheme.orangeAccent,
    '[WARNING]': AppTheme.orangeAccent,
    '[SICK]': AppTheme.orangeAccent,
    '[RETREAT]': AppTheme.orangeAccent,
    '[JACKPOT]': AppTheme.warningYellow,
    '[LUCKY]': AppTheme.warningYellow,
    '[CARAVAN]': AppTheme.warningYellow,
    '[NPC]': Colors.lightBlueAccent,
    '[SURVIVAL]': Colors.lightBlueAccent,
    '[STEALTH]': AppTheme.grey,
    '[SYSTEM]': AppTheme.grey,
    '[EVENT]': AppTheme.terminalGreen, // Restored!
    '[POI]': AppTheme.terminalGreen, // Restored!
  };

  @override
  Widget build(BuildContext context) {
    // UNIFIED SHADE: Used for timestamp and non-highlighted message text
    final Color unifiedShade = AppTheme.green.shade700;

    // 0. STRIP LORE ONLY (Event and POI are now kept)
    String cleanText = logText.replaceAll(
      RegExp(r'\[Lore\]\s*', caseSensitive: false),
      '',
    );

    // 1. EXTRACT TIMESTAMP
    int firstBracketEnd = cleanText.indexOf(']');
    String timestamp = "";
    String remainder = cleanText;

    if (firstBracketEnd != -1 && cleanText.startsWith('[')) {
      timestamp = cleanText.substring(0, firstBracketEnd + 1);
      remainder = cleanText.substring(firstBracketEnd + 1).trim();
    }

    // 2. EXTRACT EVENT TAG
    String possibleTag = "";
    Color tagColor = terminalColor;

    if (remainder.startsWith('[')) {
      int tagEnd = remainder.indexOf(']');
      if (tagEnd != -1) {
        possibleTag = remainder.substring(0, tagEnd + 1);
        String upperTag = possibleTag.toUpperCase();

        tagColor = _tagThemeRegistry[upperTag] ?? terminalColor;
        remainder = remainder.substring(tagEnd + 1).trim();
      }
    }

    if (isHallucinating) tagColor = terminalColor;

    // 3. HIGHLIGHT NUMBERS (Caps and Items Only. Damage/HP removed).
    List<TextSpan> messageSpans = [];

    // Regex looks for "15 caps" or the word "Medkit"
    final RegExp highlightRegex = RegExp(
      r'(\d+\s*caps?|\bMedkit\b)',
      caseSensitive: false,
    );

    remainder.splitMapJoin(
      highlightRegex,
      onMatch: (Match match) {
        String matchedText = match.group(0)!;
        Color matchColor = terminalColor;

        if (!isHallucinating) {
          if (matchedText.toLowerCase().contains('caps')) {
            matchColor = AppTheme.warningYellow;
          } else {
            matchColor = AppTheme.orangeAccent; // Color for Medkits/Items
          }
        }

        String finalText = isHallucinating
            ? EngineHelpers.corruptText(matchedText)
            : matchedText;
        messageSpans.add(
          TextSpan(
            text: finalText,
            style: AppTheme.retroText(
              color: matchColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        if (nonMatch.isNotEmpty) {
          String finalText = isHallucinating
              ? EngineHelpers.corruptText(nonMatch)
              : nonMatch;
          messageSpans.add(
            TextSpan(
              text: finalText,
              // THE FIX: All standard text defaults back to the unified shade
              style: AppTheme.retroText(
                color: isHallucinating ? terminalColor : unifiedShade,
              ),
            ),
          );
        }
        return '';
      },
    );

    // 4. HALLUCINATION CORRUPTION
    String finalTimestamp = isHallucinating
        ? EngineHelpers.corruptText(timestamp)
        : timestamp;
    String finalTag = isHallucinating
        ? EngineHelpers.corruptText(possibleTag)
        : possibleTag;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: AppTheme.retroText(fontSize: 13),
          children: [
            TextSpan(
              text: "> $finalTimestamp ",
              style: AppTheme.retroText(
                color: isHallucinating
                    ? baseColor.withValues(alpha: 0.6)
                    : unifiedShade,
              ),
            ),
            if (finalTag.isNotEmpty)
              TextSpan(
                text: "$finalTag ",
                style: AppTheme.retroText(
                  color: tagColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ...messageSpans,
          ],
        ),
      ),
    );
  }
}

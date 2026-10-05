import 'dart:math';

import 'game_config.dart';

class EngineHelpers {
  static final Random _random = Random();

  /// Safe RNG roller to prevent nextInt(0) crashes
  static int rollStat(int minVal, int maxVal) {
    if (minVal >= maxVal) return minVal;
    return minVal + _random.nextInt((maxVal - minVal) + 1);
  }

  /// Helper for percentage rolls (returns true if random 0-99 is less than chance)
  static bool rollPercent(int chance) {
    return _random.nextInt(100) < chance;
  }

  /// Helper to get a valid index from a list
  static int rollIndex(int length) {
    if (length <= 0) return 0;
    return _random.nextInt(length);
  }

  /// Centralized log parser that handles missing logs and tag replacement
  static String parseLog(
    Map<String, List<String>> database,
    String category,
    Map<String, String> vars,
  ) {
    if (!database.containsKey(category)) {
      return "[LOG CATEGORY MISSING: $category]";
    }

    List<String> logs = database[category]!;
    if (logs.isEmpty) return "[DATA CORRUPTED: $category]";

    String selectedLog = logs[_random.nextInt(logs.length)];
    vars.forEach((key, value) {
      selectedLog = selectedLog.replaceAll('{$key}', value);
    });

    return selectedLog;
  }

  // --- TIME FORMATTING HELPERS ---
  static String formatTimeStr(DateTime time) {
    int h = time.hour;
    int m = time.minute;
    String ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    String hh = h.toString().padLeft(2, '0');
    String mm = m.toString().padLeft(2, '0');
    return "[$hh:$mm $ampm]";
  }

  static String getRealTimeStr() => formatTimeStr(DateTime.now());

  static String getSimulationTimeStr(int totalTicks, int currentTick) {
    return formatTimeStr(
      DateTime.now().subtract(Duration(minutes: totalTicks - currentTick)),
    );
  }

  static String formatDuration(int totalMinutes) {
    int d = totalMinutes ~/ GameConfig.minutesPerDay;
    int h = (totalMinutes % GameConfig.minutesPerDay) ~/ 60;
    int m = totalMinutes % 60;

    if (d > 0) return "${d}D ${h}H ${m}M";
    if (h > 0) return "${h}H ${m}M";
    return "${m}M";
  }

  /// The Insanity Text Glitcher
  static String corruptText(String text) {
    const symbols = '¥§©ÄËÏÖÜß%&*{}[];<>/?!#';
    final result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == ' ' || char == '\n' || char == '>') {
        result.write(char);
      } else {
        result.write(
          rollPercent(25) ? symbols[_random.nextInt(symbols.length)] : char,
        );
      }
    }
    return result.toString();
  }
}

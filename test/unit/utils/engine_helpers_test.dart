import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/utils/app_theme.dart';
import 'package:overlord/utils/engine_helpers.dart';

void main() {
  group('EngineHelpers', () {
    tearDown(() {
      EngineHelpers.resetRng();
    });

    test('rng getter exposes active seedable random instance', () {
      EngineHelpers.setRng(Random(999));
      final val1 = EngineHelpers.rng.nextInt(100);

      EngineHelpers.setRng(Random(999));
      final val2 = EngineHelpers.rng.nextInt(100);

      expect(val1, equals(val2));
    });

    test('rollStat produces values within bounds', () {
      for (int i = 0; i < 100; i++) {
        final result = EngineHelpers.rollStat(5, 10);
        expect(result, greaterThanOrEqualTo(5));
        expect(result, lessThanOrEqualTo(10));
      }
    });

    test('rollStat returns minVal when minVal >= maxVal', () {
      expect(EngineHelpers.rollStat(10, 5), equals(10));
      expect(EngineHelpers.rollStat(7, 7), equals(7));
    });

    test('rollIndex returns 0 for empty or invalid lists', () {
      expect(EngineHelpers.rollIndex(0), equals(0));
      expect(EngineHelpers.rollIndex(-5), equals(0));
    });

    test('rollIndex returns valid indices', () {
      for (int i = 0; i < 50; i++) {
        final idx = EngineHelpers.rollIndex(5);
        expect(idx, greaterThanOrEqualTo(0));
        expect(idx, lessThan(5));
      }
    });

    test('deterministic RNG with setRng', () {
      EngineHelpers.setRng(Random(12345));
      final rollA = EngineHelpers.rollStat(1, 100);

      EngineHelpers.setRng(Random(12345));
      final rollB = EngineHelpers.rollStat(1, 100);

      expect(rollA, equals(rollB));
    });

    test('parseLog handles placeholders and missing keys', () {
      final db = {
        'test_category': ['Found {amount} caps at {place}.'],
      };

      final parsed = EngineHelpers.parseLog(db, 'test_category', {
        'amount': '50',
        'place': 'Vault 42',
      });
      expect(parsed, equals('Found 50 caps at Vault 42.'));

      final missing = EngineHelpers.parseLog(db, 'non_existent', {});
      expect(missing, contains('LOG CATEGORY MISSING'));
    });

    test('formatDuration formats days, hours, and minutes correctly', () {
      expect(EngineHelpers.formatDuration(45), equals('45M'));
      expect(EngineHelpers.formatDuration(90), equals('1H 30M'));
      expect(EngineHelpers.formatDuration(1500), equals('1D 1H 0M'));
    });

    test('corruptText preserves spaces, newlines, and arrows', () {
      const text = 'HELLO WORLD > TEST\nNEXT';
      final corrupted = EngineHelpers.corruptText(text);

      expect(corrupted.contains(' '), isTrue);
      expect(corrupted.contains('\n'), isTrue);
      expect(corrupted.contains('>'), isTrue);
      expect(corrupted.length, equals(text.length));
    });
  });

  group('AppTheme visual tokens', () {
    test('getItemTierColor maps tiers accurately to terminal palette', () {
      expect(AppTheme.getItemTierColor(1), equals(AppTheme.grey));
      expect(AppTheme.getItemTierColor(2), equals(AppTheme.blueAccent));
      expect(AppTheme.getItemTierColor(3), equals(AppTheme.orangeAccent));
      expect(AppTheme.getItemTierColor(0), equals(AppTheme.terminalGreen));
    });

    test('getItemTypeIcon maps item categories accurately', () {
      expect(
        AppTheme.getItemTypeIcon('consumable'),
        equals(Icons.medical_services),
      );
      expect(AppTheme.getItemTypeIcon('food'), equals(Icons.medical_services));
      expect(AppTheme.getItemTypeIcon('armor'), equals(Icons.security));
      expect(AppTheme.getItemTypeIcon('scrap'), equals(Icons.recycling));
      expect(AppTheme.getItemTypeIcon('material'), equals(Icons.science));
      expect(AppTheme.getItemTypeIcon('weapon'), equals(Icons.handyman));
    });
  });
}

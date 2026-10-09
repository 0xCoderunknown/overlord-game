import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/utils/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Offline Simulation & Lifecycle', () {
    test('processOfflineProgress clamps minutes passed to maxOfflineMinutes (4320)', () {
      final manager = GameManager();
      // Simulate last saved 10 days ago (14,400 minutes)
      manager.lastSavedTime = DateTime.now().subtract(const Duration(days: 10));

      final scav = Scavenger(
        id: 'scav_1',
        name: 'Offline Explorer',
        hp: 100,
        maxHp: 100,
        state: ScavState.exploring,
      );
      manager.roster = [scav];

      manager.processOfflineProgress(DateTime.now());

      // Should not simulate 10 days; must be clamped to 4320 minutes (3 days)
      expect(scav.minutesExplored, lessThanOrEqualTo(GameConfig.maxOfflineMinutes));
    });

    test('resolveManualEncounter with shouldBreach=false skips POI and resumes exploring', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Cautious Explorer',
        state: ScavState.waitingForInput,
        pendingPoiId: 'poi_hospital',
      );
      manager.roster = [scav];

      manager.resolveManualEncounter(scav, false);

      expect(scav.state, equals(ScavState.exploring));
      expect(scav.pendingPoiId, isNull);
      expect(scav.logs.last, contains('Skipped location'));
    });

    test('resolveManualEncounter with shouldBreach=true breaches POI', () {
      final manager = GameManager();
      final scav = Scavenger(
        id: 'scav_1',
        name: 'Brave Explorer',
        state: ScavState.waitingForInput,
        pendingPoiId: 'poi_kindergarten',
      );
      manager.roster = [scav];

      manager.resolveManualEncounter(scav, true);

      expect(scav.state, equals(ScavState.exploring));
      expect(scav.pendingPoiId, isNull);
      expect(scav.logs.any((l) => l.contains('[POI] Approaching')), isTrue);
    });

    test('didChangeAppLifecycleState pauses and resumes cleanly', () {
      final manager = GameManager();

      expect(() {
        manager.didChangeAppLifecycleState(AppLifecycleState.paused);
        manager.didChangeAppLifecycleState(AppLifecycleState.resumed);
      }, returnsNormally);
    });
  });
}

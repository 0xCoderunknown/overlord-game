import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/widgets/dweller_equipped_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DwellerEquippedCard renders placeholder when slot is empty', (
    WidgetTester tester,
  ) async {
    final manager = GameManager();
    manager.stopGameLoop();

    final testScav = Scavenger(id: 'scav_01', name: 'Test Dweller');

    await tester.pumpWidget(
      ChangeNotifierProvider<GameManager>.value(
        value: manager,
        child: MaterialApp(
          home: Scaffold(
            body: DwellerEquippedCard(
              scavenger: testScav,
              manager: manager,
              slotType: 'weapon',
              item: null,
              onUnequip: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('NO WEAPON'), findsOneWidget);

    manager.stopGameLoop();
    manager.dispose();
  });

  testWidgets(
    'DwellerEquippedCard renders item details and unequip button for idle dweller',
    (WidgetTester tester) async {
      final manager = GameManager();
      manager.stopGameLoop();

      final weapon = Item(
        id: 'w_test_revolver',
        name: 'Rusty Revolver',
        type: 'weapon',
        tier: 2,
        minStat: 8,
        maxStat: 14,
      );

      final testScav = Scavenger(
        id: 'scav_01',
        name: 'Test Dweller',
        state: ScavState.idle,
        equippedWeapon: weapon,
      );

      bool unequippedCalled = false;

      await tester.pumpWidget(
        ChangeNotifierProvider<GameManager>.value(
          value: manager,
          child: MaterialApp(
            home: Scaffold(
              body: DwellerEquippedCard(
                scavenger: testScav,
                manager: manager,
                slotType: 'weapon',
                item: weapon,
                onUnequip: () {
                  unequippedCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('RUSTY REVOLVER'), findsOneWidget);
      expect(find.text('DMG: 8-14'), findsOneWidget);
      expect(find.text('TAP TO UNEQUIP'), findsOneWidget);

      await tester.tap(find.text('TAP TO UNEQUIP'));
      await tester.pumpAndSettle();

      expect(unequippedCalled, isTrue);

      manager.stopGameLoop();
      manager.dispose();
    },
  );
}

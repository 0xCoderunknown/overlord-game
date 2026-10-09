import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/screens/facility_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FacilityScreen renders locked and offline state when medbay not unlocked', (WidgetTester tester) async {
    final manager = GameManager();
    manager.stopGameLoop();
    manager.medbay.isUnlocked = false;

    await tester.pumpWidget(
      ChangeNotifierProvider<GameManager>.value(
        value: manager,
        child: const MaterialApp(
          home: FacilityScreen(),
        ),
      ),
    );

    expect(find.text('VAULT FACILITIES'), findsOneWidget);
    expect(find.text('[ ENGINEERING DECK ]'), findsOneWidget);
    expect(find.text('MEDICAL BAY'), findsOneWidget);
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('[ REQUIRES 10,000 CAPS ]'), findsOneWidget);

    manager.stopGameLoop();
    manager.dispose();
  });

  testWidgets('FacilityScreen renders active state when medbay is unlocked', (WidgetTester tester) async {
    final manager = GameManager();
    manager.stopGameLoop();
    manager.medbay.isUnlocked = true;

    await tester.pumpWidget(
      ChangeNotifierProvider<GameManager>.value(
        value: manager,
        child: const MaterialApp(
          home: FacilityScreen(),
        ),
      ),
    );

    expect(find.text('LVL 1'), findsOneWidget);
    expect(find.text('SYNTHESIS RECIPE: 2x MEDKIT'), findsOneWidget);
    expect(find.text('[ INSUFFICIENT MATERIALS ]'), findsOneWidget);

    manager.stopGameLoop();
    manager.dispose();
  });
}

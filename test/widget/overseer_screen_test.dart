import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/screens/overseer_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('OverseerScreen renders command dashboard and treasury', (WidgetTester tester) async {
    final manager = GameManager();
    manager.stopGameLoop();
    manager.caps = 750;

    await tester.pumpWidget(
      ChangeNotifierProvider<GameManager>.value(
        value: manager,
        child: const MaterialApp(
          home: OverseerScreen(),
        ),
      ),
    );

    expect(find.text('COMMAND CENTER'), findsOneWidget);
    expect(find.text('[ ID: OVERSEER ]'), findsOneWidget);
    expect(find.text('TREASURY : 750 CAPS'), findsOneWidget);
    expect(find.text('[ROOMS]'), findsOneWidget);
    expect(find.text('[ROSTER]'), findsOneWidget);
    expect(find.text('[STASH]'), findsOneWidget);

    manager.stopGameLoop();
    manager.dispose();
  });
}

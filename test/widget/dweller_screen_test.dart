import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord/engine/game_manager.dart';
import 'package:overlord/models/game_models.dart';
import 'package:overlord/screens/dweller_screen.dart';
import 'package:overlord/widgets/terminal_log_line.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DwellerScreen renders vitals, live logs, and inventory button', (WidgetTester tester) async {
    final manager = GameManager();
    manager.stopGameLoop();

    final testDweller = Scavenger(
      id: 'scav_test_hero',
      name: 'Vance',
      hp: 85,
      maxHp: 100,
      state: ScavState.exploring,
      minutesExplored: 50,
      logs: ['[12:00 PM] Patrolling sector 4.'],
    );
    manager.roster = [testDweller];

    await tester.pumpWidget(
      ChangeNotifierProvider<GameManager>.value(
        value: manager,
        child: MaterialApp(
          home: DwellerScreen(scavenger: testDweller),
        ),
      ),
    );

    expect(find.text('DWELLER DETAIL'), findsOneWidget);
    expect(find.text('VANCE'), findsOneWidget);
    expect(find.text('85 / 100'), findsOneWidget);
    expect(find.text('[ INVENTORY ]'), findsOneWidget);
    expect(find.text('[ RECALL SCAV ]'), findsOneWidget);
    expect(find.byType(TerminalLogLine), findsOneWidget);

    manager.stopGameLoop();
    manager.dispose();
  });
}

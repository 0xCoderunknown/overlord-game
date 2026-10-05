import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:overlord/main.dart';
import 'package:overlord/engine/game_manager.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => GameManager(),
        child: const OverlordApp(),
      ),
    );

    expect(find.text('COMMAND CENTER'), findsOneWidget);
  });
}

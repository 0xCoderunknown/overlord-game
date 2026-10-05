import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'engine/game_manager.dart';
import 'screens/overseer_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameManager(),
      child: const OverlordApp(),
    ),
  );
}

class OverlordApp extends StatelessWidget {
  const OverlordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlord',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.grey[900],
        fontFamily: 'Courier',
        // Placeholder for monospace
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C2C2C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white54, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0A0A),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white38,
        ),
      ),
      home: const OverseerScreen(),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  // Core Palette
  static const Color terminalGreen = Colors.greenAccent;
  static const Color bgDark = Color(0xFF121212);
  static const Color bgBlack = Colors.black;
  static const Color alertRed = Colors.redAccent;
  static const Color warningYellow = Colors.yellowAccent;

  // Extended Palette mapped to original colors
  static const MaterialColor green = Colors.green;
  static const MaterialColor red = Colors.red;
  static const MaterialAccentColor orangeAccent = Colors.orangeAccent;
  static const MaterialColor grey = Colors.grey;
  static const MaterialAccentColor blueAccent = Colors.blueAccent;
  static const MaterialAccentColor lightBlueAccent = Colors.lightBlueAccent;
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
  static const Color panelDark = Color(0xFF0A0A0A);

  // Palettes with shades
  static final Color red900 = Colors.red[900]!;
  static final Color red400 = Colors.red[400]!;
  static final Color green300 = Colors.green[300]!;
  static final Color green900 = Colors.green[900]!;
  static final Color grey800 = Colors.grey[800]!;
  static final Color grey700 = Colors.grey[700]!;
  static final Color grey600 = Colors.grey[600]!;

  // Text Styles
  static TextStyle retroText({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      color: color ?? terminalGreen,
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.bold,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TerminalButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final double padding;

  const TerminalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.bgBlack,
        foregroundColor: textColor ?? AppTheme.white,
        padding: EdgeInsets.symmetric(vertical: padding),
        side: BorderSide(color: borderColor ?? AppTheme.green, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTheme.retroText(
          color: textColor ?? AppTheme.green,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

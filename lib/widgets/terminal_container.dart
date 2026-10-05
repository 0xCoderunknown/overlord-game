import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TerminalContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;
  final double? height;
  final double? width;

  const TerminalContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.borderWidth = 2.0,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.bgBlack,
        border: Border.all(
          color: borderColor ?? AppTheme.green,
          width: borderWidth,
        ),
      ),
      child: child,
    );
  }
}

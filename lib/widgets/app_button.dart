import 'package:flutter/material.dart';

// Shared pill-shaped button used across onboarding, menu, settings, dialogs
// and the tutorial. Every call site can reproduce its exact prior look via
// the style parameters below.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final double letterSpacing;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderWidth = 2,
    this.verticalPadding = 18,
    this.borderRadius = 14,
    this.fontSize = 16,
    this.letterSpacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor!, width: borderWidth),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: letterSpacing,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

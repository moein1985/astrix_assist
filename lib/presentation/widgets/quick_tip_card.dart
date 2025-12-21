import 'package:flutter/material.dart';

/// A quick tip card with lightbulb icon and colored background
class QuickTipCard extends StatelessWidget {
  final String tip;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;

  const QuickTipCard({
    super.key,
    required this.tip,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final brdColor = borderColor ?? colorScheme.primary.withValues(alpha: 0.3);
    final icnColor = iconColor ?? colorScheme.primary;
    final txtColor = textColor ?? colorScheme.onSurface.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brdColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: icnColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: txtColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
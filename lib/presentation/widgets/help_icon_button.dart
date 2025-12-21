import 'package:flutter/material.dart';

/// A help icon button that shows a dialog with information
class HelpIconButton extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const HelpIconButton({
    super.key,
    required this.title,
    required this.content,
    this.icon = Icons.help_outline,
    this.iconSize = 20,
    this.iconColor,
  });

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? colorScheme.onSurface.withOpacity(0.6),
      ),
      onPressed: () => _showHelpDialog(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'راهنما',
    );
  }
}
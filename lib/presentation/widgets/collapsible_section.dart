import 'package:flutter/material.dart';

/// A collapsible section widget for advanced options
class CollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? borderColor;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.initiallyExpanded = false,
    this.icon,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: widget.backgroundColor,
      shape: widget.borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.borderColor!, width: 1),
            )
          : null,
      child: Column(
        children: [
          ListTile(
            leading: widget.icon != null
                ? Icon(widget.icon, color: colorScheme.primary)
                : null,
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
            trailing: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
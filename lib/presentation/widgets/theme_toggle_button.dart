import 'package:flutter/material.dart';
import '../../core/theme_manager.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  void _toggle() {
    final current = ThemeManager.themeMode.value;
    if (current == ThemeMode.dark) {
      ThemeManager.update(ThemeMode.light);
    } else {
      ThemeManager.update(ThemeMode.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          tooltip: isDark ? 'Switch to light' : 'Switch to dark',
          onPressed: _toggle,
        );
      },
    );
  }
}

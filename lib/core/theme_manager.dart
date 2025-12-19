import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const _key = 'theme_mode';
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (stored == 'system') {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  static Future<void> update(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    String value = 'light';
    if (mode == ThemeMode.dark) {
      value = 'dark';
    } else if (mode == ThemeMode.system) {
      value = 'system';
    }
    await prefs.setString(_key, value);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager {
  static const String _localeKey = 'app_locale';
  static const String _localeInitKey = 'app_locale_initialized';
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en', ''));

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if this is first run - if so, set English as default
    final initialized = prefs.getBool(_localeInitKey) ?? false;
    if (!initialized) {
      await prefs.setString(_localeKey, 'en');
      await prefs.setBool(_localeInitKey, true);
      locale.value = const Locale('en', '');
      print('🌐 [Locale] First run - Setting English as default');
      return;
    }
    
    final languageCode = prefs.getString(_localeKey) ?? 'en';
    locale.value = Locale(languageCode, '');
    print('🌐 [Locale] Loaded: $languageCode');
  }

  static Future<void> setLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    locale.value = newLocale;
    print('🌐 [Locale] Changed to: ${newLocale.languageCode}');
  }
  
  /// Force reset to English (for debugging)
  static Future<void> resetToEnglish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, 'en');
    locale.value = const Locale('en', '');
  }

  static bool isFarsi() => locale.value.languageCode == 'fa';
  static bool isEnglish() => locale.value.languageCode == 'en';
}

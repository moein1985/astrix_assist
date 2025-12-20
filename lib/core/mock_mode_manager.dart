import 'package:shared_preferences/shared_preferences.dart';

class MockModeManager {
  static const String _mockModeKey = 'use_mock_mode';
  static bool _isMockMode = false;

  static bool get isMockMode => _isMockMode;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isMockMode = prefs.getBool(_mockModeKey) ?? false;
  }

  static Future<void> setMockMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mockModeKey, enabled);
    _isMockMode = enabled;
  }

  static Future<void> clearMockMode() async {
    await setMockMode(false);
  }
}

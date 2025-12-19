import 'package:shared_preferences/shared_preferences.dart';

class RefreshSettings {
  final bool enabled;
  final int intervalSeconds;

  const RefreshSettings({required this.enabled, required this.intervalSeconds});

  static const _enabledKey = 'auto_refresh_enabled';
  static const _intervalKey = 'auto_refresh_interval_seconds';
  static const defaultIntervalSeconds = 20;

  static Future<RefreshSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? true;
    final interval = prefs.getInt(_intervalKey) ?? defaultIntervalSeconds;
    return RefreshSettings(enabled: enabled, intervalSeconds: interval);
  }

  static Future<void> save(RefreshSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setInt(_intervalKey, settings.intervalSeconds);
  }
}

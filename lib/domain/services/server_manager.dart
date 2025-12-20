import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/server_config.dart';

class ServerManager {
  static const _serversKey = 'saved_servers';
  static const _activeServerKey = 'active_server_id';

  static Future<List<ServerConfig>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_serversKey) ?? [];
    return jsonList.map((json) => ServerConfig.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveServer(ServerConfig config) async {
    final servers = await loadServers();
    final existing = servers.indexWhere((s) => s.id == config.id);
    if (existing != -1) {
      servers[existing] = config;
    } else {
      servers.add(config);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_serversKey, servers.map((s) => jsonEncode(s.toJson())).toList());
  }

  static Future<void> deleteServer(String id) async {
    final servers = await loadServers();
    servers.removeWhere((s) => s.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_serversKey, servers.map((s) => jsonEncode(s.toJson())).toList());
    final active = prefs.getString(_activeServerKey);
    if (active == id) {
      await prefs.remove(_activeServerKey);
    }
  }

  static Future<String?> getActiveServerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeServerKey);
  }

  static Future<void> setActiveServer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeServerKey, id);
  }

  static Future<ServerConfig?> getActiveServer() async {
    final id = await getActiveServerId();
    if (id == null) return null;
    final servers = await loadServers();
    try {
      return servers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearActiveServer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeServerKey);
  }
}

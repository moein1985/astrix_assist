// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme_manager.dart';
import '../../core/locale_manager.dart';
import '../../core/background_service_manager.dart';
import '../../core/ssh_config.dart';
import '../../core/app_config.dart';
import '../../domain/services/server_manager.dart';
import '../widgets/theme_toggle_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentServerName;
  bool _notificationsEnabled = true;
  bool _backgroundServiceEnabled = false;
  SshConfig _sshConfig = SshConfig.defaultConfig;
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
    _loadNotificationSettings();
    _loadSshSettings();
  }

  Future<void> _loadCurrentServer() async {
    final activeId = await ServerManager.getActiveServerId();
    if (activeId != null) {
      final servers = await ServerManager.loadServers();
      try {
        final server = servers.firstWhere((s) => s.id == activeId);
        setState(() => _currentServerName = server.name);
      } catch (_) {}
    }
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _backgroundServiceEnabled =
          prefs.getBool('background_service_enabled') ?? false;
    });
  }

  Future<void> _loadSshSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final sshJson = prefs.getString('ssh_config');
    
    if (sshJson != null) {
      try {
        setState(() {
          _sshConfig = SshConfig.fromJson(
            Map<String, dynamic>.from(
              // Simple JSON parsing
              <String, dynamic>{
                'host': prefs.getString('ssh_host') ?? AppConfig.defaultSshHost,
                'port': prefs.getInt('ssh_port') ?? AppConfig.defaultSshPort,
                'username': prefs.getString('ssh_username') ?? AppConfig.defaultSshUsername,
                'authMethod': prefs.getString('ssh_auth_method') ?? 'password',
                'recordingsPath': prefs.getString('ssh_recordings_path') ?? AppConfig.defaultRecordingsPath,
              },
            ),
          );
        });
        
        // Load password from secure storage
        final password = await _secureStorage.read(key: 'ssh_password');
        if (password != null) {
          setState(() {
            _sshConfig = _sshConfig.copyWith(password: password);
          });
        }
      } catch (e) {
        // Use default if parsing fails
      }
    }
  }

  Future<void> _saveSshSettings(SshConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('ssh_host', config.host);
    await prefs.setInt('ssh_port', config.port);
    await prefs.setString('ssh_username', config.username);
    await prefs.setString('ssh_auth_method', config.authMethod);
    await prefs.setString('ssh_recordings_path', config.recordingsPath);
    
    // Save password securely
    if (config.password != null) {
      await _secureStorage.write(key: 'ssh_password', value: config.password);
    }
    
    setState(() {
      _sshConfig = config;
    });
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _setBackgroundServiceEnabled(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_service_enabled', value);
    setState(() => _backgroundServiceEnabled = value);

    if (value) {
      await BackgroundServiceManager().scheduleConnectionCheck();
      await BackgroundServiceManager().scheduleQueueStatusCheck();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backgroundServiceEnabled),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      await BackgroundServiceManager().cancelAllBackgroundTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.backgroundServiceDisabled),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          actions: const [ThemeToggleButton()],
        ),
        body: ListView(
          children: [
            const SizedBox(height: 8),
            // Language Section
            _buildSection(l10n.language),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(LocaleManager.isEnglish() ? l10n.currentLanguageEnglish : l10n.currentLanguagePersian),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(),
            ),
            const Divider(),
            
            // Server Section
            _buildSection(l10n.server),
            ListTile(
              leading: const Icon(Icons.dns),
              title: Text(l10n.currentServer),
              subtitle: Text(_currentServerName ?? l10n.noServerConnected),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangeServerDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.settings_remote),
              title: const Text('Server Setup (SSH + AMI)'),
              subtitle: const Text('Configure SSH and AMI settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/server-setup'),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: Text(
                l10n.disconnect,
                style: const TextStyle(color: Colors.orange),
              ),
              subtitle: Text(l10n.returnToServerSelection),
              onTap: () => _disconnectAndGoToLogin(),
            ),
            const Divider(),
            
            // SSH Settings Section (simplified - keep for recordings path)
            _buildSection('Recording Settings'),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Recordings Path'),
              subtitle: Text(_sshConfig.recordingsPath),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRecordingsPathDialog(),
            ),
            const Divider(),
            
            // Notifications Section
            _buildSection(l10n.notifications),
            SwitchListTile(
              title: Text(l10n.localNotifications),
              subtitle: Text(l10n.receiveNotificationsForEvents),
              value: _notificationsEnabled,
              onChanged: _setNotificationsEnabled,
            ),
            SwitchListTile(
              title: Text(l10n.backgroundService),
              subtitle: Text(l10n.checkServerStatusInBackground),
              value: _backgroundServiceEnabled,
              onChanged: _setBackgroundServiceEnabled,
            ),
            if (_backgroundServiceEnabled)
              ListTile(
                title: Text(l10n.information),
                subtitle: Text(l10n.queuesCheckedEvery5Minutes),
              ),
            const Divider(),
            
            // Display Section
            _buildSection(l10n.theme),
            ListTile(
              leading: Icon(
                ThemeManager.themeMode.value == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: Text(l10n.theme),
              subtitle: Text(
                ThemeManager.themeMode.value == ThemeMode.dark 
                  ? l10n.dark
                  : l10n.light,
              ),
              trailing: Switch(
                value: ThemeManager.themeMode.value == ThemeMode.dark,
                onChanged: (isDark) {
                  ThemeManager.update(isDark ? ThemeMode.dark : ThemeMode.light);
                  setState(() {});
                },
              ),
            ),
            const Divider(),
            
            // About Section
            _buildSection(l10n.about),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.version),
              subtitle: const Text('0.1.0'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Astrix Assist'),
              subtitle: Text(l10n.asteriskIssabelManagement),
              onTap: () => _showAboutDialog(),
            ),
            const Divider(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.englishLanguage),
                value: 'en',
                groupValue: LocaleManager.locale.value.languageCode,
                onChanged: (value) {
                  LocaleManager.setLocale(const Locale('en', ''));
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.persianLanguage),
                value: 'fa',
                groupValue: LocaleManager.locale.value.languageCode,
                onChanged: (value) {
                  LocaleManager.setLocale(const Locale('fa', ''));
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                // Clear active server
                await ServerManager.clearActiveServer();
                
                if (context.mounted) {
                  // Navigate to login page
                  Navigator.pop(context); // Close dialog
                  context.go('/');
                }
              },
              child: Text(
                l10n.logout,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeServerDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final servers = await ServerManager.loadServers();
    final isRTL = LocaleManager.isFarsi();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.selectServer),
          content: SizedBox(
            width: double.maxFinite,
            child: servers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noServersSaved),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      return ListTile(
                        leading: const Icon(Icons.dns),
                        title: Text(server.name),
                        subtitle: Text('${server.host}:${server.port}'),
                        onTap: () {
                          Navigator.pop(context);
                          _disconnectAndGoToLogin();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isRTL ? 'لغو' : 'Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _disconnectAndGoToLogin() {
    context.go('/');
  }

  void _showRecordingsPathDialog() {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();
    final pathController = TextEditingController(text: _sshConfig.recordingsPath);

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: const Text('Recordings Path'),
          content: TextField(
            controller: pathController,
            decoration: const InputDecoration(
              labelText: 'Path on server',
              prefixIcon: Icon(Icons.folder),
              helperText: 'Usually /var/spool/asterisk/monitor',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final newConfig = _sshConfig.copyWith(
                  recordingsPath: pathController.text,
                );
                await _saveSshSettings(newConfig);
                
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.saved),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showAboutDialog(
      context: context,
      applicationName: 'Astrix Assist',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.phone_in_talk, size: 48),
      children: [
        Text(l10n.manageAsteriskIssabelViaAMI),
        const SizedBox(height: 16),
        Text(l10n.features),
        Text(l10n.extensionsManagement),
        Text(l10n.activeCallsMonitoring),
        Text(l10n.queueManagement),
        Text(l10n.originateCalls),
      ],
    );
  }
}

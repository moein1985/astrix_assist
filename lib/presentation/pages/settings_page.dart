// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme_manager.dart';
import '../../core/locale_manager.dart';
import '../../core/background_service_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
    _loadNotificationSettings();
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
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: Text(
                l10n.disconnect,
                style: const TextStyle(color: Colors.orange),
              ),
              subtitle: Text(l10n.returnToServerSelection),
              onTap: () => _disconnectAndGoToLogin(),
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

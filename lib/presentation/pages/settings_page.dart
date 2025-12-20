import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme_manager.dart';
import '../../core/locale_manager.dart';
import '../../core/app_localizations.dart';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_service_enabled', value);
    setState(() => _backgroundServiceEnabled = value);

    if (value) {
      await BackgroundServiceManager().scheduleConnectionCheck();
      await BackgroundServiceManager().scheduleQueueStatusCheck();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سرویس پس‌زمینه فعال شد'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await BackgroundServiceManager().cancelAllBackgroundTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('سرویس پس‌زمینه غیرفعال شد'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRTL = LocaleManager.isFarsi();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.t('settings')),
          actions: const [ThemeToggleButton()],
        ),
        body: ListView(
          children: [
            const SizedBox(height: 8),
            // Language Section
            _buildSection(l10n.t('language')),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.t('language')),
              subtitle: Text(LocaleManager.isEnglish() ? 'English' : 'فارسی'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(),
            ),
            const Divider(),
            
            // Server Section
            _buildSection(isRTL ? 'سرور' : 'Server'),
            ListTile(
              leading: const Icon(Icons.dns),
              title: Text(isRTL ? 'سرور فعلی' : 'Current Server'),
              subtitle: Text(_currentServerName ?? (isRTL ? 'هیچ سروری متصل نیست' : 'No server connected')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangeServerDialog(),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: Text(
                isRTL ? 'قطع اتصال' : 'Disconnect',
                style: const TextStyle(color: Colors.orange),
              ),
              subtitle: Text(isRTL ? 'بازگشت به صفحه انتخاب سرور' : 'Return to server selection'),
              onTap: () => _disconnectAndGoToLogin(),
            ),
            const Divider(),
            
            // Notifications Section
            _buildSection(isRTL ? 'اطلاع‌رسانی' : 'Notifications'),
            SwitchListTile(
              title: Text(isRTL ? 'اطلاع‌رسانی‌های محلی' : 'Local Notifications'),
              subtitle: Text(isRTL ? 'دریافت اطلاع‌رسانی برای رویدادهای سیستم' : 'Receive notifications for system events'),
              value: _notificationsEnabled,
              onChanged: _setNotificationsEnabled,
            ),
            SwitchListTile(
              title: Text(isRTL ? 'سرویس پس‌زمینه' : 'Background Service'),
              subtitle: Text(isRTL ? 'بررسی وضعیت سرور در پس‌زمینه' : 'Check server status in background'),
              value: _backgroundServiceEnabled,
              onChanged: _setBackgroundServiceEnabled,
            ),
            if (_backgroundServiceEnabled)
              ListTile(
                title: Text(isRTL ? 'اطلاعات' : 'Information'),
                subtitle: Text(isRTL ? 'هر 5 دقیقه صف‌ها بررسی می‌شود' : 'Queues are checked every 5 minutes'),
              ),
            const Divider(),
            
            // Display Section
            _buildSection(l10n.t('theme')),
            ListTile(
              leading: Icon(
                ThemeManager.themeMode.value == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: Text(l10n.t('theme')),
              subtitle: Text(
                ThemeManager.themeMode.value == ThemeMode.dark 
                  ? l10n.t('dark')
                  : l10n.t('light'),
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
            
            // Reports Section
            _buildSection(isRTL ? 'گزارشات' : 'Reports'),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(isRTL ? 'تاریخچه تماس‌ها (CDR)' : 'Call History (CDR)'),
              subtitle: Text(isRTL ? 'مشاهده رکوردهای تماس' : 'View call records'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/cdr'),
            ),
            const Divider(),
            
            // About Section
            _buildSection(isRTL ? 'درباره برنامه' : 'About'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(isRTL ? 'نسخه' : 'Version'),
              subtitle: const Text('0.1.0'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Astrix Assist'),
              subtitle: Text(isRTL ? 'مدیریت سرورهای Asterisk/Issabel' : 'Asterisk/Issabel Management'),
              onTap: () => _showAboutDialog(),
            ),
            const Divider(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.t('logout')),
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
    final l10n = AppLocalizations.of(context);
    final isRTL = LocaleManager.isFarsi();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.t('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: LocaleManager.locale.value.languageCode,
                onChanged: (value) {
                  LocaleManager.setLocale(const Locale('en', ''));
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              RadioListTile<String>(
                title: const Text('فارسی'),
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
    final l10n = AppLocalizations.of(context);
    final isRTL = LocaleManager.isFarsi();
    
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.t('logout')),
          content: Text(l10n.t('logout_confirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.t('cancel')),
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
                l10n.t('logout'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeServerDialog() async {
    final servers = await ServerManager.loadServers();
    final isRTL = LocaleManager.isFarsi();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(isRTL ? 'انتخاب سرور' : 'Select Server'),
          content: SizedBox(
            width: double.maxFinite,
            child: servers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(isRTL ? 'هیچ سروری ذخیره نشده است' : 'No servers saved'),
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
    final isRTL = LocaleManager.isFarsi();
    
    showAboutDialog(
      context: context,
      applicationName: 'Astrix Assist',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.phone_in_talk, size: 48),
      children: [
        Text(isRTL 
          ? 'مدیریت سرورهای Asterisk و Issabel از طریق AMI'
          : 'Manage Asterisk and Issabel servers via AMI'),
        const SizedBox(height: 16),
        Text(isRTL ? 'ویژگی‌ها:' : 'Features:'),
        Text(isRTL ? '• مدیریت داخلی‌ها' : '• Extensions Management'),
        Text(isRTL ? '• مشاهده تماس‌های فعال' : '• Active Calls Monitoring'),
        Text(isRTL ? '• مدیریت صف‌ها' : '• Queue Management'),
        Text(isRTL ? '• برقراری تماس' : '• Originate Calls'),
      ],
    );
  }
}

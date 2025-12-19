import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme_manager.dart';
import '../../domain/services/server_manager.dart';
import '../widgets/theme_toggle_button.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentServerName;

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        actions: const [ThemeToggleButton()],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection('سرور'),
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('سرور فعلی'),
            subtitle: Text(_currentServerName ?? 'هیچ سروری متصل نیست'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangeServerDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('قطع اتصال'),
            subtitle: const Text('بازگشت به صفحه انتخاب سرور'),
            onTap: () => _disconnectAndGoToLogin(),
          ),
          const Divider(),
          _buildSection('نمایش'),
          ListTile(
            leading: Icon(
              ThemeManager.themeMode.value == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: const Text('تم'),
            subtitle: Text(
              ThemeManager.themeMode.value == ThemeMode.dark ? 'تیره' : 'روشن',
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
          _buildSection('درباره برنامه'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('نسخه'),
            subtitle: Text('0.1.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Astrix Assist'),
            subtitle: const Text('مدیریت سرورهای Asterisk/Issabel'),
            onTap: () => _showAboutDialog(),
          ),
        ],
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

  Future<void> _showChangeServerDialog() async {
    final servers = await ServerManager.loadServers();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتخاب سرور'),
        content: SizedBox(
          width: double.maxFinite,
          child: servers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('هیچ سروری ذخیره نشده است'),
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
            child: const Text('لغو'),
          ),
        ],
      ),
    );
  }

  void _disconnectAndGoToLogin() {
    context.go('/');
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Astrix Assist',
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.phone_in_talk, size: 48),
      children: [
        const Text('مدیریت سرورهای Asterisk و Issabel از طریق AMI'),
        const SizedBox(height: 16),
        const Text('ویژگی‌ها:'),
        const Text('• مدیریت داخلی‌ها'),
        const Text('• مشاهده تماس‌های فعال'),
        const Text('• مدیریت صف‌ها'),
        const Text('• برقراری تماس'),
      ],
    );
  }
}

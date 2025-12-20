import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/server_config.dart';
import '../../domain/services/server_manager.dart';
import '../widgets/theme_toggle_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<ServerConfig> _servers = [];
  ServerConfig? _selectedServer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    final servers = await ServerManager.loadServers();
    final activeId = await ServerManager.getActiveServerId();
    setState(() {
      _servers = servers;
      if (activeId != null) {
        try {
          _selectedServer = servers.firstWhere((s) => s.id == activeId);
        } catch (_) {}
      }
      _loading = false;
    });
  }

  Future<void> _connectToServer(ServerConfig config) async {
    await ServerManager.setActiveServer(config.id);
    if (!mounted) return;
    
    // Navigate to dashboard after connection
    if (mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _showAddEditDialog([ServerConfig? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final hostController = TextEditingController(text: existing?.host ?? '');
    final portController = TextEditingController(text: existing?.port.toString() ?? '5038');
    final userController = TextEditingController(text: existing?.username ?? '');
    final passController = TextEditingController(text: existing?.password ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'افزودن سرور جدید' : 'ویرایش سرور'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام سرور',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'نام الزامی است' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    labelText: 'آدرس IP',
                    prefixIcon: Icon(Icons.dns),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'آدرس IP الزامی است' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: 'پورت',
                    prefixIcon: Icon(Icons.settings_ethernet),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'پورت الزامی است' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: userController,
                  decoration: const InputDecoration(
                    labelText: 'نام کاربری',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'نام کاربری الزامی است' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passController,
                  decoration: const InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'رمز عبور الزامی است' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );

    if (result == true) {
      final config = ServerConfig(
        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        host: hostController.text,
        port: int.parse(portController.text),
        username: userController.text,
        password: passController.text,
      );
      await ServerManager.saveServer(config);
      _loadServers();
    }
  }

  Future<void> _deleteServer(ServerConfig config) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف سرور'),
        content: Text('آیا از حذف "${config.name}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ServerManager.deleteServer(config.id);
      _loadServers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  title: const Text('Astrix Assist'),
                  actions: const [ThemeToggleButton()],
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'سرورهای ذخیره شده',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            FilledButton.icon(
                              onPressed: () => _showAddEditDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('افزودن سرور'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_servers.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.dns_outlined, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'هیچ سروری ذخیره نشده',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'برای شروع یک سرور اضافه کنید',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...List.generate(_servers.length, (index) {
                            final server = _servers[index];
                            final isActive = _selectedServer?.id == server.id;
                            return Card(
                              elevation: isActive ? 4 : 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: IntrinsicHeight(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.blue : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.dns,
                                    color: isActive ? Colors.white : Colors.grey[600],
                                  ),
                                ),
                                title: Text(
                                  server.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.computer, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              '${server.host}:${server.port}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              server.username,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isActive) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                            const SizedBox(width: 4),
                                            Text('فعال', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showAddEditDialog(server),
                                        tooltip: 'ویرایش',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteServer(server),
                                        tooltip: 'حذف',
                                      ),
                                    ],
                                  ),
                                  onTap: () => _connectToServer(server),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
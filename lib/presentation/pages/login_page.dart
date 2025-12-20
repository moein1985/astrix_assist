import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../core/locale_manager.dart';
import '../../domain/entities/server_config.dart';
import '../../domain/services/server_manager.dart';
import '../widgets/language_switcher.dart';
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

    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(existing == null ? l10n.addNewServer : l10n.editServer),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.serverName,
                      prefixIcon: const Icon(Icons.label),
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: hostController,
                    decoration: InputDecoration(
                      labelText: l10n.ipAddress,
                      prefixIcon: const Icon(Icons.dns),
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.ipRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: portController,
                    decoration: InputDecoration(
                      labelText: l10n.port,
                      prefixIcon: const Icon(Icons.settings_ethernet),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? l10n.portRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.deleteServer),
          content: Text('${l10n.deleteConfirm} "${config.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await ServerManager.deleteServer(config.id);
      _loadServers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    title: Text(l10n.appTitle),
                    actions: const [
                      LanguageSwitcher(),
                      ThemeToggleButton(),
                    ],
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
                                l10n.savedServers,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              FilledButton.icon(
                                onPressed: () => _showAddEditDialog(),
                                icon: const Icon(Icons.add),
                                label: Text(l10n.addServer),
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
                                      l10n.noServers,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.addServerToStart,
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
                                    subtitle: Column(
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
                                              Text(l10n.active, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showAddEditDialog(server),
                                          tooltip: l10n.edit,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteServer(server),
                                          tooltip: l10n.delete,
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
      ),
    );
  }
}

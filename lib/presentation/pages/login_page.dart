import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../core/locale_manager.dart';
import '../../core/ssh_config.dart';
import '../../core/services/asterisk_ssh_manager.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading dialog
    if (!mounted) return;
    String statusMessage = 'Connecting to server...';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(statusMessage),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      void updateStatus(String message) {
        statusMessage = message;
        if (mounted) {
          // Force update the dialog
          Navigator.pop(context);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(message),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }

      // Step 1: Test SSH Connection
      updateStatus('Testing SSH connection...');
      final sshConfig = SshConfig(
        host: config.host,
        port: 22, // SSH port
        username: config.username,
        password: config.password,
        authMethod: 'password',
      );
      
      final sshManager = AsteriskSshManager(sshConfig);
      await sshManager.connect();
      
      // Step 2: Check AMI Status
      updateStatus('Checking AMI status...');
      final amiStatus = await sshManager.checkAmi();
      
      String amiUsername = 'astrix_assist';
      String amiPassword = 'A12321ssist';
      
      // Step 3: Setup AMI if needed
      if (amiStatus.success && amiStatus.data != null) {
        final data = amiStatus.data!;
        if (!data.enabled || !data.userExists) {
          updateStatus('Configuring AMI...');
          final setupResult = await sshManager.setupAmi(
            username: amiUsername,
            password: amiPassword,
          );
          
          if (!setupResult.success) {
            throw Exception('AMI setup failed: ${setupResult.error ?? "Unknown error"}');
          }
        } else {
          updateStatus('AMI already configured');
        }
      } else {
        // If check fails, try to setup anyway
        updateStatus('Setting up AMI...');
        final setupResult = await sshManager.setupAmi(
          username: amiUsername,
          password: amiPassword,
        );
        
        if (!setupResult.success) {
          // Just warn, don't fail - user can configure manually
          print('Warning: AMI auto-setup failed: ${setupResult.error}');
        }
      }
      
      // Step 4: Save SSH Config
      updateStatus('Saving configuration...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ssh_host', config.host);
      await prefs.setInt('ssh_port', 22);
      await prefs.setString('ssh_username', config.username);
      
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'ssh_password', value: config.password);
      
      // Step 5: Save AMI Config
      await prefs.setString('ami_host', config.host);
      await prefs.setInt('ami_port', 5038);
      await prefs.setString('ami_username', amiUsername);
      await secureStorage.write(key: 'ami_password', value: amiPassword);
      
      // Step 6: Save as active server
      await ServerManager.setActiveServer(config.id);
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Navigate to dashboard
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.connectionError),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connection failed. Please check:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• SSH server is running on port 22'),
                  const Text('• Username/password are correct'),
                  const Text('• Server is reachable'),
                  const SizedBox(height: 16),
                  const Text(
                    'Error details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(e.toString(), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _showAddEditDialog([ServerConfig? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final hostController = TextEditingController(text: existing?.host ?? '');
    final portController = TextEditingController(text: existing?.port.toString() ?? '22');
    final userController = TextEditingController(text: existing?.username ?? 'root');
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
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enter SSH (root) credentials.\nAMI will be auto-configured.',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.serverName,
                      prefixIcon: const Icon(Icons.label),
                      helperText: 'e.g., Office PBX',
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.nameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: hostController,
                    decoration: InputDecoration(
                      labelText: 'Server IP Address',
                      prefixIcon: const Icon(Icons.dns),
                      helperText: 'e.g., 192.168.1.100',
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.ipRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: portController,
                    decoration: InputDecoration(
                      labelText: 'SSH Port',
                      prefixIcon: const Icon(Icons.settings_ethernet),
                      helperText: 'Default: 22',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Port required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: userController,
                    decoration: InputDecoration(
                      labelText: 'SSH Username',
                      prefixIcon: const Icon(Icons.person),
                      helperText: 'Usually "root"',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Username required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passController,
                    decoration: InputDecoration(
                      labelText: 'SSH Password',
                      prefixIcon: const Icon(Icons.lock),
                      helperText: 'Root password',
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? 'Password required' : null,
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
                                                'SSH: ${server.host}:${server.port}',
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
                                        const SizedBox(height: 2),
                                        const Row(
                                          children: [
                                            Icon(Icons.info_outline, size: 14, color: Colors.blue),
                                            SizedBox(width: 4),
                                            Text(
                                              'AMI: Auto-configured',
                                              style: TextStyle(fontSize: 11, color: Colors.blue),
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../core/locale_manager.dart';
import '../../core/ssh_config.dart';
import '../../core/ssh_service.dart';
import '../../core/services/asterisk_ssh_manager.dart';
import '../../core/app_config.dart';

/// صفحه تنظیمات سرور - SSH + AMI Configuration
/// این صفحه جایگزین تنظیمات پیچیده MySQL شده است
class ServerSetupPage extends StatefulWidget {
  const ServerSetupPage({super.key});

  @override
  State<ServerSetupPage> createState() => _ServerSetupPageState();
}

class _ServerSetupPageState extends State<ServerSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = const FlutterSecureStorage();
  
  // SSH Fields
  final _sshHostController = TextEditingController();
  final _sshPortController = TextEditingController(text: '22');
  final _sshUsernameController = TextEditingController(text: 'root');
  final _sshPasswordController = TextEditingController();
  
  // AMI Fields
  final _amiHostController = TextEditingController();
  final _amiPortController = TextEditingController(text: '5038');
  final _amiUsernameController = TextEditingController();
  final _amiPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _sshTested = false;
  bool _amiAutoSetup = true;
  String? _connectionMessage;
  Color? _messageColor;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _sshHostController.dispose();
    _sshPortController.dispose();
    _sshUsernameController.dispose();
    _sshPasswordController.dispose();
    _amiHostController.dispose();
    _amiPortController.dispose();
    _amiUsernameController.dispose();
    _amiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _sshHostController.text = prefs.getString('ssh_host') ?? AppConfig.defaultSshHost;
      _sshPortController.text = prefs.getInt('ssh_port')?.toString() ?? '22';
      _sshUsernameController.text = prefs.getString('ssh_username') ?? AppConfig.defaultSshUsername;
      
      _amiHostController.text = prefs.getString('ami_host') ?? AppConfig.defaultAmiHost;
      _amiPortController.text = prefs.getInt('ami_port')?.toString() ?? '5038';
      _amiUsernameController.text = prefs.getString('ami_username') ?? AppConfig.defaultAmiUsername;
      
      _amiAutoSetup = prefs.getBool('ami_auto_setup') ?? true;
    });
    
    // Load passwords from secure storage
    final sshPassword = await _secureStorage.read(key: 'ssh_password');
    final amiPassword = await _secureStorage.read(key: 'ami_password');
    
    if (sshPassword != null) {
      _sshPasswordController.text = sshPassword;
    }
    if (amiPassword != null) {
      _amiPasswordController.text = amiPassword;
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save SSH settings
      await prefs.setString('ssh_host', _sshHostController.text.trim());
      await prefs.setInt('ssh_port', int.parse(_sshPortController.text));
      await prefs.setString('ssh_username', _sshUsernameController.text.trim());
      await _secureStorage.write(key: 'ssh_password', value: _sshPasswordController.text);
      
      // Save AMI settings
      await prefs.setString('ami_host', _amiHostController.text.trim());
      await prefs.setInt('ami_port', int.parse(_amiPortController.text));
      await prefs.setString('ami_username', _amiUsernameController.text.trim());
      await _secureStorage.write(key: 'ami_password', value: _amiPasswordController.text);
      await prefs.setBool('ami_auto_setup', _amiAutoSetup);
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSshConnection() async {
    if (_sshHostController.text.isEmpty || _sshUsernameController.text.isEmpty) {
      setState(() {
        _connectionMessage = 'Please fill SSH host and username';
        _messageColor = Colors.red;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _connectionMessage = 'Testing SSH connection...';
      _messageColor = Colors.orange;
    });
    
    try {
      final config = SshConfig(
        host: _sshHostController.text.trim(),
        port: int.parse(_sshPortController.text),
        username: _sshUsernameController.text.trim(),
        password: _sshPasswordController.text,
        authMethod: 'password',
      );
      
      final sshService = SshService(config);
      final success = await sshService.testConnection();
      
      setState(() {
        _sshTested = success;
        _connectionMessage = success 
          ? '✓ SSH connection successful!' 
          : '✗ SSH connection failed';
        _messageColor = success ? Colors.green : Colors.red;
      });
    } catch (e) {
      setState(() {
        _sshTested = false;
        _connectionMessage = 'SSH Error: $e';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupAmiAutomatically() async {
    if (!_sshTested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please test SSH connection first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _connectionMessage = 'Setting up AMI automatically...';
      _messageColor = Colors.blue;
    });
    
    try {
      final config = SshConfig(
        host: _sshHostController.text.trim(),
        port: int.parse(_sshPortController.text),
        username: _sshUsernameController.text.trim(),
        password: _sshPasswordController.text,
        authMethod: 'password',
      );
      
      final manager = AsteriskSshManager(config);
      await manager.connect();
      
      // Generate random AMI credentials if empty
      String amiUser = _amiUsernameController.text.trim();
      String amiPass = _amiPasswordController.text;
      
      if (amiUser.isEmpty) {
        amiUser = 'astrix_${DateTime.now().millisecondsSinceEpoch % 10000}';
        _amiUsernameController.text = amiUser;
      }
      if (amiPass.isEmpty) {
        amiPass = _generateRandomPassword(12);
        _amiPasswordController.text = amiPass;
      }
      
      // Setup AMI via Python script
      final result = await manager.setupAmi(
        username: amiUser,
        password: amiPass,
      );
      
      if (result.success) {
        setState(() {
          _connectionMessage = '✓ AMI setup completed! User: $amiUser';
          _messageColor = Colors.green;
          _amiHostController.text = _sshHostController.text; // AMI host = SSH host
        });
        
        // Save settings automatically
        await _saveSettings();
      } else {
        setState(() {
          _connectionMessage = '✗ AMI setup failed: ${result.error ?? "Unknown error"}';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _connectionMessage = 'AMI Setup Error: $e';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateRandomPassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => chars.codeUnitAt((DateTime.now().microsecondsSinceEpoch % chars.length)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = LocaleManager.isFarsi();
    
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Server Setup'),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection Status Message
              if (_connectionMessage != null)
                Card(
                  color: _messageColor?.withAlpha((0.1 * 255).round()),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          _messageColor == Colors.green 
                            ? Icons.check_circle 
                            : _messageColor == Colors.red 
                              ? Icons.error 
                              : Icons.info,
                          color: _messageColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _connectionMessage!,
                            style: TextStyle(color: _messageColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // SSH Settings Section
              _buildSectionHeader('SSH Settings', Icons.security),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _sshHostController,
                decoration: InputDecoration(
                  labelText: 'SSH Host (IP or Domain)',
                  prefixIcon: const Icon(Icons.computer),
                  border: const OutlineInputBorder(),
                  helperText: 'Server IP address or domain name',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _sshUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'SSH Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sshPortController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (int.tryParse(value!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _sshPasswordController,
                decoration: const InputDecoration(
                  labelText: 'SSH Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  helperText: 'Root or sudo user password',
                ),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testSshConnection,
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Test SSH Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              
              const Divider(height: 40),
              
              // AMI Settings Section
              _buildSectionHeader('AMI Settings', Icons.phone_callback),
              const SizedBox(height: 12),
              
              SwitchListTile(
                title: const Text('Auto-Setup AMI'),
                subtitle: const Text('Automatically configure AMI user via SSH'),
                value: _amiAutoSetup,
                onChanged: (value) => setState(() => _amiAutoSetup = value),
              ),
              const SizedBox(height: 12),
              
              if (_amiAutoSetup) ...[
                Card(
                  color: Colors.blue.withAlpha((0.1 * 255).round()),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Automatic Setup',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We will automatically:\n'
                          '• Enable AMI in manager.conf\n'
                          '• Create AMI user with full permissions\n'
                          '• Reload Asterisk configuration\n'
                          '• Test the connection',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading || !_sshTested ? null : _setupAmiAutomatically,
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Setup AMI Automatically'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Or fill AMI credentials manually:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
              ],
              
              TextFormField(
                controller: _amiHostController,
                decoration: const InputDecoration(
                  labelText: 'AMI Host',
                  prefixIcon: Icon(Icons.dns),
                  border: OutlineInputBorder(),
                  helperText: 'Usually same as SSH host',
                ),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amiUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'AMI Username',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amiPortController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _amiPasswordController,
                decoration: const InputDecoration(
                  labelText: 'AMI Secret/Password',
                  prefixIcon: Icon(Icons.vpn_key),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSettings,
                icon: const Icon(Icons.save),
                label: Text(l10n.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

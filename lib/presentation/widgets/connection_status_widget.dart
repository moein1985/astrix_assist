import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../data/datasources/ami_datasource.dart';

class ConnectionStatusWidget extends StatefulWidget {
  const ConnectionStatusWidget({super.key});

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  String? _serverName;
  ConnectionStatus _status = ConnectionStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _loadServerInfo();
  }

  Future<void> _loadServerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('ip') ?? 'Unknown';
    setState(() {
      _serverName = host;
      _status = ConnectionStatus.connected; // Assume connected if we're in the app
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _showServerDetails,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _serverName ?? l10n.server,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getStatusText(l10n),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (_status) {
      case ConnectionStatus.connected:
        return l10n.connectionConnected;
      case ConnectionStatus.connecting:
        return l10n.connectionConnecting;
      case ConnectionStatus.error:
        return l10n.connectionError;
      case ConnectionStatus.disconnected:
        return l10n.connectionDisconnected;
    }
  }

  void _showServerDetails() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    
    // AMI Settings
    final amiHost = prefs.getString('ami_host') ?? prefs.getString('ip') ?? 'N/A';
    final amiPort = prefs.getInt('ami_port')?.toString() ?? prefs.getString('port') ?? '5038';
    final amiUsername = prefs.getString('ami_username') ?? prefs.getString('username') ?? 'N/A';
    
    // SSH Settings
    final sshHost = prefs.getString('ssh_host') ?? 'N/A';
    final sshPort = prefs.getInt('ssh_port')?.toString() ?? '22';
    final sshUsername = prefs.getString('ssh_username') ?? 'N/A';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 12),
            Text(l10n.serverInfoTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(l10n.serverLabelStatus, _getStatusText(l10n)),
              const Divider(),
              // AMI Section
              const Text(
                'AMI Connection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(l10n.serverLabelAddress, amiHost),
              _buildInfoRow(l10n.serverLabelPort, amiPort),
              _buildInfoRow(l10n.serverLabelUsername, amiUsername),
              const Divider(),
              // SSH Section
              const Text(
                'SSH Connection',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('SSH Host', sshHost),
              _buildInfoRow('SSH Port', sshPort),
              _buildInfoRow('SSH User', sshUsername),
              const SizedBox(height: 8),
              const Text(
                '💡 SSH is used for CDR access and recordings',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

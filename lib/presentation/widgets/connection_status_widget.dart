import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                  _serverName ?? 'سرور',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getStatusText(),
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

  String _getStatusText() {
    switch (_status) {
      case ConnectionStatus.connected:
        return 'متصل';
      case ConnectionStatus.connecting:
        return 'در حال اتصال...';
      case ConnectionStatus.error:
        return 'خطا';
      case ConnectionStatus.disconnected:
        return 'قطع شده';
    }
  }

  void _showServerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('ip') ?? 'N/A';
    final port = prefs.getString('port') ?? '5038';
    final username = prefs.getString('username') ?? 'N/A';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 12),
            const Text('اطلاعات سرور'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('وضعیت', _getStatusText()),
            const Divider(),
            _buildInfoRow('آدرس', host),
            _buildInfoRow('پورت', port),
            _buildInfoRow('نام کاربری', username),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
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

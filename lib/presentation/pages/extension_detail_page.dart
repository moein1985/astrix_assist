import 'package:flutter/material.dart';
import '../../domain/entities/extension.dart';
import '../widgets/theme_toggle_button.dart';

class ExtensionDetailPage extends StatelessWidget {
  final Extension extensionInfo;
  const ExtensionDetailPage({super.key, required this.extensionInfo});

  @override
  Widget build(BuildContext context) {
    final ext = extensionInfo;
    return Scaffold(
      appBar: AppBar(
        title: Text('داخلی ${ext.name}'),
        actions: const [ThemeToggleButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Number', ext.name),
            _infoRow('IP/Location', ext.location.isNotEmpty ? ext.location : 'N/A'),
            _infoRow('Status', ext.status),
            _infoRow('Online', ext.isOnline ? 'Yes' : 'No'),
            _infoRow('Trunk', ext.isTrunk ? 'Yes' : 'No'),
            if (ext.latency != null) _infoRow('Latency', '${ext.latency} ms'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

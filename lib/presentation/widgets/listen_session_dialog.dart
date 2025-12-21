import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/ami_api.dart';

/// @deprecated This widget is no longer needed after removing Backend Proxy.
/// Listen functionality now uses direct AMI connection via AmiListenClient.
class ListenSessionDialog extends StatefulWidget {
  final String jobId;

  const ListenSessionDialog({super.key, required this.jobId});

  @override
  State<ListenSessionDialog> createState() => _ListenSessionDialogState();
}

class _ListenSessionDialogState extends State<ListenSessionDialog> {
  String _status = 'pending';
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _stopping = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _sub = AmiApi.pollJob(widget.jobId).listen((job) {
      final s = (job['status'] as String?) ?? 'unknown';
      if (mounted) setState(() => _status = s);
      if (s == 'stopped' || s == 'unknown') {
        // keep the final status visible but stop polling
        _sub?.cancel();
      }
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _stop() async {
    if (_stopping) return;
    setState(() => _stopping = true);
    try {
      await AmiApi.controlPlayback({'jobId': widget.jobId, 'command': 'stop'});
    } catch (_) {}
    setState(() => _stopping = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Listen Live'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job: ${widget.jobId}'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Status: '),
              Text(
                _status,
                style: TextStyle(
                  color: _status == 'listening' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: _status == 'listening' || _status == 'connecting' ? () async {
            await _stop();
          } : null,
          icon: const Icon(Icons.stop_circle),
          label: _stopping ? const Text('Stopping...') : const Text('Stop'),
        ),
      ],
    );
  }
}

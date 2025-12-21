import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/ami_api.dart';

/// @deprecated This widget is no longer needed after removing Backend Proxy.
/// Playback functionality now uses direct AMI connection via AmiListenClient.
class PlaybackSessionDialog extends StatefulWidget {
  final String jobId;

  const PlaybackSessionDialog({super.key, required this.jobId});

  @override
  State<PlaybackSessionDialog> createState() => _PlaybackSessionDialogState();
}

class _PlaybackSessionDialogState extends State<PlaybackSessionDialog> {
  String _status = 'pending';
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _processing = false;

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
        _sub?.cancel();
      }
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _sendCommand(String command) async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      await AmiApi.controlPlayback({'jobId': widget.jobId, 'command': command});
    } catch (_) {}
    setState(() => _processing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Playback Session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job: ${widget.jobId}'),
          const SizedBox(height: 8),
          Row(children: [const Text('Status: '), Text(_status, style: TextStyle(color: _status == 'playing' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold))]),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        IconButton(
          tooltip: 'Pause',
          onPressed: (_status == 'playing' && !_processing) ? () => _sendCommand('pause') : null,
          icon: const Icon(Icons.pause_circle_filled),
        ),
        IconButton(
          tooltip: 'Stop',
          onPressed: (_status == 'playing' || _status == 'connecting') && !_processing ? () => _sendCommand('stop') : null,
          icon: const Icon(Icons.stop_circle),
        ),
      ],
    );
  }
}

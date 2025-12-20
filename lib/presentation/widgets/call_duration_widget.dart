import 'package:flutter/material.dart';
import 'dart:async';

class CallDurationWidget extends StatefulWidget {
  final String durationString; // Format: "00:00:05" or seconds like "5"
  
  const CallDurationWidget({
    super.key,
    required this.durationString,
  });

  @override
  State<CallDurationWidget> createState() => _CallDurationWidgetState();
}

class _CallDurationWidgetState extends State<CallDurationWidget> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _parseInitialDuration();
    _startTimer();
  }

  void _parseInitialDuration() {
    try {
      // Try to parse as seconds first
      _elapsedSeconds = int.tryParse(widget.durationString) ?? 0;
      
      // If that fails, try to parse as HH:MM:SS or MM:SS
      if (_elapsedSeconds == 0 && widget.durationString.contains(':')) {
        final parts = widget.durationString.split(':');
        if (parts.length == 3) {
          // HH:MM:SS
          _elapsedSeconds = int.parse(parts[0]) * 3600 + 
                           int.parse(parts[1]) * 60 + 
                           int.parse(parts[2]);
        } else if (parts.length == 2) {
          // MM:SS
          _elapsedSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
      }
    } catch (e) {
      _elapsedSeconds = 0;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getDurationColor() {
    final minutes = _elapsedSeconds ~/ 60;
    if (minutes < 5) {
      return Colors.green;
    } else if (minutes < 15) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDuration() {
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final seconds = _elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDurationColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDurationColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: _getDurationColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _getDurationColor(),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

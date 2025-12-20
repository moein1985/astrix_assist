import 'dart:math';
import 'package:astrix_assist/domain/entities/active_call.dart';
import 'package:astrix_assist/domain/entities/queue_status.dart';
import 'package:astrix_assist/domain/repositories/imonitor_repository.dart';
import 'package:astrix_assist/core/result.dart';
import 'package:astrix_assist/data/models/active_call_model.dart';
import 'package:astrix_assist/data/models/queue_status_model.dart';
import 'mock_data.dart';

class MonitorRepositoryMock implements IMonitorRepository {
  @override
  Future<Result<List<ActiveCall>>> getActiveCalls() async {
    // شبیه‌سازی تاخیر شبکه
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

    final activeCalls = <ActiveCall>[];

    for (final channelString in MockData.mockActiveChannels) {
      // فیلتر کانال‌های سیستمی
      if (_isSystemChannel(channelString)) continue;

      try {
        final call = ActiveCallModel.fromAmi(channelString);
        // فقط تماس‌های واقعی (Up و ConnectedLineNum پر)
        if (_isRealCall(channelString)) {
          activeCalls.add(call);
        }
      } catch (e) {
        continue;
      }
    }

    return Success(activeCalls);
  }

  @override
  Future<Result<List<QueueStatus>>> getQueueStatuses() async {
    // شبیه‌سازی تاخیر شبکه
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

    // گروه‌بندی events بر اساس Queue
    final queueEvents = <String, List<String>>{};

    for (final event in MockData.mockQueueStatus) {
      final lines = event.split(RegExp(r'\r\n|\n'));
      final queue = _valueForPrefix(lines, 'Queue: ');
      if (queue.isNotEmpty) {
        queueEvents.putIfAbsent(queue, () => []).add(event);
      }
    }

    final queueStatuses = <QueueStatus>[];
    for (final entry in queueEvents.entries) {
      try {
        final status = QueueStatusModel.fromEvents(entry.key, entry.value);
        queueStatuses.add(status);
      } catch (e) {
        continue;
      }
    }

    return Success(queueStatuses);
  }

  @override
  Future<Result<void>> hangup(String channel) async {
    // Mock implementation - do nothing
    await Future.delayed(Duration(milliseconds: 100));
    return Success(null);
  }

  @override
  Future<Result<void>> originate({required String from, required String to, required String context}) async {
    // Mock implementation - do nothing
    await Future.delayed(Duration(milliseconds: 100));
    return Success(null);
  }

  @override
  Future<Result<void>> transfer({required String channel, required String destination, required String context}) async {
    // Mock implementation - do nothing
    await Future.delayed(Duration(milliseconds: 100));
    return Success(null);
  }

  @override
  Future<Result<void>> pauseAgent({required String queue, required String interface, required bool paused, String? reason}) async {
    // Mock implementation - do nothing
    await Future.delayed(Duration(milliseconds: 100));
    return Success(null);
  }

  bool _isSystemChannel(String channelString) {
    final lines = channelString.split(RegExp(r'\r\n|\n'));
    final channel = _valueForPrefix(lines, 'Channel: ');
    return channel.contains('Local@') ||
           channel.contains('VoiceMail') ||
           channel.contains('Parked') ||
           channel.contains('ConfBridge') ||
           channel.contains('MeetMe') ||
           _valueForPrefix(lines, 'Application: ') != 'Dial';
  }

  bool _isRealCall(String channelString) {
    final lines = channelString.split(RegExp(r'\r\n|\n'));
    final stateDesc = _valueForPrefix(lines, 'ChannelStateDesc: ');
    final connectedLine = _valueForPrefix(lines, 'ConnectedLineNum: ');
    return stateDesc == 'Up' && connectedLine.isNotEmpty;
  }

  String _valueForPrefix(List<String> lines, String prefix) {
    for (final line in lines) {
      if (line.startsWith(prefix)) {
        return line.substring(prefix.length);
      }
    }
    return '';
  }
}
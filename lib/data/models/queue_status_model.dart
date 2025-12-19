import '../../domain/entities/queue_member.dart';
import '../../domain/entities/queue_status.dart';

class QueueStatusModel extends QueueStatus {
  QueueStatusModel({
    required super.queue,
    required super.calls,
    required super.holdTime,
    required super.talkTime,
    required super.completed,
    required super.members,
  });

  factory QueueStatusModel.fromEvents(String queue, List<String> events) {
    int calls = 0;
    int holdTime = 0;
    int talkTime = 0;
    int completed = 0;
    final List<QueueMember> members = [];

    for (final event in events) {
      final lines = event.split(RegExp(r'\r\n|\n')).where((l) => l.isNotEmpty).toList();
      final type = _valueForPrefix(lines, 'Event: ');
      if (type == 'QueueParams') {
        calls = _intForPrefix(lines, 'Calls: ');
        holdTime = _intForPrefix(lines, 'Holdtime: ');
        talkTime = _intForPrefix(lines, 'TalkTime: ');
        completed = _intForPrefix(lines, 'Completed: ');
      } else if (type == 'QueueMember') {
        final name = _valueForPrefix(lines, 'Name: ');
        final paused = _intForPrefix(lines, 'Paused: ') == 1;
        final statusCode = _intForPrefix(lines, 'Status: ');
        final callsTaken = _intForPrefix(lines, 'CallsTaken: ');
        final lastCall = _intForPrefix(lines, 'LastCall: ');
        members.add(QueueMember(
          name: name.isNotEmpty ? name : _valueForPrefix(lines, 'Location: '),
          state: _mapStatus(statusCode, paused),
          paused: paused,
          callsTaken: callsTaken,
          lastCall: lastCall,
        ));
      }
    }

    return QueueStatusModel(
      queue: queue,
      calls: calls,
      holdTime: holdTime,
      talkTime: talkTime,
      completed: completed,
      members: members,
    );
  }

  static String _valueForPrefix(List<String> lines, String prefix) {
    final line = lines.firstWhere(
      (l) => l.startsWith(prefix),
      orElse: () => '',
    );
    return line.isEmpty ? '' : line.substring(prefix.length);
  }

  static int _intForPrefix(List<String> lines, String prefix) {
    return int.tryParse(_valueForPrefix(lines, prefix)) ?? 0;
  }

  static String _mapStatus(int code, bool paused) {
    if (paused) return 'Paused';
    switch (code) {
      case 1:
        return 'Ready';
      case 2:
        return 'In Use';
      case 3:
        return 'Busy';
      case 4:
        return 'Unavailable';
      case 5:
        return 'Ringing';
      case 6:
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }
}

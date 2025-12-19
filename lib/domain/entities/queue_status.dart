import 'queue_member.dart';

class QueueStatus {
  final String queue;
  final int calls;
  final int holdTime;
  final int talkTime;
  final int completed;
  final List<QueueMember> members;

  QueueStatus({
    required this.queue,
    required this.calls,
    required this.holdTime,
    required this.talkTime,
    required this.completed,
    required this.members,
  });
}

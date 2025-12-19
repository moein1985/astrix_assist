class QueueMember {
  final String name;
  final String state;
  final bool paused;
  final int callsTaken;
  final int lastCall;

  QueueMember({
    required this.name,
    required this.state,
    required this.paused,
    required this.callsTaken,
    required this.lastCall,
  });
}

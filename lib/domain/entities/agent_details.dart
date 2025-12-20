import 'package:equatable/equatable.dart';

class AgentDetails extends Equatable {
  final String name;
  final String interface;
  final String state;
  final bool paused;
  final String? pauseReason;
  final int callsTaken;
  final int lastCall;
  final List<String> queues;
  final int callsAnsweredToday;
  final double averageTalkTime;

  const AgentDetails({
    required this.name,
    required this.interface,
    required this.state,
    required this.paused,
    this.pauseReason,
    required this.callsTaken,
    required this.lastCall,
    required this.queues,
    required this.callsAnsweredToday,
    required this.averageTalkTime,
  });

  @override
  List<Object?> get props => [
        name,
        interface,
        state,
        paused,
        pauseReason,
        callsTaken,
        lastCall,
        queues,
        callsAnsweredToday,
        averageTalkTime,
      ];
}

part of 'agent_detail_bloc.dart';

abstract class AgentDetailEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAgentDetails extends AgentDetailEvent {
  final String agentInterface;

  LoadAgentDetails(this.agentInterface);

  @override
  List<Object?> get props => [agentInterface];
}

class PauseAgentFromDetail extends AgentDetailEvent {
  final String queue;
  final String interface;
  final String? reason;

  PauseAgentFromDetail({
    required this.queue,
    required this.interface,
    this.reason,
  });

  @override
  List<Object?> get props => [queue, interface, reason];
}

class UnpauseAgentFromDetail extends AgentDetailEvent {
  final String queue;
  final String interface;

  UnpauseAgentFromDetail({
    required this.queue,
    required this.interface,
  });

  @override
  List<Object?> get props => [queue, interface];
}

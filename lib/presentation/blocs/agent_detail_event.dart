part of 'agent_detail_bloc.dart';

sealed class AgentDetailEvent {}

final class LoadAgentDetails extends AgentDetailEvent {
  final String agentInterface;

  LoadAgentDetails(this.agentInterface);
}

final class PauseAgentFromDetail extends AgentDetailEvent {
  final String queue;
  final String interface;
  final String? reason;

  PauseAgentFromDetail({
    required this.queue,
    required this.interface,
    this.reason,
  });
}

final class UnpauseAgentFromDetail extends AgentDetailEvent {
  final String queue;
  final String interface;

  UnpauseAgentFromDetail({
    required this.queue,
    required this.interface,
  });
}

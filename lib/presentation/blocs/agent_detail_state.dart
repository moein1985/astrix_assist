part of 'agent_detail_bloc.dart';

sealed class AgentDetailState {}

final class AgentDetailInitial extends AgentDetailState {}

final class AgentDetailLoading extends AgentDetailState {}

final class AgentDetailLoaded extends AgentDetailState {
  final AgentDetails details;

  AgentDetailLoaded(this.details);
}

final class AgentDetailError extends AgentDetailState {
  final String message;

  AgentDetailError(this.message);
}

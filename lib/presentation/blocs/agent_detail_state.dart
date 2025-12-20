part of 'agent_detail_bloc.dart';

abstract class AgentDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgentDetailInitial extends AgentDetailState {}

class AgentDetailLoading extends AgentDetailState {}

class AgentDetailLoaded extends AgentDetailState {
  final AgentDetails details;

  AgentDetailLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class AgentDetailError extends AgentDetailState {
  final String message;

  AgentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

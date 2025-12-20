part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQueues extends QueueEvent {}

class PauseAgent extends QueueEvent {
  final String queue;
  final String interface;
  final String? reason;

  PauseAgent({required this.queue, required this.interface, this.reason});

  @override
  List<Object?> get props => [queue, interface, reason];
}

class UnpauseAgent extends QueueEvent {
  final String queue;
  final String interface;

  UnpauseAgent({required this.queue, required this.interface});

  @override
  List<Object?> get props => [queue, interface];
}

part of 'queue_bloc.dart';

sealed class QueueEvent {
  const QueueEvent();
}

final class LoadQueues extends QueueEvent {
  const LoadQueues();
}

final class PauseAgent extends QueueEvent {
  final String queue;
  final String interface;
  final String? reason;

  const PauseAgent({required this.queue, required this.interface, this.reason});
}

final class UnpauseAgent extends QueueEvent {
  final String queue;
  final String interface;

  const UnpauseAgent({required this.queue, required this.interface});
}

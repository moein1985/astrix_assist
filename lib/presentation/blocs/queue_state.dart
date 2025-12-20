part of 'queue_bloc.dart';

sealed class QueueState {
  const QueueState();
}

final class QueueInitial extends QueueState {
  const QueueInitial();
}

final class QueueLoading extends QueueState {
  const QueueLoading();
}

final class QueueLoaded extends QueueState {
  final List<QueueStatus> queues;
  const QueueLoaded(this.queues);
}

final class QueueError extends QueueState {
  final String message;
  const QueueError(this.message);
}

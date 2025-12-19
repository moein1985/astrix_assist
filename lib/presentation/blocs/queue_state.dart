part of 'queue_bloc.dart';

abstract class QueueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QueueInitial extends QueueState {}

class QueueLoading extends QueueState {}

class QueueLoaded extends QueueState {
  final List<QueueStatus> queues;
  QueueLoaded(this.queues);

  @override
  List<Object?> get props => [queues];
}

class QueueError extends QueueState {
  final String message;
  QueueError(this.message);

  @override
  List<Object?> get props => [message];
}

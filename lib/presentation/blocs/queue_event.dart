part of 'queue_bloc.dart';

abstract class QueueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadQueues extends QueueEvent {}

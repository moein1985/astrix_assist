part of 'active_call_bloc.dart';

abstract class ActiveCallState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActiveCallInitial extends ActiveCallState {}

class ActiveCallLoading extends ActiveCallState {}

class ActiveCallLoaded extends ActiveCallState {
  final List<ActiveCall> calls;
  ActiveCallLoaded(this.calls);

  @override
  List<Object?> get props => [calls];
}

class ActiveCallError extends ActiveCallState {
  final String message;
  ActiveCallError(this.message);

  @override
  List<Object?> get props => [message];
}

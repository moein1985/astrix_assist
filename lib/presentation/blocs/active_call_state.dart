part of 'active_call_bloc.dart';

sealed class ActiveCallState {
  const ActiveCallState();
}

final class ActiveCallInitial extends ActiveCallState {
  const ActiveCallInitial();
}

final class ActiveCallLoading extends ActiveCallState {
  const ActiveCallLoading();
}

final class ActiveCallLoaded extends ActiveCallState {
  final List<ActiveCall> calls;
  const ActiveCallLoaded(this.calls);
}

final class ActiveCallError extends ActiveCallState {
  final String message;
  const ActiveCallError(this.message);
}

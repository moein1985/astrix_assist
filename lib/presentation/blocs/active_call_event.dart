part of 'active_call_bloc.dart';

abstract class ActiveCallEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadActiveCalls extends ActiveCallEvent {}

class HangupCall extends ActiveCallEvent {
  final String channel;
  HangupCall(this.channel);

  @override
  List<Object?> get props => [channel];
}

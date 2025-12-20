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

class TransferCall extends ActiveCallEvent {
  final String channel;
  final String destination;
  final String context;
  
  TransferCall({
    required this.channel,
    required this.destination,
    this.context = 'from-internal',
  });

  @override
  List<Object?> get props => [channel, destination, context];
}

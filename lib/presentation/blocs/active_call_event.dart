part of 'active_call_bloc.dart';

sealed class ActiveCallEvent {
  const ActiveCallEvent();
}

final class LoadActiveCalls extends ActiveCallEvent {
  const LoadActiveCalls();
}

final class HangupCall extends ActiveCallEvent {
  final String channel;
  const HangupCall(this.channel);
}

final class TransferCall extends ActiveCallEvent {
  final String channel;
  final String destination;
  final String context;

  const TransferCall({
    required this.channel,
    required this.destination,
    this.context = 'from-internal',
  });
}

part of 'parking_bloc.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class LoadParkedCalls extends ParkingEvent {
  const LoadParkedCalls();
}

class RefreshParkedCalls extends ParkingEvent {
  const RefreshParkedCalls();
}

class PickupCall extends ParkingEvent {
  final String exten;
  final String extension;

  const PickupCall({required this.exten, required this.extension});

  @override
  List<Object?> get props => [exten, extension];
}

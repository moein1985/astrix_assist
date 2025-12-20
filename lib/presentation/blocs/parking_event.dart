part of 'parking_bloc.dart';

sealed class ParkingEvent {}

final class LoadParkedCalls extends ParkingEvent {}

final class RefreshParkedCalls extends ParkingEvent {}

final class PickupCall extends ParkingEvent {
  final String exten;
  final String extension;

  PickupCall({required this.exten, required this.extension});
}

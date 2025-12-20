part of 'parking_bloc.dart';

sealed class ParkingState {}

final class ParkingInitial extends ParkingState {}

final class ParkingLoading extends ParkingState {}

final class ParkingLoaded extends ParkingState {
  final List<ParkedCall> parkedCalls;

  ParkingLoaded(this.parkedCalls);
}

final class ParkingError extends ParkingState {
  final String message;

  ParkingError(this.message);
}

final class ParkedCallPickedUp extends ParkingState {
  final String exten;

  ParkedCallPickedUp(this.exten);
}

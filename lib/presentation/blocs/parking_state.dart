part of 'parking_bloc.dart';

abstract class ParkingState extends Equatable {
  const ParkingState();

  @override
  List<Object?> get props => [];
}

class ParkingInitial extends ParkingState {
  const ParkingInitial();
}

class ParkingLoading extends ParkingState {
  const ParkingLoading();
}

class ParkingLoaded extends ParkingState {
  final List<ParkedCall> parkedCalls;

  const ParkingLoaded(this.parkedCalls);

  @override
  List<Object?> get props => [parkedCalls];
}

class ParkingError extends ParkingState {
  final String message;

  const ParkingError(this.message);

  @override
  List<Object?> get props => [message];
}

class ParkedCallPickedUp extends ParkingState {
  final String exten;

  const ParkedCallPickedUp(this.exten);

  @override
  List<Object?> get props => [exten];
}

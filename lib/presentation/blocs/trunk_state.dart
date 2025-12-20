part of 'trunk_bloc.dart';

abstract class TrunkState extends Equatable {
  const TrunkState();

  @override
  List<Object?> get props => [];
}

class TrunkInitial extends TrunkState {
  const TrunkInitial();
}

class TrunkLoading extends TrunkState {
  const TrunkLoading();
}

class TrunkLoaded extends TrunkState {
  final List<Trunk> trunks;

  const TrunkLoaded(this.trunks);

  @override
  List<Object?> get props => [trunks];
}

class TrunkError extends TrunkState {
  final String message;

  const TrunkError(this.message);

  @override
  List<Object?> get props => [message];
}

part of 'trunk_bloc.dart';

sealed class TrunkState {}

final class TrunkInitial extends TrunkState {}

final class TrunkLoading extends TrunkState {}

final class TrunkLoaded extends TrunkState {
  final List<Trunk> trunks;

  TrunkLoaded(this.trunks);
}

final class TrunkError extends TrunkState {
  final String message;

  TrunkError(this.message);
}

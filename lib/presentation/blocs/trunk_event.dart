part of 'trunk_bloc.dart';

abstract class TrunkEvent extends Equatable {
  const TrunkEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrunks extends TrunkEvent {
  const LoadTrunks();
}

class RefreshTrunks extends TrunkEvent {
  const RefreshTrunks();
}

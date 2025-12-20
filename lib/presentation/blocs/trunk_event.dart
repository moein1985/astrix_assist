part of 'trunk_bloc.dart';

sealed class TrunkEvent {}

final class LoadTrunks extends TrunkEvent {}

final class RefreshTrunks extends TrunkEvent {}

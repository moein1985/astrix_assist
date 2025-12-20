import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trunk.dart';
import '../../domain/usecases/get_trunks_usecase.dart';

part 'trunk_event.dart';
part 'trunk_state.dart';

class TrunkBloc extends Bloc<TrunkEvent, TrunkState> {
  final GetTrunksUseCase getTrunksUseCase;

  TrunkBloc({required this.getTrunksUseCase}) : super(const TrunkInitial()) {
    on<LoadTrunks>(_onLoadTrunks);
    on<RefreshTrunks>(_onRefreshTrunks);
  }

  Future<void> _onLoadTrunks(LoadTrunks event, Emitter<TrunkState> emit) async {
    try {
      emit(const TrunkLoading());
      final trunks = await getTrunksUseCase();
      emit(TrunkLoaded(trunks));
    } catch (e) {
      emit(TrunkError(e.toString()));
    }
  }

  Future<void> _onRefreshTrunks(
    RefreshTrunks event,
    Emitter<TrunkState> emit,
  ) async {
    try {
      final trunks = await getTrunksUseCase();
      emit(TrunkLoaded(trunks));
    } catch (e) {
      emit(TrunkError(e.toString()));
    }
  }
}

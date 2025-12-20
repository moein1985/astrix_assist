import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/result.dart';
import '../../domain/entities/trunk.dart';
import '../../domain/usecases/get_trunks_usecase.dart';

part 'trunk_event.dart';
part 'trunk_state.dart';

class TrunkBloc extends Bloc<TrunkEvent, TrunkState> {
  final GetTrunksUseCase getTrunksUseCase;

  TrunkBloc({required this.getTrunksUseCase}) : super(TrunkInitial()) {
    on<LoadTrunks>(_onLoadTrunks);
    on<RefreshTrunks>(_onRefreshTrunks);
  }

  Future<void> _onLoadTrunks(LoadTrunks event, Emitter<TrunkState> emit) async {
    emit(TrunkLoading());
    final result = await getTrunksUseCase();
    switch (result) {
      case Success(:final data):
        final trunks = data;
        emit(TrunkLoaded(trunks));
      case Failure(:final message):
        emit(TrunkError(message));
    }
  }

  Future<void> _onRefreshTrunks(
    RefreshTrunks event,
    Emitter<TrunkState> emit,
  ) async {
    final result = await getTrunksUseCase();
    switch (result) {
      case Success(:final data):
        final trunks = data;
        emit(TrunkLoaded(trunks));
      case Failure(:final message):
        emit(TrunkError(message));
    }
  }
}

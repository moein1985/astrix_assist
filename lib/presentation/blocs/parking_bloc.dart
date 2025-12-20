import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/parked_call.dart';
import '../../domain/usecases/get_parked_calls_usecase.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final GetParkedCallsUseCase getParkedCallsUseCase;

  ParkingBloc({required this.getParkedCallsUseCase})
    : super(const ParkingInitial()) {
    on<LoadParkedCalls>(_onLoadParkedCalls);
    on<RefreshParkedCalls>(_onRefreshParkedCalls);
    on<PickupCall>(_onPickupCall);
  }

  Future<void> _onLoadParkedCalls(
    LoadParkedCalls event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      emit(const ParkingLoading());
      final parkedCalls = await getParkedCallsUseCase();
      emit(ParkingLoaded(parkedCalls));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onRefreshParkedCalls(
    RefreshParkedCalls event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      final parkedCalls = await getParkedCallsUseCase();
      emit(ParkingLoaded(parkedCalls));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onPickupCall(
    PickupCall event,
    Emitter<ParkingState> emit,
  ) async {
    try {
      // In a real scenario, we would call a PickupParkedCallUseCase
      // For now, we just emit the state
      emit(ParkedCallPickedUp(event.exten));
      // Refresh the list after pickup
      add(const RefreshParkedCalls());
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }
}

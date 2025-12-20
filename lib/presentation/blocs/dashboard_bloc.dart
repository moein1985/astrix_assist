import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/entities/active_call.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_active_calls_usecase.dart';
import '../../core/result.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final GetActiveCallsUseCase getActiveCallsUseCase;

  DashboardBloc(this.getDashboardStatsUseCase, this.getActiveCallsUseCase)
      : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _fetchDashboard(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    await _fetchDashboard(emit);
  }

  Future<void> _fetchDashboard(Emitter<DashboardState> emit) async {
    try {
      

      final statsResult = await getDashboardStatsUseCase.call();
      switch (statsResult) {
        case Failure(:final message):
          
          emit(DashboardError(message));
          return;
        case Success(:final data):
          final stats = data;
          

          final callsResult = await getActiveCallsUseCase.call();
          switch (callsResult) {
            case Failure(:final message):
              
              emit(DashboardError(message));
            case Success(:final data):
              final allCalls = data;
              

              // Get last 5 calls
              final recentCalls = allCalls.take(5).cast<ActiveCall>().toList();
              
              emit(DashboardLoaded(stats, recentCalls));
          }
      }
    } catch (e) {
      
      emit(DashboardError(e.toString()));
    }
  }
}

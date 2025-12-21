import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../domain/entities/active_call.dart';
import '../../domain/entities/system_resource.dart';
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
    on<RefreshSystemResources>(_onRefreshSystemResources);
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

  Future<void> _onRefreshSystemResources(
    RefreshSystemResources event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      // Mock system resource data
      final systemResource = SystemResource(
        uptime: '1 day 2 hours',
        version: 'Asterisk 18.10.0',
        cpuLoad: '15.5',
        freeMemory: '512 MB',
        totalMemory: '1024 MB',
        freeHddSpace: '10 GB',
        totalHddSpace: '50 GB',
        architectureName: 'x86_64',
        boardName: 'Generic PC',
        platform: 'Linux',
      );
      emit(DashboardLoaded(currentState.stats, currentState.recentCalls, systemResource: systemResource));
    }
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
              
              // Mock system resource
              final systemResource = SystemResource(
                uptime: '1 day 2 hours',
                version: 'Asterisk 18.10.0',
                cpuLoad: '15.5',
                freeMemory: '512 MB',
                totalMemory: '1024 MB',
                freeHddSpace: '10 GB',
                totalHddSpace: '50 GB',
                architectureName: 'x86_64',
                boardName: 'Generic PC',
                platform: 'Linux',
              );
              
              emit(DashboardLoaded(stats, recentCalls, systemResource: systemResource));
          }
      }
    } catch (e) {
      
      emit(DashboardError(e.toString()));
    }
  }
}

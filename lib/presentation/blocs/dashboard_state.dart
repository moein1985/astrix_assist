import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/active_call.dart';
import '../../domain/entities/system_resource.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActiveCall> recentCalls;
  final SystemResource? systemResource;

  DashboardLoaded(this.stats, this.recentCalls, {this.systemResource});
}

final class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}

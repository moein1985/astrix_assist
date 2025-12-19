import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/active_call.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ActiveCall> recentCalls;

  DashboardLoaded(this.stats, this.recentCalls);

  @override
  List<Object?> get props => [stats, recentCalls];
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

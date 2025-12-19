import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  DashboardStatsModel({
    required super.totalExtensions,
    required super.onlineExtensions,
    required super.offlineExtensions,
    required super.activeCalls,
    required super.queuedCalls,
    required super.totalQueues,
    required super.averageWaitTime,
    required super.lastUpdate,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalExtensions: json['totalExtensions'] ?? 0,
      onlineExtensions: json['onlineExtensions'] ?? 0,
      offlineExtensions: json['offlineExtensions'] ?? 0,
      activeCalls: json['activeCalls'] ?? 0,
      queuedCalls: json['queuedCalls'] ?? 0,
      totalQueues: json['totalQueues'] ?? 0,
      averageWaitTime: (json['averageWaitTime'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExtensions': totalExtensions,
      'onlineExtensions': onlineExtensions,
      'offlineExtensions': offlineExtensions,
      'activeCalls': activeCalls,
      'queuedCalls': queuedCalls,
      'totalQueues': totalQueues,
      'averageWaitTime': averageWaitTime,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

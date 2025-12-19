class DashboardStats {
  final int totalExtensions;
  final int onlineExtensions;
  final int offlineExtensions;
  final int activeCalls;
  final int queuedCalls;
  final int totalQueues;
  final double averageWaitTime;
  final DateTime lastUpdate;

  DashboardStats({
    required this.totalExtensions,
    required this.onlineExtensions,
    required this.offlineExtensions,
    required this.activeCalls,
    required this.queuedCalls,
    required this.totalQueues,
    required this.averageWaitTime,
    required this.lastUpdate,
  });
}

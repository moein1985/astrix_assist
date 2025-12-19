import '../entities/dashboard_stats.dart';
import '../repositories/iextension_repository.dart';
import '../repositories/imonitor_repository.dart';
import '../../data/models/dashboard_stats_model.dart';

class GetDashboardStatsUseCase {
  final IExtensionRepository extensionRepository;
  final IMonitorRepository monitorRepository;

  GetDashboardStatsUseCase(this.extensionRepository, this.monitorRepository);

  Future<DashboardStats> call() async {
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        extensionRepository.getExtensions(),
        monitorRepository.getActiveCalls(),
        monitorRepository.getQueueStatuses(),
      ]);

      final extensions = results[0] as List;
      final calls = results[1] as List;
      final queues = results[2] as List;

      final totalExtensions = extensions.length;
      final onlineExtensions = extensions.where((e) => e.isOnline).length;
      final offlineExtensions = totalExtensions - onlineExtensions;

      // Calculate queued calls and average wait time
      int queuedCalls = 0;
      double totalWaitTime = 0;
      int queueCount = 0;

      for (final queue in queues) {
        queuedCalls += queue.calls as int;
        if (queue.calls > 0) {
          totalWaitTime += (queue.holdTime as num).toDouble();
          queueCount++;
        }
      }

      final averageWaitTime = queueCount > 0 ? totalWaitTime / queueCount : 0.0;

      return DashboardStatsModel(
        totalExtensions: totalExtensions,
        onlineExtensions: onlineExtensions,
        offlineExtensions: offlineExtensions,
        activeCalls: calls.length,
        queuedCalls: queuedCalls,
        totalQueues: queues.length,
        averageWaitTime: averageWaitTime,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}

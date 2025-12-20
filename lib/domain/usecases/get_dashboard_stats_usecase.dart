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
      print('🟡 [GetDashboardStatsUseCase] Starting to fetch stats...');
      
      // Fetch data sequentially to avoid AMI connection conflicts
      print('🟡 [GetDashboardStatsUseCase] Fetching extensions...');
      final extensions = await extensionRepository.getExtensions();
      print('🟡 [GetDashboardStatsUseCase] Received ${extensions.length} extensions');
      
      print('🟡 [GetDashboardStatsUseCase] Fetching active calls...');
      final calls = await monitorRepository.getActiveCalls();
      print('🟡 [GetDashboardStatsUseCase] Received ${calls.length} active calls');
      
      print('🟡 [GetDashboardStatsUseCase] Fetching queue statuses...');
      final queues = await monitorRepository.getQueueStatuses();
      print('🟡 [GetDashboardStatsUseCase] Received ${queues.length} queues');

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

      print('🟡 [GetDashboardStatsUseCase] Creating DashboardStats model...');
      final dashboardStats = DashboardStatsModel(
        totalExtensions: totalExtensions,
        onlineExtensions: onlineExtensions,
        offlineExtensions: offlineExtensions,
        activeCalls: calls.length,
        queuedCalls: queuedCalls,
        totalQueues: queues.length,
        averageWaitTime: averageWaitTime,
        lastUpdate: DateTime.now(),
      );
      
      print('🟡 [GetDashboardStatsUseCase] Stats calculation complete!');
      return dashboardStats;
    } catch (e) {
      print('⛔ [GetDashboardStatsUseCase] Error: $e');
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}

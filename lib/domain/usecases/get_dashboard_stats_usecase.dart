import '../entities/dashboard_stats.dart';
import '../repositories/iextension_repository.dart';
import '../repositories/imonitor_repository.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../core/result.dart';

class GetDashboardStatsUseCase {
  final IExtensionRepository extensionRepository;
  final IMonitorRepository monitorRepository;

  GetDashboardStatsUseCase(this.extensionRepository, this.monitorRepository);

  Future<Result<DashboardStats>> call() async {
    try {
      

      // Fetch data sequentially to avoid AMI connection conflicts
      
      final extensionsResult = await extensionRepository.getExtensions();
      switch (extensionsResult) {
        case Failure(:final message):
          return Failure('Failed to fetch extensions: $message');
        case Success(:final data):
          final extensions = data;
          

          final callsResult = await monitorRepository.getActiveCalls();
          switch (callsResult) {
            case Failure(:final message):
              return Failure('Failed to fetch active calls: $message');
            case Success(:final data):
              final calls = data;
              

              final queuesResult = await monitorRepository.getQueueStatuses();
              switch (queuesResult) {
                case Failure(:final message):
                  return Failure('Failed to fetch queue statuses: $message');
                case Success(:final data):
                  final queues = data;
                  

                  final totalExtensions = extensions.length;
                  final onlineExtensions = extensions.where((e) => e.isOnline).length;
                  final offlineExtensions = totalExtensions - onlineExtensions;

                  // Calculate queued calls and average wait time
                  int queuedCalls = 0;
                  double totalWaitTime = 0;
                  int queueCount = 0;

                  for (final queue in queues) {
                    queuedCalls += queue.calls;
                    if (queue.calls > 0) {
                      totalWaitTime += (queue.holdTime as num).toDouble();
                      queueCount++;
                    }
                  }

                  final averageWaitTime = queueCount > 0 ? totalWaitTime / queueCount : 0.0;

                  
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

                  
                  return Success(dashboardStats);
              }
          }
      }
    } catch (e) {
      
      return Failure('Failed to fetch dashboard stats: $e');
    }
  }
}

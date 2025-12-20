import '../entities/active_call.dart';
import '../entities/queue_status.dart';

abstract class IMonitorRepository {
  Future<List<ActiveCall>> getActiveCalls();
  Future<List<QueueStatus>> getQueueStatuses();
  Future<void> hangup(String channel);
  Future<void> originate({required String from, required String to, required String context});
  Future<void> transfer({required String channel, required String destination, required String context});
  Future<void> pauseAgent({required String queue, required String interface, required bool paused, String? reason});
}

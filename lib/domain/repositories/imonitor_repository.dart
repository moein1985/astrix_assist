import '../entities/active_call.dart';
import '../entities/queue_status.dart';
import '../../core/result.dart';

abstract class IMonitorRepository {
  Future<Result<List<ActiveCall>>> getActiveCalls();
  Future<Result<List<QueueStatus>>> getQueueStatuses();
  Future<Result<void>> hangup(String channel);
  Future<Result<void>> originate({required String from, required String to, required String context});
  Future<Result<void>> transfer({required String channel, required String destination, required String context});
  Future<Result<void>> pauseAgent({required String queue, required String interface, required bool paused, String? reason});
}

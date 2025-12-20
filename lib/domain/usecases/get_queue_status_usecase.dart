import '../entities/queue_status.dart';
import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class GetQueueStatusUseCase {
  final IMonitorRepository repository;
  GetQueueStatusUseCase(this.repository);

  Future<Result<List<QueueStatus>>> call() async {
    return await repository.getQueueStatuses();
  }
}

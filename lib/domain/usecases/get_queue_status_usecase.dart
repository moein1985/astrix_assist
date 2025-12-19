import '../entities/queue_status.dart';
import '../repositories/imonitor_repository.dart';

class GetQueueStatusUseCase {
  final IMonitorRepository repository;
  GetQueueStatusUseCase(this.repository);

  Future<List<QueueStatus>> call() async {
    return await repository.getQueueStatuses();
  }
}

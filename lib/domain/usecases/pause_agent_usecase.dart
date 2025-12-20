import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class PauseAgentUseCase {
  final IMonitorRepository repository;

  PauseAgentUseCase(this.repository);

  Future<Result<void>> call({
    required String queue,
    required String interface,
    String? reason,
  }) async {
    return repository.pauseAgent(
      queue: queue,
      interface: interface,
      paused: true,
      reason: reason,
    );
  }
}

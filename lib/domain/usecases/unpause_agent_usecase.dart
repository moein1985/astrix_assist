import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class UnpauseAgentUseCase {
  final IMonitorRepository repository;

  UnpauseAgentUseCase(this.repository);

  Future<Result<void>> call({
    required String queue,
    required String interface,
  }) async {
    return repository.pauseAgent(
      queue: queue,
      interface: interface,
      paused: false,
    );
  }
}

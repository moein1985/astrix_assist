import '../repositories/imonitor_repository.dart';

class UnpauseAgentUseCase {
  final IMonitorRepository repository;

  UnpauseAgentUseCase(this.repository);

  Future<void> call({
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

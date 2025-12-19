import '../entities/active_call.dart';
import '../repositories/imonitor_repository.dart';

class GetActiveCallsUseCase {
  final IMonitorRepository repository;
  GetActiveCallsUseCase(this.repository);

  Future<List<ActiveCall>> call() async {
    return await repository.getActiveCalls();
    }
}

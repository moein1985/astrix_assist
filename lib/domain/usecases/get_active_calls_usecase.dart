import '../entities/active_call.dart';
import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class GetActiveCallsUseCase {
  final IMonitorRepository repository;
  GetActiveCallsUseCase(this.repository);

  Future<Result<List<ActiveCall>>> call() async {
    return await repository.getActiveCalls();
  }
}

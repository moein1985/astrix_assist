import '../repositories/imonitor_repository.dart';
import '../entities/parked_call.dart';
import '../../core/result.dart';

class GetParkedCallsUseCase {
  final IMonitorRepository repository;

  GetParkedCallsUseCase(this.repository);

  Future<Result<List<ParkedCall>>> call() async {
    // Note: This method is not implemented in IMonitorRepository yet
    // For now, return empty list
    return Success([]);
  }
}

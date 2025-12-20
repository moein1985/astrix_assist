import '../repositories/imonitor_repository.dart';
import '../entities/trunk.dart';
import '../../core/result.dart';

class GetTrunksUseCase {
  final IMonitorRepository repository;

  GetTrunksUseCase(this.repository);

  Future<Result<List<Trunk>>> call() async {
    // Note: This method is not implemented in IMonitorRepository yet
    // For now, return empty list
    return Success([]);
  }
}

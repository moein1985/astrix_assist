import '../../data/repositories/monitor_repository_impl.dart';
import '../entities/parked_call.dart';

class GetParkedCallsUseCase {
  final MonitorRepositoryImpl repository;

  GetParkedCallsUseCase(this.repository);

  Future<List<ParkedCall>> call() async {
    return await repository.getParkedCalls();
  }
}

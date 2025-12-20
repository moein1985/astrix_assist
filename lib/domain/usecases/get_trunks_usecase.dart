import '../../data/repositories/monitor_repository_impl.dart';
import '../entities/trunk.dart';

class GetTrunksUseCase {
  final MonitorRepositoryImpl repository;

  GetTrunksUseCase(this.repository);

  Future<List<Trunk>> call() async {
    return await repository.getTrunks();
  }
}

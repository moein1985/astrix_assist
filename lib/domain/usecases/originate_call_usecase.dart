import '../repositories/imonitor_repository.dart';

class OriginateCallUseCase {
  final IMonitorRepository repository;
  OriginateCallUseCase(this.repository);

  Future<void> call({required String from, required String to, required String context}) async {
    await repository.originate(from: from, to: to, context: context);
  }
}

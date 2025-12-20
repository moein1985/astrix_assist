import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class HangupCallUseCase {
  final IMonitorRepository repository;
  HangupCallUseCase(this.repository);

  Future<Result<void>> call(String channel) async {
    return await repository.hangup(channel);
  }
}

import '../repositories/imonitor_repository.dart';

class HangupCallUseCase {
  final IMonitorRepository repository;
  HangupCallUseCase(this.repository);

  Future<void> call(String channel) async {
    await repository.hangup(channel);
  }
}

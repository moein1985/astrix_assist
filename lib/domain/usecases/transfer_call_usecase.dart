import '../repositories/imonitor_repository.dart';

class TransferCallUseCase {
  final IMonitorRepository repository;

  TransferCallUseCase(this.repository);

  Future<void> call({
    required String channel,
    required String destination,
    String context = 'from-internal',
  }) async {
    await repository.transfer(
      channel: channel,
      destination: destination,
      context: context,
    );
  }
}

import '../repositories/imonitor_repository.dart';
import '../../core/result.dart';

class TransferCallUseCase {
  final IMonitorRepository repository;

  TransferCallUseCase(this.repository);

  Future<Result<void>> call({
    required String channel,
    required String destination,
    String context = 'from-internal',
  }) async {
    return repository.transfer(
      channel: channel,
      destination: destination,
      context: context,
    );
  }
}

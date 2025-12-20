import '../entities/cdr_record.dart';
import '../repositories/icdr_repository.dart';

class GetCdrRecordsUseCase {
  final ICdrRepository repository;

  GetCdrRecordsUseCase(this.repository);

  Future<List<CdrRecord>> call({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    return await repository.getCdrRecords(
      startDate: startDate,
      endDate: endDate,
      src: src,
      dst: dst,
      disposition: disposition,
      limit: limit,
    );
  }
}

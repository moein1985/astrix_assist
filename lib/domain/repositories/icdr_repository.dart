import '../../domain/entities/cdr_record.dart';
import '../../core/result.dart';

abstract class ICdrRepository {
  Future<Result<List<CdrRecord>>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  });
}

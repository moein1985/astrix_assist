import '../../domain/entities/cdr_record.dart';

abstract class ICdrRepository {
  Future<List<CdrRecord>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  });
}

import '../../domain/entities/cdr_record.dart';
import '../../domain/repositories/icdr_repository.dart';
import '../datasources/cdr_datasource.dart';

class CdrRepositoryImpl implements ICdrRepository {
  final CdrDataSource dataSource;

  CdrRepositoryImpl(this.dataSource);

  @override
  Future<List<CdrRecord>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    return await dataSource.getCdrRecords(
      startDate: startDate,
      endDate: endDate,
      src: src,
      dst: dst,
      disposition: disposition,
      limit: limit,
    );
  }
}

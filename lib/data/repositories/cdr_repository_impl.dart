import '../../domain/entities/cdr_record.dart';
import '../../domain/repositories/icdr_repository.dart';
import '../../core/result.dart';
import '../datasources/ssh_cdr_datasource.dart';

class CdrRepositoryImpl implements ICdrRepository {
  final SshCdrDataSource dataSource;

  CdrRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<CdrRecord>>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    try {
      final records = await dataSource.getCdrRecords(
        startDate: startDate,
        endDate: endDate,
        src: src,
        dst: dst,
        disposition: disposition,
        limit: limit,
      );
      return Success(records);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/result.dart';
import 'package:astrix_assist/domain/usecases/get_cdr_records_usecase.dart';
import 'package:astrix_assist/data/repositories/mock/cdr_repository_mock.dart';
import 'package:astrix_assist/domain/repositories/icdr_repository.dart';

void main() {
  group('End-to-End Feature Tests', () {
    setUpAll(() async {
      // Register mock repository directly for testing
      GetIt.I.registerLazySingleton<ICdrRepository>(
        () => CdrRepositoryMock(),
      );
      GetIt.I.registerFactory(() => GetCdrRecordsUseCase(GetIt.I<ICdrRepository>()));
    });

    tearDownAll(() {
      GetIt.I.reset();
    });

    for (var gen = 1; gen <= 4; gen++) {
      group('Generation $gen', () {
        setUp(() {
          AppConfig.setGeneration(gen);
        });

        test('CDR fetching works for generation $gen', () async {
          // Test CDR fetching for this generation using mock repository
          final getCdrRecordsUseCase = GetIt.I<GetCdrRecordsUseCase>();

          final result = await getCdrRecordsUseCase(
            startDate: DateTime.now().subtract(const Duration(days: 7)),
            endDate: DateTime.now(),
            limit: 10,
          );

          // Should return success with mock data
          expect(result, isA<Success<List>>());
          final success = result as Success<List>;
          expect(success.data, isNotNull);
          expect(success.data.length, greaterThan(0));
        });
      });
    }
  });
}
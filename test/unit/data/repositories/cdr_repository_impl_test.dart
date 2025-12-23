import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:astrix_assist/data/repositories/cdr_repository_impl.dart';
import 'package:astrix_assist/data/datasources/ssh_cdr_datasource.dart';
import 'package:astrix_assist/data/models/cdr_model.dart';
import 'package:astrix_assist/domain/entities/cdr_record.dart';
import 'package:astrix_assist/core/result.dart';

@GenerateMocks([SshCdrDataSource])
import 'cdr_repository_impl_test.mocks.dart';

void main() {
  late CdrRepositoryImpl repository;
  late MockSshCdrDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSshCdrDataSource();
    repository = CdrRepositoryImpl(mockDataSource);
  });

  group('CdrRepositoryImpl', () {
    test('getCdrRecords should return Success when dataSource succeeds', () async {
      // Arrange
      final mockModels = [
        CdrModel(
          callDate: '2025-12-23 10:00:00',
          clid: '"John Doe" <1234>',
          src: '1234',
          dst: '5678',
          dcontext: 'from-internal',
          channel: 'SIP/1234-0001',
          dstChannel: 'SIP/5678-0002',
          lastApp: 'Dial',
          lastData: 'SIP/5678,30,Tt',
          duration: '45',
          billsec: '42',
          disposition: 'ANSWERED',
          amaflags: '3',
          uniqueid: '1734945600.1',
          userfield: '',
        )
      ];

      when(mockDataSource.getCdrRecords(limit: 10))
          .thenAnswer((_) async => mockModels);

      // Act
      final result = await repository.getCdrRecords(limit: 10);

      // Assert
      expect(result, isA<Success<List<CdrRecord>>>());
      final success = result as Success<List<CdrRecord>>;
      expect(success.data.length, 1);
      expect(success.data.first.src, '1234');
      expect(success.data.first.disposition, 'ANSWERED');
    });

    test('getCdrRecords should return Failure when dataSource throws exception', () async {
      // Arrange
      when(mockDataSource.getCdrRecords(limit: 10))
          .thenThrow(Exception('Connection failed'));

      // Act
      final result = await repository.getCdrRecords(limit: 10);

      // Assert
      expect(result, isA<Failure<List<CdrRecord>>>());
      final failure = result as Failure<List<CdrRecord>>;
      expect(failure.message, 'Exception: Connection failed');
    });

    test('getCdrRecords should pass all parameters to dataSource', () async {
      // Arrange
      final startDate = DateTime(2025, 12, 20);
      final endDate = DateTime(2025, 12, 23);

      when(mockDataSource.getCdrRecords(
        startDate: startDate,
        endDate: endDate,
        src: '1234',
        dst: '5678',
        disposition: 'ANSWERED',
        limit: 50,
      )).thenAnswer((_) async => []);

      // Act
      await repository.getCdrRecords(
        startDate: startDate,
        endDate: endDate,
        src: '1234',
        dst: '5678',
        disposition: 'ANSWERED',
        limit: 50,
      );

      // Assert
      verify(mockDataSource.getCdrRecords(
        startDate: startDate,
        endDate: endDate,
        src: '1234',
        dst: '5678',
        disposition: 'ANSWERED',
        limit: 50,
      )).called(1);
    });
  });
}
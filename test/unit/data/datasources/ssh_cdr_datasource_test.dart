import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:astrix_assist/data/datasources/ssh_cdr_datasource.dart';
import 'package:astrix_assist/data/models/cdr_model.dart';
import 'package:astrix_assist/core/services/asterisk_ssh_manager.dart';
import 'package:astrix_assist/core/services/script_models.dart';

@GenerateMocks([AsteriskSshManager])
import 'ssh_cdr_datasource_test.mocks.dart';

void main() {
  late SshCdrDataSource dataSource;
  late MockAsteriskSshManager mockSshManager;

  setUp(() {
    mockSshManager = MockAsteriskSshManager();
    dataSource = SshCdrDataSource(sshManager: mockSshManager);
  });

  group('SshCdrDataSource', () {
    test('getCdrRecords should return list of CdrModel when successful', () async {
      // Arrange
      final mockResponse = ScriptResponse<CdrListResponse>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: CdrListResponse(
          count: 1,
          records: [
            {
              'calldate': '2025-12-23 10:00:00',
              'clid': '"John Doe" <1234>',
              'src': '1234',
              'dst': '5678',
              'dcontext': 'from-internal',
              'channel': 'SIP/1234-0001',
              'dstchannel': 'SIP/5678-0002',
              'lastapp': 'Dial',
              'lastdata': 'SIP/5678,30,Tt',
              'duration': '45',
              'billsec': '42',
              'disposition': 'ANSWERED',
              'amaflags': '3',
              'uniqueid': '1734945600.1',
              'userfield': '',
            }
          ],
        ),
        error: null,
      );

      when(mockSshManager.getCdrs(days: 7, limit: 10))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCdrRecords(limit: 10);

      // Assert
      expect(result, isA<List<CdrModel>>());
      expect(result.length, 1);
      expect(result.first.src, '1234');
      expect(result.first.dst, '5678');
      expect(result.first.disposition, 'ANSWERED');
    });

    test('getCdrRecords should throw exception when SSH response fails', () async {
      // Arrange
      final mockResponse = ScriptResponse<CdrListResponse>(
        success: false,
        error: 'Connection failed',
        errorCode: 'CONNECTION_ERROR',
      );

      when(mockSshManager.getCdrs(days: 7, limit: 10))
          .thenAnswer((_) async => mockResponse);

      // Act & Assert
      expect(
        () => dataSource.getCdrRecords(limit: 10),
        throwsA(isA<Exception>()),
      );
    });

    test('getCdrByUniqueId should return single CdrModel', () async {
      // Arrange
      final uniqueId = '1734945600.1';
      final mockResponse = ScriptResponse<CdrListResponse>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: CdrListResponse(
          count: 1,
          records: [
            {
              'calldate': '2025-12-23 10:00:00',
              'clid': '"John Doe" <1234>',
              'src': '1234',
              'dst': '5678',
              'dcontext': 'from-internal',
              'channel': 'SIP/1234-0001',
              'dstchannel': 'SIP/5678-0002',
              'lastapp': 'Dial',
              'lastdata': 'SIP/5678,30,Tt',
              'duration': '45',
              'billsec': '42',
              'disposition': 'ANSWERED',
              'amaflags': '3',
              'uniqueid': uniqueId,
              'userfield': '',
            }
          ],
        ),
        error: null,
      );

      when(mockSshManager.getCdrs(days: 30, limit: 5000))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCdrByUniqueId(uniqueId);

      // Assert
      expect(result, isA<CdrModel>());
      expect(result!.uniqueid, uniqueId);
      expect(result.src, '1234');
    });

    test('getCdrByUniqueId should return null when record not found', () async {
      // Arrange
      final mockResponse = ScriptResponse<CdrListResponse>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: CdrListResponse(count: 0, records: []),
        error: null,
      );

      when(mockSshManager.getCdrs(days: 30, limit: 5000))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCdrByUniqueId('nonexistent');

      // Assert
      expect(result, isNull);
    });
  });
}
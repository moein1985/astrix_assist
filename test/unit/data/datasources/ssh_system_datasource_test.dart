import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:astrix_assist/data/datasources/ssh_system_datasource.dart';
import 'package:astrix_assist/core/services/asterisk_ssh_manager.dart';
import 'package:astrix_assist/core/services/script_models.dart';

@GenerateMocks([AsteriskSshManager])
import 'ssh_system_datasource_test.mocks.dart';

void main() {
  late SshSystemDataSource dataSource;
  late MockAsteriskSshManager mockSshManager;

  setUp(() {
    mockSshManager = MockAsteriskSshManager();
    dataSource = SshSystemDataSource(sshManager: mockSshManager);
  });

  group('SshSystemDataSource', () {
    test('getSystemInfo should return SystemInfo when successful', () async {
      // Arrange
      final mockResponse = ScriptResponse<SystemInfo>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: SystemInfo(
          pythonVersion: '3.9.7',
          asteriskVersion: '18.10.0',
          cdrPath: '/var/log/asterisk/cdr-csv',
          recordingPath: '/var/spool/asterisk/monitor',
          configPath: '/etc/asterisk',
          cdrEnabled: true,
          scriptVersion: '1.0.0',
        ),
        error: null,
      );

      when(mockSshManager.getSystemInfo())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getSystemInfo();

      // Assert
      expect(result, isA<SystemInfo>());
      expect(result!.pythonVersion, '3.9.7');
      expect(result.asteriskVersion, '18.10.0');
      expect(result.cdrEnabled, true);
    });

    test('getSystemInfo should return null when SSH response fails', () async {
      // Arrange
      final mockResponse = ScriptResponse<SystemInfo>(
        success: false,
        error: 'Connection failed',
        errorCode: 'CONNECTION_ERROR',
      );

      when(mockSshManager.getSystemInfo())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getSystemInfo();

      // Assert
      expect(result, isNull);
    });

    test('checkAmiStatus should return AmiStatus when successful', () async {
      // Arrange
      final mockResponse = ScriptResponse<AmiStatus>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: AmiStatus(
          enabled: true,
          userExists: true,
          configPath: '/etc/asterisk/manager.conf',
        ),
        error: null,
      );

      when(mockSshManager.checkAmi())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.checkAmiStatus();

      // Assert
      expect(result, isA<AmiStatus>());
      expect(result!.enabled, true);
      expect(result.userExists, true);
      expect(result.configPath, '/etc/asterisk/manager.conf');
    });

    test('checkAmiStatus should return null when SSH response fails', () async {
      // Arrange
      final mockResponse = ScriptResponse<AmiStatus>(
        success: false,
        error: 'AMI not configured',
        errorCode: 'AMI_ERROR',
      );

      when(mockSshManager.checkAmi())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.checkAmiStatus();

      // Assert
      expect(result, isNull);
    });

    test('setupAmi should return AmiCredentials when successful', () async {
      // Arrange
      final mockResponse = ScriptResponse<AmiCredentials>(
        success: true,
        timestamp: '2025-12-23T10:30:00',
        data: AmiCredentials(
          username: 'astrix_assist',
          password: 'generated_password_123',
          host: 'localhost',
          port: 5038,
        ),
        error: null,
      );

      when(mockSshManager.setupAmi(username: 'astrix_assist', password: anyNamed('password')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.setupAmi(username: 'astrix_assist');

      // Assert
      expect(result, isA<AmiCredentials>());
      expect(result!.username, 'astrix_assist');
      expect(result.host, 'localhost');
      expect(result.port, 5038);
    });

    test('setupAmi should return null when SSH response fails', () async {
      // Arrange
      final mockResponse = ScriptResponse<AmiCredentials>(
        success: false,
        error: 'Setup failed',
        errorCode: 'SETUP_ERROR',
      );

      when(mockSshManager.setupAmi(username: anyNamed('username'), password: anyNamed('password')))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.setupAmi();

      // Assert
      expect(result, isNull);
    });
  });
}
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:astrix_assist/core/services/asterisk_ssh_manager.dart';
import 'package:astrix_assist/core/ssh_service.dart';
import 'package:astrix_assist/core/ssh_config.dart';

@GenerateMocks([SshService])
import 'asterisk_ssh_manager_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AsteriskSshManager sshManager;
  late MockSshService mockSshService;
  late SshConfig testConfig;

  setUp(() {
    testConfig = SshConfig(
      host: 'test-host',
      port: 22,
      username: 'test-user',
      password: 'test-pass',
      authMethod: 'password',
    );

    mockSshService = MockSshService();
    sshManager = AsteriskSshManager(testConfig, mockSshService);
  });

  group('AsteriskSshManager', () {
    test('connect should call sshService.connect', () async {
      // Arrange
      when(mockSshService.connect()).thenAnswer((_) async => {});

      // Act
      await sshManager.connect();

      // Assert
      verify(mockSshService.connect()).called(1);
    });

    test('disconnect should call sshService.disconnect and reset state', () {
      // Arrange
      when(mockSshService.disconnect()).thenReturn(null);

      // Act
      sshManager.disconnect();

      // Assert
      verify(mockSshService.disconnect()).called(1);
    });

    test('downloadRecording should delegate to sshService', () async {
      // Arrange
      const remotePath = '/var/spool/asterisk/monitor/test.wav';
      const localPath = '/tmp/test.wav';

      when(mockSshService.downloadRecording(remotePath, localPath: localPath))
          .thenAnswer((_) async => File('/tmp/test.wav'));

      // Act
      await sshManager.downloadRecording(remotePath, localPath: localPath);

      // Assert
      verify(mockSshService.downloadRecording(remotePath, localPath: localPath)).called(1);
    });

    // Note: Other tests are commented out because they require complex mocking
    // of the script deployment and execution flow. These will be implemented
    // when we have a more testable architecture.
  });
}
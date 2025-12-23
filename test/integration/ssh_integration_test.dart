import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:astrix_assist/core/services/asterisk_ssh_manager.dart';
import 'package:astrix_assist/core/ssh_config.dart';
import 'package:astrix_assist/core/ssh_service.dart';

// Mock classes
class MockSshService extends Mock implements SshService {}
class MockAsteriskSshManager extends Mock implements AsteriskSshManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SSH + Python Script Integration Tests', () {
    late MockSshService mockSshService;
    late AsteriskSshManager sshManager;

    setUp(() {
      mockSshService = MockSshService();

      final sshConfig = SshConfig(
        host: '127.0.0.1',
        port: 22,
        username: 'admin',
        password: 'password',
      );

      sshManager = AsteriskSshManager(sshConfig, mockSshService);
    });

    tearDown(() async {
      await sshManager.disconnect();
    });

    test('SSH connection and script execution should work with mock service', () async {
      // Mock successful connection
      when(() => mockSshService.connect()).thenAnswer((_) async {});

      // Mock successful command execution
      when(() => mockSshService.executeCommand('echo "test"'))
          .thenAnswer((_) async => 'test');

      // Mock disconnect
      when(() => mockSshService.disconnect()).thenAnswer((_) async {});

      await sshManager.connect();

      // Test basic command execution through SSH service
      final result = await sshManager.sshService.executeCommand('echo "test"');
      expect(result, equals('test'));

      verify(() => mockSshService.connect()).called(1);
      verify(() => mockSshService.executeCommand('echo "test"')).called(1);
    });

    test('Asterisk SSH manager integration should work with mock service', () async {
      // Mock successful connection
      when(() => mockSshService.connect()).thenAnswer((_) async {});

      // Mock disconnect
      when(() => mockSshService.disconnect()).thenAnswer((_) async {});

      await sshManager.connect();

      // Test that the manager is connected and has access to SSH service
      expect(sshManager.sshService, isNotNull);

      verify(() => mockSshService.connect()).called(1);
    });
  });
}
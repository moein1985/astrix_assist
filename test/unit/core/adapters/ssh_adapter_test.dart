import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/adapters/ssh_adapter.dart';
import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/generation/generation_1_config.dart';
import 'package:astrix_assist/core/generation/generation_2_config.dart';

void main() {
  group('SSHAdapter', () {
    late SSHAdapter adapter;

    setUp(() {
      AppConfig.setGeneration(1);
      adapter = SSHAdapter();
    });

    test('getConnectionParams returns correct parameters', () {
      final params = adapter.getConnectionParams(
        host: '192.168.1.100',
        port: 22,
        username: 'asterisk',
        password: 'password',
      );

      expect(params['host'], '192.168.1.100');
      expect(params['port'], 22);
      expect(params['username'], 'asterisk');
      expect(params['password'], 'password');
      expect(params['pythonPath'], isNotNull);
      expect(params['sshOptions'], isNotNull);
    });

    test('adaptCommand adapts command for current generation', () {
      const command = 'python --version';
      final adapted = adapter.adaptCommand(command);

      expect(adapted, isNotNull);
      expect(adapted, contains('python'));
    });

    test('getPythonExecutable returns correct path', () {
      final pythonPath = adapter.getPythonExecutable();

      expect(pythonPath, isNotNull);
      expect(pythonPath, contains('python'));
    });

    test('supportsPythonFeature checks feature support', () {
      // Test with Generation 1 (older Python)
      AppConfig.setGeneration(1);
      final adapter1 = SSHAdapter();

      // Test with Generation 4 (newer Python)
      AppConfig.setGeneration(4);
      final adapter4 = SSHAdapter();

      // Both should support basic features
      expect(adapter1.supportsPythonFeature('basic'), isA<bool>());
      expect(adapter4.supportsPythonFeature('basic'), isA<bool>());
    });

    test('getSystemPaths returns paths for current generation', () {
      final paths = adapter.getSystemPaths();

      expect(paths, isA<List<String>>());
      expect(paths, isNotEmpty);
    });

    test('validateGeneration returns true for mock validation', () async {
      final isValid = await adapter.validateGeneration();

      expect(isValid, true);
    });

    test('adapts behavior when generation changes', () {
      // Generation 1
      AppConfig.setGeneration(1);
      final adapter1 = SSHAdapter();
      final python1 = adapter1.getPythonExecutable();

      // Generation 4
      AppConfig.setGeneration(4);
      final adapter4 = SSHAdapter();
      final python4 = adapter4.getPythonExecutable();

      // Python paths should be different
      expect(python1, isNot(python4));
    });
  });
}
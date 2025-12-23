import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('AppConfig Generation Tests', () {
    tearDown(() {
      AppConfig.resetGeneration();
    });

    test('default generation is 4', () {
      expect(AppConfig.current.generation, 4);
      expect(AppConfig.current.name, 'Latest');
    });

    test('can set generation at runtime', () {
      AppConfig.setGeneration(1);
      expect(AppConfig.current.generation, 1);
      expect(AppConfig.current.name, 'Legacy');

      AppConfig.setGeneration(2);
      expect(AppConfig.current.generation, 2);
      expect(AppConfig.current.name, 'Transition');
    });

    test('throws error for invalid generation', () {
      expect(
        () => AppConfig.setGeneration(0),
        throwsArgumentError,
      );

      expect(
        () => AppConfig.setGeneration(5),
        throwsArgumentError,
      );
    });

    test('reset returns to default', () {
      AppConfig.setGeneration(1);
      expect(AppConfig.current.generation, 1);

      AppConfig.resetGeneration();
      expect(AppConfig.current.generation, 4);
    });

    test('generation-specific features work', () {
      // Test Gen 1
      AppConfig.setGeneration(1);
      expect(AppConfig.isFeatureSupported('core_show_channels'), false);
      expect(AppConfig.isFeatureSupported('pjsip'), false);

      // Test Gen 4
      AppConfig.setGeneration(4);
      expect(AppConfig.isFeatureSupported('core_show_channels'), true);
      expect(AppConfig.isFeatureSupported('pjsip'), true);
      expect(AppConfig.isFeatureSupported('cel'), true);
    });

    test('AMI port adapts to generation', () {
      AppConfig.setGeneration(1);
      expect(AppConfig.defaultAmiPort, 5038);

      AppConfig.setGeneration(4);
      expect(AppConfig.defaultAmiPort, 5038); // Same for all gens
    });

    test('recording paths are generation-specific', () {
      final date = DateTime(2025, 12, 23);

      AppConfig.setGeneration(1);
      expect(
        AppConfig.getRecordingPath(date),
        '/var/spool/asterisk/monitor',
      );

      AppConfig.setGeneration(2);
      expect(
        AppConfig.getRecordingPath(date),
        '/var/spool/asterisk/monitor/2025/12/23',
      );
    });
  });
}
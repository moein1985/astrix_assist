import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/generation/generation_1_config.dart';
import 'package:astrix_assist/core/generation/generation_2_config.dart';
import 'package:astrix_assist/core/generation/generation_3_config.dart';
import 'package:astrix_assist/core/generation/generation_4_config.dart';

void main() {
  group('Generation Configs', () {
    test('Generation 1 has correct properties', () {
      final config = Generation1Config();

      expect(config.generation, 1);
      expect(config.name, 'Legacy');
      expect(config.osName, 'CentOS');
      expect(config.osVersion, '6.x');
      expect(config.asteriskVersion, '11.x');
      expect(config.pythonVersion, '2.6');
      expect(config.cdrColumnCount, 14);
      expect(config.supportsCoreShowChannels, false);
      expect(config.supportsPJSIP, false);
      expect(config.pythonVersion, '2.6');
    });

    test('Generation 4 has all modern features', () {
      final config = Generation4Config();

      expect(config.generation, 4);
      expect(config.supportsCoreShowChannels, true);
      expect(config.supportsPJSIP, true);
      expect(config.supportsJSON, true);
      expect(config.supportsCEL, true);
      expect(config.cdrColumnCount, 21);
      expect(config.pythonVersion, '3.9');
    });

    test('Recording paths are generation-specific', () {
      final date = DateTime(2025, 12, 23);

      final gen1 = Generation1Config();
      final gen2 = Generation2Config();

      // Gen 1: No date subdirectories
      expect(
        gen1.getRecordingPath(date),
        '/var/spool/asterisk/monitor',
      );

      // Gen 2+: Date subdirectories
      expect(
        gen2.getRecordingPath(date),
        '/var/spool/asterisk/monitor/2025/12/23',
      );
    });

    test('AMI command adaptation works', () {
      final gen1 = Generation1Config();

      // CoreShowChannels not supported in Gen 1
      expect(
        gen1.adaptAMICommand('CoreShowChannels'),
        'Status',
      );

      // Other commands pass through
      expect(
        gen1.adaptAMICommand('SIPpeers'),
        'SIPpeers',
      );
    });

    test('CDR adaptation adds missing fields', () {
      final gen1 = Generation1Config();

      final input = {
        'src': '1003',
        'dst': '09155119004',
        'calldate': '2025-12-23 12:41:27',
      };

      final adapted = gen1.adaptCDRRecord(input);

      // Should add missing fields
      expect(adapted.containsKey('linkedid'), true);
      expect(adapted.containsKey('peeraccount'), true);
      // Should preserve original fields
      expect(adapted['src'], '1003');
      expect(adapted['dst'], '09155119004');
    });

    test('All generations have valid properties', () {
      final configs = [
        Generation1Config(),
        Generation2Config(),
        Generation3Config(),
        Generation4Config(),
      ];

      for (final config in configs) {
        expect(config.generation, greaterThan(0));
        expect(config.generation, lessThanOrEqualTo(4));
        expect(config.name, isNotEmpty);
        expect(config.description, isNotEmpty);
        expect(config.cdrColumnCount, greaterThan(10));
        expect(config.supportedAmiCommands, isNotEmpty);
      }
    });
  });
}
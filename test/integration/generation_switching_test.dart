import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('Generation Switching Integration', () {
    setUp(() {
      AppConfig.resetGeneration();
    });

    test('can switch between all generations', () {
      for (var gen = 1; gen <= 4; gen++) {
        AppConfig.setGeneration(gen);

        final config = AppConfig.current;
        expect(config.generation, gen);

        // Verify generation-specific features
        if (gen == 1) {
          expect(config.supportsCoreShowChannels, false);
        } else {
          expect(config.supportsCoreShowChannels, true);
        }
      }
    });

    test('config properties change with generation', () {
      AppConfig.setGeneration(1);
      final gen1CDRColumns = AppConfig.current.cdrColumnCount;

      AppConfig.setGeneration(4);
      final gen4CDRColumns = AppConfig.current.cdrColumnCount;

      expect(gen4CDRColumns, greaterThan(gen1CDRColumns));
    });
  });
}
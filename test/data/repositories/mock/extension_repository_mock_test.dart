import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/data/repositories/mock/extension_repository_mock.dart';
import 'package:astrix_assist/core/result.dart';

void main() {
  late ExtensionRepositoryMock repository;

  setUp(() {
    repository = ExtensionRepositoryMock();
  });

  group('ExtensionRepositoryMock', () {
    test('getExtensions should return extensions', () async {
      final result = await repository.getExtensions();
      expect(result, isA<Success<List>>());
      final extensions = (result as Success).data;
      expect(extensions.length, greaterThan(0));
    });

    test('extensions should have valid properties', () async {
      final result = await repository.getExtensions();
      expect(result, isA<Success<List>>());
      final extensions = (result as Success).data;
      for (final ext in extensions) {
        expect(ext.name, isNotEmpty);
        expect(ext.isOnline, isA<bool>());
      }
    });
  });
}
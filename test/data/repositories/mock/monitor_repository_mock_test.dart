import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/data/repositories/mock/monitor_repository_mock.dart';
import 'package:astrix_assist/core/result.dart';

void main() {
  late MonitorRepositoryMock repository;

  setUp(() {
    repository = MonitorRepositoryMock();
  });

  group('MonitorRepositoryMock', () {
    test('getActiveCalls should return at least 1 active call', () async {
      final result = await repository.getActiveCalls();
      expect(result, isA<Success<List>>());
      final calls = (result as Success).data;
      expect(calls.length, greaterThanOrEqualTo(1));
    });

    test('getActiveCalls should not include system channels', () async {
      final result = await repository.getActiveCalls();
      expect(result, isA<Success<List>>());
      final calls = (result as Success).data;
      for (final call in calls) {
        expect(call.channel, isNot(contains('Local@')));
        expect(call.channel, isNot(contains('VoiceMail')));
      }
    });

    test('getQueueStatuses should return queue statuses', () async {
      final result = await repository.getQueueStatuses();
      expect(result, isA<Success<List>>());
      final statuses = (result as Success).data;
      expect(statuses.length, greaterThan(0));
    });

    test('mock methods should complete without error', () async {
      final hangupResult = await repository.hangup('test');
      expect(hangupResult, isA<Success<void>>());

      final originateResult = await repository.originate(from: '101', to: '102', context: 'internal');
      expect(originateResult, isA<Success<void>>());

      final transferResult = await repository.transfer(channel: 'test', destination: '103', context: 'internal');
      expect(transferResult, isA<Success<void>>());

      final pauseResult = await repository.pauseAgent(queue: 'support', interface: 'SIP/101', paused: true);
      expect(pauseResult, isA<Success<void>>());
    });
  });
}
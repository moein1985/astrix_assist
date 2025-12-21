import 'package:test/test.dart';
import 'package:astrix_assist/core/ami_api.dart';

void main() {
  group('AmiApi (integration with mock AMI proxy)', () {
    test('getRecordings returns a list', () async {
      final res = await AmiApi.getRecordings();
      expect(res.statusCode, 200);
      expect(res.data, isA<List>());
      expect((res.data as List).isNotEmpty, isTrue);
    });

    test('getRecordingMeta returns metadata for rec1', () async {
      final res = await AmiApi.getRecordingMeta('rec1');
      expect(res.statusCode, 200);
      expect(res.data, isA<Map>());
      expect((res.data as Map).containsKey('url'), isTrue);
    });

    test('originateListen returns job and pollJob observes status', () async {
      final resp = await AmiApi.originateListen({'target': 'SIP/101'});
      expect(resp.statusCode, 200);
      final jobId = resp.data['jobId']?.toString();
      expect(jobId, isNotNull);

      // pollJob should eventually yield a status map containing jobId
      final statuses = <Map<String, dynamic>>[];
      await for (final job in AmiApi.pollJob(jobId!)) {
        statuses.add(job);
        if (job['status'] == 'listening') break;
      }
      expect(statuses.any((m) => m['status'] == 'listening'), isTrue);
    }, timeout: Timeout(Duration(seconds: 10)));
  });
}

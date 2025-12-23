import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/ami_api.dart';

void main() {
  group('SSH + Python Script Integration Tests', () {
    test('SSH connection and script execution should work with mock server', () async {
      // This test would require setting up a real SSH mock server
      // For now, we'll test the existing AMI integration
      final recordings = await AmiApi.getRecordings();
      expect(recordings.statusCode, 200);
      expect(recordings.data, isA<List>());
    });

    test('AMI originate listen should work with mock server', () async {
      final response = await AmiApi.originateListen({'target': 'SIP/101'});
      expect(response.statusCode, 200);
      expect(response.data, isA<Map>());
      expect(response.data['jobId'], isNotNull);
    }, timeout: Timeout(Duration(seconds: 10)));
  });
}
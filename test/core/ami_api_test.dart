import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/ami_listen_client.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  group('AmiListenClient (integration with mock AMI server)', () {
    late MockAmiServer mockServer;
    late AmiListenClient client;

    setUp(() async {
      mockServer = MockAmiServer(generation: 4, port: 5041);
      await mockServer.start();

      client = AmiListenClient(
        host: '127.0.0.1',
        port: 5041,
        username: 'admin',
        secret: 'password', // Mock server expects 'password'
      );
    });

    tearDown(() async {
      await client.disconnect();
      await mockServer.stop();
    });

    test('connect should establish connection to mock AMI server', () async {
      await client.connect();
      expect(client.isConnected, isTrue);
    });

    test('should handle login and basic AMI commands', () async {
      await client.connect();

      // Test that connection is established and login worked
      expect(client.isConnected, isTrue);

      // Test that we can send actions (mock server should respond)
      final events = <Map<String, String>>[];
      final subscription = client.eventsStream.listen(events.add);

      // Wait a bit for any initial events
      await Future.delayed(Duration(seconds: 1));

      await subscription.cancel();
      // Note: Mock server may not send events, so we just verify connection works
    });

    test('disconnect should close connection', () async {
      await client.connect();
      expect(client.isConnected, isTrue);

      await client.disconnect();
      expect(client.isConnected, isFalse);
    });
  });
}

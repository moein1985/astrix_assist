import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import '../../tools/mock_servers/mock_ssh_server.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  group('Mock Server Integration', () {
    late MockSshServer sshServer;
    late MockAmiServer amiServer;

    setUpAll(() async {
      sshServer = MockSshServer(generation: 4, port: 2222);
      amiServer = MockAmiServer(generation: 4, port: 15038);

      await sshServer.start();
      await amiServer.start();
    });

    tearDownAll(() async {
      await sshServer.stop();
      await amiServer.stop();
    });

    test('can connect to mock SSH server at socket level', () async {
      // Test basic socket connection to mock server
      final socket = await Socket.connect('127.0.0.1', 2222);
      expect(socket.remoteAddress.address, '127.0.0.1');
      expect(socket.remotePort, 2222);

      await socket.close();
    });

    test('can connect to mock AMI server at socket level', () async {
      // Test basic socket connection to mock AMI server
      final socket = await Socket.connect('127.0.0.1', 15038);
      expect(socket.remoteAddress.address, '127.0.0.1');
      expect(socket.remotePort, 15038);

      await socket.close();
    });
  });
}
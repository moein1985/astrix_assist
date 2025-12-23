import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../tools/mock_servers/mock_ssh_server.dart';
import '../../tools/mock_servers/mock_ami_server.dart';

void main() {
  group('Mock Servers Integration', () {
    late MockSshServer sshServer;
    late MockAmiServer amiServer;

    setUp(() async {
      sshServer = MockSshServer(generation: 4, port: 2223);
      amiServer = MockAmiServer(generation: 4, port: 5039);

      await Future.wait(<Future<void>>[
        sshServer.start(),
        amiServer.start(),
      ]);
    });

    tearDown(() async {
      await Future.wait(<Future<void>>[
        sshServer.stop(),
        amiServer.stop(),
      ]);
    });

    test('SSH server starts and accepts connections', () async {
      expect(sshServer.isRunning, true);

      // Try to connect to SSH server
      final socket = await Socket.connect('127.0.0.1', 2223);
      expect(socket.remoteAddress.address, '127.0.0.1');
      expect(socket.remotePort, 2223);

      await socket.close();
    });

    test('AMI server starts and accepts connections', () async {
      expect(amiServer.isRunning, true);

      // Try to connect to AMI server
      final socket = await Socket.connect('127.0.0.1', 5039);
      expect(socket.remoteAddress.address, '127.0.0.1');
      expect(socket.remotePort, 5039);

      await socket.close();
    });

    test('SSH server responds to basic commands', () async {
      final socket = await Socket.connect('127.0.0.1', 2223);

      try {
        final responses = <String>[];
        bool bannerReceived = false;
        bool authResponseReceived = false;

        socket.listen(
          (data) {
            final chunk = String.fromCharCodes(data);
            final lines = chunk.split('\n');

            for (final line in lines) {
              if (line.trim().isNotEmpty) {
                responses.add(line.trim());

                if (line.contains('SSH-2.0-MockSSH_Gen4') && !bannerReceived) {
                  bannerReceived = true;
                  // Send authentication after receiving banner
                  socket.write('asterisk\n');
                }

                if (line.contains('Authentication successful') && !authResponseReceived) {
                  authResponseReceived = true;
                }
              }
            }
          },
          onDone: () {},
          onError: (error) {},
        );

        // Wait for banner
        await Future.delayed(Duration(milliseconds: 100));
        expect(responses.any((r) => r.contains('SSH-2.0-MockSSH_Gen4')), true);

        // Wait for auth response
        await Future.delayed(Duration(milliseconds: 100));
        expect(responses.any((r) => r.contains('Authentication successful')), true);
      } finally {
        await socket.close();
      }
    });

    test('AMI server responds to login', () async {
      final socket = await Socket.connect('127.0.0.1', 5039);

      try {
        final responses = <String>[];
        bool greetingReceived = false;
        bool loginResponseReceived = false;

        socket.listen(
          (data) {
            final chunk = String.fromCharCodes(data);
            responses.add(chunk);

            if (chunk.contains('Asterisk Call Manager') && !greetingReceived) {
              greetingReceived = true;
              // Send login after receiving greeting
              socket.write('Action: Login\r\nUsername: admin\r\nSecret: password\r\n\r\n');
            }

            if (chunk.contains('Authentication accepted') && !loginResponseReceived) {
              loginResponseReceived = true;
            }
          },
          onDone: () {},
          onError: (error) {},
        );

        // Wait for greeting
        await Future.delayed(Duration(milliseconds: 100));
        expect(responses.any((r) => r.contains('Asterisk Call Manager')), true);

        // Wait for login response
        await Future.delayed(Duration(milliseconds: 100));
        expect(responses.any((r) => r.contains('Authentication accepted')), true);
      } finally {
        await socket.close();
      }
    });

    test('Mock servers support different generations', () async {
      // Test Generation 1
      final sshServer1 = MockSshServer(generation: 1, port: 2224);
      final amiServer1 = MockAmiServer(generation: 1, port: 5043);

      await Future.wait(<Future<void>>[
        sshServer1.start(),
        amiServer1.start(),
      ]);

      // Test SSH Gen 1
      final socketSSH1 = await Socket.connect('127.0.0.1', 2224);
      final sshResponses1 = <String>[];
      socketSSH1.listen((data) {
        sshResponses1.add(String.fromCharCodes(data).trim());
      });
      await Future.delayed(Duration(milliseconds: 50));
      expect(sshResponses1.any((r) => r.contains('SSH-2.0-MockSSH_Gen1')), true);
      await socketSSH1.close();

      // Test AMI Gen 1
      final socketAMI1 = await Socket.connect('127.0.0.1', 5043);
      final amiResponses1 = <String>[];
      socketAMI1.listen((data) {
        amiResponses1.add(String.fromCharCodes(data));
      });
      await Future.delayed(Duration(milliseconds: 50));
      expect(amiResponses1.any((r) => r.contains('1.1')), true);
      await socketAMI1.close();

      await Future.wait(<Future<void>>[
        sshServer1.stop(),
        amiServer1.stop(),
      ]);

      // Test Generation 4
      final sshServer4 = MockSshServer(generation: 4, port: 2225);
      final amiServer4 = MockAmiServer(generation: 4, port: 5042);

      await Future.wait(<Future<void>>[
        sshServer4.start(),
        amiServer4.start(),
      ]);

      // Test SSH Gen 4
      final socketSSH4 = await Socket.connect('127.0.0.1', 2225);
      final sshResponses4 = <String>[];
      socketSSH4.listen((data) {
        sshResponses4.add(String.fromCharCodes(data).trim());
      });
      await Future.delayed(Duration(milliseconds: 50));
      expect(sshResponses4.any((r) => r.contains('SSH-2.0-MockSSH_Gen4')), true);
      await socketSSH4.close();

      // Test AMI Gen 4
      final socketAMI4 = await Socket.connect('127.0.0.1', 5042);
      final amiResponses4 = <String>[];
      socketAMI4.listen((data) {
        amiResponses4.add(String.fromCharCodes(data));
      });
      await Future.delayed(Duration(milliseconds: 50));
      expect(amiResponses4.any((r) => r.contains('3.0')), true);
      await socketAMI4.close();

      await Future.wait(<Future<void>>[
        sshServer4.stop(),
        amiServer4.stop(),
      ]);
    });
  });
}
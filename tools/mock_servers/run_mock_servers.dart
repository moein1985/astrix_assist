import 'dart:async';
import 'dart:io';
import 'mock_ssh_server.dart';
import 'mock_ami_server.dart';

/// Script to run mock servers for testing
void main(List<String> args) async {
  final generation = _parseGeneration(args);
  final sshPort = _parsePort(args, 'ssh', 2222);
  final amiPort = _parsePort(args, 'ami', 5038);

  print('🚀 Starting Mock Servers for Generation $generation');
  print('SSH Server: localhost:$sshPort');
  print('AMI Server: localhost:$amiPort');
  print('');

  final sshServer = MockSshServer(generation: generation, port: sshPort);
  final amiServer = MockAmiServer(generation: generation, port: amiPort);

  // Start servers
  await Future.wait([
    sshServer.start(),
    amiServer.start(),
  ]);

  print('');
  print('✅ Mock servers are running!');
  print('Press Ctrl+C to stop...');

  // Handle shutdown
  ProcessSignal.sigint.watch().listen((_) async {
    print('');
    print('🛑 Shutting down mock servers...');

    await Future.wait([
      sshServer.stop(),
      amiServer.stop(),
    ]);

    print('✅ Mock servers stopped.');
    exit(0);
  });

  // Keep running
  await Future.delayed(Duration(days: 365)); // Run indefinitely
}

int _parseGeneration(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--generation' || args[i] == '-g') {
      if (i + 1 < args.length) {
        final gen = int.tryParse(args[i + 1]);
        if (gen != null && gen >= 1 && gen <= 4) {
          return gen;
        }
      }
    }
  }

  // Default to generation 4
  return 4;
}

int _parsePort(List<String> args, String type, int defaultPort) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--${type}-port') {
      if (i + 1 < args.length) {
        final port = int.tryParse(args[i + 1]);
        if (port != null && port > 0 && port < 65536) {
          return port;
        }
      }
    }
  }

  return defaultPort;
}
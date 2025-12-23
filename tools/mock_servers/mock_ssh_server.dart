import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Mock SSH Server for testing
class MockSshServer {
  final int generation;
  final int port;
  late ServerSocket _server;
  bool _isRunning = false;

  MockSshServer({
    required this.generation,
    this.port = 2222,
  });

  Future<void> start() async {
    _server = await ServerSocket.bind('127.0.0.1', port);
    _isRunning = true;

    print('Mock SSH Server (Gen $generation) started on port $port');

    _server.listen(_handleConnection);
  }

  void _handleConnection(Socket socket) {
    print('Client connected: ${socket.remoteAddress}:${socket.remotePort}');

    final session = _SshSession(socket, generation);
    session.start();
  }

  Future<void> stop() async {
    _isRunning = false;
    await _server.close();
    print('Mock SSH Server stopped');
  }

  bool get isRunning => _isRunning;
}

class _SshSession {
  final Socket socket;
  final int generation;
  bool _authenticated = false;

  _SshSession(this.socket, this.generation);

  void start() {
    // Send SSH banner
    _sendLine('SSH-2.0-MockSSH_Gen${generation}_1.0');

    socket.listen(
      _handleData,
      onDone: () => print('Client disconnected'),
      onError: (error) => print('Error: $error'),
    );
  }

  void _handleData(List<int> data) {
    final command = utf8.decode(data).trim();

    if (!_authenticated) {
      _handleAuth(command);
      return;
    }

    _handleCommand(command);
  }

  void _handleAuth(String credentials) {
    // Simple mock authentication
    if (credentials.contains('root') || credentials.contains('admin') || credentials.contains('asterisk')) {
      _authenticated = true;
      _sendLine('Authentication successful');
      _sendLine('Welcome to Mock SSH Server (Generation $generation)');
    } else {
      _sendLine('Authentication failed');
      socket.close();
    }
  }

  void _handleCommand(String command) {
    if (command.startsWith('python') || command.startsWith('python2') || command.startsWith('python3')) {
      _handlePythonCommand(command);
    } else if (command == 'ls /var/spool/asterisk/monitor' || command.contains('ls ')) {
      _handleListRecordings(command);
    } else if (command.startsWith('cat ')) {
      _handleCatFile(command);
    } else if (command == 'whoami') {
      _sendLine('asterisk');
    } else if (command == 'pwd') {
      _sendLine('/home/asterisk');
    } else if (command.startsWith('cd ')) {
      _sendLine('Directory changed');
    } else {
      _sendLine('Command not found: $command');
    }
  }

  void _handlePythonCommand(String command) {
    if (command.contains('cdr')) {
      _sendCdrData(command);
    } else if (command.contains('extensions') || command.contains('sip')) {
      _sendExtensionsData();
    } else if (command.contains('--version')) {
      _sendPythonVersion();
    } else {
      _sendLine('Python script executed successfully');
    }
  }

  void _sendCdrData(String command) {
    try {
      // Load fixture data based on generation
      final fixturePath = 'test/fixtures/generation_$generation/cdr_samples.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());

        // Convert to CSV-like output
        final csvLines = <String>[];
        for (final record in data) {
          final csvLine = [
            record['accountcode'] ?? '',
            record['src'] ?? '',
            record['dst'] ?? '',
            record['dcontext'] ?? '',
            record['clid'] ?? '',
            record['channel'] ?? '',
            record['dstchannel'] ?? '',
            record['lastapp'] ?? '',
            record['lastdata'] ?? '',
            record['calldate'] ?? '',
            record['duration'] ?? '',
            record['billsec'] ?? '',
            record['disposition'] ?? '',
            record['amaflags'] ?? '',
          ].join(',');
          csvLines.add(csvLine);
        }

        _sendLine(csvLines.join('\n'));
      } else {
        _sendLine('Error: Fixture data not found for generation $generation');
      }
    } catch (e) {
      _sendLine('Error loading CDR data: $e');
    }
  }

  void _sendExtensionsData() {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/extensions.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final output = data.map((ext) => 'Extension: ${ext['extension']}, Context: ${ext['context']}, Status: ${ext['status']}').join('\n');
        _sendLine(output);
      } else {
        // Generate mock extensions
        final extensions = <String>[];
        for (var i = 100; i < 120; i++) {
          extensions.add('Extension: $i, Context: from-internal, Status: Idle');
        }
        _sendLine(extensions.join('\n'));
      }
    } catch (e) {
      _sendLine('Error loading extensions data: $e');
    }
  }

  void _sendPythonVersion() {
    switch (generation) {
      case 1:
        _sendLine('Python 2.6.6');
        break;
      case 2:
        _sendLine('Python 2.7.5');
        break;
      case 3:
        _sendLine('Python 3.6.8');
        break;
      case 4:
        _sendLine('Python 3.9.7');
        break;
      default:
        _sendLine('Python 2.6.6');
    }
  }

  void _handleListRecordings(String command) {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/recordings.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final paths = data.map((rec) => rec['path']).join('\n');
        _sendLine(paths);
      } else {
        // Generate mock recording list
        final recordings = <String>[];
        for (var i = 0; i < 10; i++) {
          recordings.add('/var/spool/asterisk/monitor/recording_$i.wav');
        }
        _sendLine(recordings.join('\n'));
      }
    } catch (e) {
      _sendLine('Error listing recordings: $e');
    }
  }

  void _handleCatFile(String command) {
    final path = command.substring(4); // Remove 'cat '

    if (path.contains('cdr')) {
      _sendCdrData('python cdr --days 1 --limit 10');
    } else if (path.contains('.wav') || path.contains('.mp3')) {
      _sendLine('Mock audio file content (binary data would be here)');
    } else {
      _sendLine('File content: Mock data for $path');
    }
  }

  void _sendLine(String line) {
    socket.write('$line\n');
  }
}
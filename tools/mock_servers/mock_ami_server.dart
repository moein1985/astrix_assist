import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Mock Asterisk Manager Interface (AMI) Server
class MockAmiServer {
  final int generation;
  final int port;
  late ServerSocket _server;
  bool _isRunning = false;

  MockAmiServer({
    required this.generation,
    this.port = 5038,
  });

  Future<void> start() async {
    _server = await ServerSocket.bind('127.0.0.1', port);
    _isRunning = true;

    print('Mock AMI Server (Gen $generation) started on port $port');

    _server.listen(_handleConnection);
  }

  void _handleConnection(Socket socket) {
    print('AMI Client connected');

    final session = _AmiSession(socket, generation);
    session.start();
  }

  Future<void> stop() async {
    _isRunning = false;
    await _server.close();
    print('Mock AMI Server stopped');
  }

  bool get isRunning => _isRunning;
}

class _AmiSession {
  final Socket socket;
  final int generation;
  bool _authenticated = false;
  final StringBuffer _buffer = StringBuffer();

  _AmiSession(this.socket, this.generation);

  void start() {
    // Send AMI greeting
    _send({
      'Response': 'Success',
      'Message': 'Asterisk Call Manager/${_getAmiVersion()}',
      'ActionID': 'greeting',
    });

    socket.listen(
      _handleData,
      onDone: () => print('AMI Client disconnected'),
      onError: (error) => print('AMI Error: $error'),
    );
  }

  String _getAmiVersion() {
    switch (generation) {
      case 1:
        return '1.1';
      case 2:
        return '2.0';
      case 3:
        return '2.5';
      case 4:
        return '3.0';
      default:
        return '1.0';
    }
  }

  void _handleData(List<int> data) {
    _buffer.write(utf8.decode(data));

    // Process complete messages (messages end with \r\n\r\n)
    final bufferContent = _buffer.toString();
    final messageEndIndex = bufferContent.indexOf('\r\n\r\n');

    if (messageEndIndex != -1) {
      // Extract the complete message
      final messageText = bufferContent.substring(0, messageEndIndex + 4);
      final message = _parseAmiMessage(messageText);

      // Remove processed message from buffer
      _buffer.clear();
      if (bufferContent.length > messageEndIndex + 4) {
        _buffer.write(bufferContent.substring(messageEndIndex + 4));
      }

      // Process the message
      if (message['Action'] == 'Login') {
        _handleLogin(message);
      } else if (!_authenticated) {
        _sendError('Not authenticated');
        return;
      }

      _handleAction(message);
    }
  }

  void _handleAction(Map<String, String> message) {
    final action = message['Action'];

    switch (action) {
      case 'SIPpeers':
        _sendSIPPeers();
        break;
      case 'QueueStatus':
        _sendQueueStatus();
        break;
      case 'Status':
        _sendStatus();
        break;
      case 'CoreShowChannels':
        if (generation >= 2) {
          _sendCoreShowChannels();
        } else {
          _sendError('Command not available in this version');
        }
        break;
      case 'PJSIPShowEndpoints':
        if (generation >= 4) {
          _sendPJSIPEndpoints();
        } else {
          _sendError('Command not available in this version');
        }
        break;
      case 'Logoff':
        _send({
          'Response': 'Goodbye',
          'Message': 'Thanks for using Asterisk!',
          'ActionID': message['ActionID'] ?? '',
        });
        socket.close();
        break;
      default:
        _sendError('Unknown action: $action');
    }
  }

  void _handleLogin(Map<String, String> message) {
    final username = message['Username'];
    final password = message['Secret'];

    // Simple mock authentication
    if ((username == 'admin' || username == 'asterisk') && password == 'password') {
      _authenticated = true;
      _send({
        'Response': 'Success',
        'Message': 'Authentication accepted',
        'ActionID': message['ActionID'] ?? '',
      });
    } else {
      _send({
        'Response': 'Error',
        'Message': 'Authentication failed',
        'ActionID': message['ActionID'] ?? '',
      });
    }
  }

  void _sendSIPPeers() {
    // Load fixture or generate mock data
    try {
      final fixturePath = 'test/fixtures/generation_$generation/ami_responses.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final peers = data['sippeers']['response'] as List;

        for (final peer in peers) {
          _send(peer);
        }
      } else {
        // Generate mock SIP peers
        for (var i = 100; i < 110; i++) {
          _send({
            'Event': 'PeerEntry',
            'Channeltype': 'SIP',
            'ObjectName': '$i',
            'ChanObjectType': 'peer',
            'IPaddress': '192.168.1.$i',
            'IPport': '5060',
            'Dynamic': 'yes',
            'Natsupport': 'yes',
            'VideoSupport': 'yes',
            'TextSupport': 'yes',
            'ACL': 'no',
            'Status': 'OK (${20 + i} ms)',
            'RealtimeDevice': 'no',
          });
        }

        _send({
          'Event': 'PeerlistComplete',
          'EventList': 'Complete',
          'ListItems': '10',
        });
      }
    } catch (e) {
      _sendError('Error loading SIP peers data: $e');
    }
  }

  void _sendQueueStatus() {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/ami_responses.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        _send(data['queue_status']);
      } else {
        _send({
          'Response': 'Success',
          'Event': 'QueueParams',
          'Queue': 'support',
          'Max': '0',
          'Strategy': 'ringall',
          'Calls': '2',
          'Holdtime': '15',
          'TalkTime': '45',
          'Completed': '12',
          'Abandoned': '3',
          'ServiceLevel': '30',
          'ServicelevelPerf': '85.7',
          'Weight': '0',
        });

        // Add some queue entries
        for (var i = 0; i < 2; i++) {
          _send({
            'Event': 'QueueEntry',
            'Queue': 'support',
            'Position': '${i + 1}',
            'Channel': 'SIP/10${i}-000000${i.toRadixString(16)}',
            'CallerIDNum': '091551190${i}',
            'CallerIDName': 'Caller ${i + 1}',
            'Wait': '${30 + i * 15}',
          });
        }

        _send({
          'Event': 'QueueStatusComplete',
          'EventList': 'Complete',
        });
      }
    } catch (e) {
      _sendError('Error loading queue status data: $e');
    }
  }

  void _sendStatus() {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/ami_responses.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final status = data['status']['response'] as List;

        for (final event in status) {
          _send(event);
        }
      } else {
        // Generate mock status
        for (var i = 0; i < 3; i++) {
          _send({
            'Event': 'Status',
            'Privilege': 'Call',
            'Channel': 'SIP/10${i}-000000${i.toRadixString(16)}',
            'CallerIDNum': '10${i}',
            'CallerIDName': 'User ${i + 1}',
            'ConnectedLineNum': '091551190${i}',
            'ConnectedLineName': 'External Call',
            'State': 'Up',
            'Context': 'from-internal',
            'Extension': '091551190${i}',
            'Priority': '1',
            'Seconds': '${10 + i * 5}',
            'Link': 'SIP/trunk-000000${i.toRadixString(16)}',
            'Uniqueid': '${DateTime.now().millisecondsSinceEpoch}.$i',
          });
        }

        _send({
          'Event': 'StatusComplete',
          'Items': '3',
        });
      }
    } catch (e) {
      _sendError('Error loading status data: $e');
    }
  }

  void _sendCoreShowChannels() {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/ami_responses.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final channels = data['core_show_channels']['response'] as List;

        for (final event in channels) {
          _send(event);
        }
      } else {
        // Generate mock core show channels
        for (var i = 0; i < 2; i++) {
          _send({
            'Event': 'CoreShowChannel',
            'ActionID': '12345',
            'Channel': 'SIP/10${i}-000000${i.toRadixString(16)}',
            'ChannelState': '6',
            'ChannelStateDesc': 'Up',
            'CallerIDNum': '10${i}',
            'CallerIDName': 'User ${i + 1}',
            'ConnectedLineNum': '091551190${i}',
            'ConnectedLineName': 'External Call',
            'Language': 'en',
            'AccountCode': '',
            'Context': 'from-internal',
            'Exten': '091551190${i}',
            'Priority': '1',
            'Uniqueid': '${DateTime.now().millisecondsSinceEpoch}.$i',
            'Linkedid': '${DateTime.now().millisecondsSinceEpoch}.$i',
            'Application': 'Dial',
            'ApplicationData': 'SIP/trunk/091551190${i},300,T',
            'Duration': '00:00:${10 + i * 5}',
            'BridgeId': 'bridge_${i}',
          });
        }

        _send({
          'Event': 'CoreShowChannelsComplete',
          'EventList': 'Complete',
          'ActionID': '12345',
          'ListItems': '2',
        });
      }
    } catch (e) {
      _sendError('Error loading core show channels data: $e');
    }
  }

  void _sendPJSIPEndpoints() {
    try {
      final fixturePath = 'test/fixtures/generation_$generation/ami_responses.json';
      final fixture = File(fixturePath);

      if (fixture.existsSync()) {
        final data = json.decode(fixture.readAsStringSync());
        final endpoints = data['pjsip_show_endpoints']['response'] as List;

        for (final event in endpoints) {
          _send(event);
        }
      } else {
        // Generate mock PJSIP endpoints
        for (var i = 200; i < 205; i++) {
          _send({
            'Event': 'EndpointList',
            'ObjectType': 'endpoint',
            'ObjectName': '$i',
            'Transport': 'transport-udp',
            'Aor': '$i',
            'Auths': 'auth$i',
            'OutboundAuths': '',
            'Contacts': 'contact$i',
            'DeviceState': 'Unavailable',
            'ActiveChannels': '0',
          });
        }

        _send({
          'Event': 'EndpointListComplete',
          'EventList': 'Complete',
          'ListItems': '5',
        });
      }
    } catch (e) {
      _sendError('Error loading PJSIP endpoints data: $e');
    }
  }

  void _sendError(String message) {
    _send({
      'Response': 'Error',
      'Message': message,
    });
  }

  void _send(Map<String, dynamic> message) {
    final buffer = StringBuffer();
    message.forEach((key, value) {
      buffer.write('$key: $value\r\n');
    });
    buffer.write('\r\n'); // Empty line to end message

    socket.write(buffer.toString());
  }

  Map<String, String> _parseAmiMessage(String text) {
    // Handle both \r\n and \n line endings
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    final message = <String, String>{};

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      final parts = line.split(':');
      if (parts.length >= 2) {
        message[parts[0].trim()] = parts.sublist(1).join(':').trim();
      }
    }

    return message;
  }
}
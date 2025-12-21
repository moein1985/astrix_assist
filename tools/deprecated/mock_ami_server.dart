import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Mock AMI Server for testing AmiListenClient
/// Simulates Asterisk AMI protocol responses
/// 
/// Run with: dart tools/mock_ami_server.dart
class MockAmiServer {
  ServerSocket? _serverSocket;
  final int port;
  final List<Socket> _clients = [];
  int _actionCounter = 0;

  MockAmiServer({this.port = 5038});

  Future<void> start() async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    print('🚀 Mock AMI Server started on port $port');
    print('📡 Waiting for connections...');
    print('');

    _serverSocket!.listen((Socket client) {
      print('✅ Client connected: ${client.remoteAddress.address}:${client.remotePort}');
      _clients.add(client);
      _handleClient(client);
    });
  }

  void _handleClient(Socket client) {
    // Send welcome banner
    final banner = 'Asterisk Call Manager/1.1\r\n\r\n';
    client.write(banner);
    print('📤 Sent welcome banner');

    client.listen(
      (data) {
        final message = utf8.decode(data);
        print('📥 Received:\n$message');
        _processMessage(client, message);
      },
      onError: (error) {
        print('❌ Client error: $error');
        _clients.remove(client);
      },
      onDone: () {
        print('🔌 Client disconnected: ${client.remoteAddress.address}');
        _clients.remove(client);
      },
    );
  }

  void _processMessage(Socket client, String message) {
    final lines = message.split('\r\n');
    final Map<String, String> data = {};

    for (final line in lines) {
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        data[key] = value;
      }
    }

    if (!data.containsKey('Action')) return;

    final action = data['Action']!;
    final actionId = data['ActionID'] ?? 'unknown';

    print('🎬 Processing action: $action (ID: $actionId)');

    switch (action) {
      case 'Login':
        _handleLogin(client, data);
        break;
      case 'Logoff':
        _handleLogoff(client, data);
        break;
      case 'Originate':
        _handleOriginate(client, data);
        break;
      case 'Hangup':
        _handleHangup(client, data);
        break;
      case 'ControlPlayback':
        _handleControlPlayback(client, data);
        break;
      case 'CoreShowChannels':
        _handleCoreShowChannels(client, data);
        break;
      default:
        _sendError(client, actionId, 'Unknown action: $action');
    }
  }

  void _handleLogin(Socket client, Map<String, String> data) {
    final username = data['Username'];
    final secret = data['Secret'];
    final actionId = data['ActionID'] ?? '';

    // Accept any credentials for testing
    final response = 'Response: Success\r\n'
        'ActionID: $actionId\r\n'
        'Message: Authentication accepted\r\n'
        '\r\n';

    client.write(response);
    print('✅ Login successful: $username');
  }

  void _handleLogoff(Socket client, Map<String, String> data) {
    final actionId = data['ActionID'] ?? '';
    final response = 'Response: Goodbye\r\n'
        'ActionID: $actionId\r\n'
        'Message: Thanks for all the fish.\r\n'
        '\r\n';

    client.write(response);
    print('👋 Logoff');
  }

  void _handleOriginate(Socket client, Map<String, String> data) {
    final actionId = data['ActionID'] ?? '';
    final channel = data['Channel'];
    final application = data['Application'];
    final appData = data['Data'];

    // Send success response
    final response = 'Response: Success\r\n'
        'ActionID: $actionId\r\n'
        'Message: Originate successfully queued\r\n'
        '\r\n';

    client.write(response);
    print('✅ Originate queued: $channel -> $application($appData)');

    // Simulate async originate response after delay
    Future.delayed(Duration(seconds: 1), () {
      _sendOriginateResponse(client, actionId, channel, application, appData);
    });
  }

  void _sendOriginateResponse(
    Socket client,
    String actionId,
    String? channel,
    String? application,
    String? appData,
  ) {
    final event = 'Event: OriginateResponse\r\n'
        'ActionID: $actionId\r\n'
        'Response: Success\r\n'
        'Channel: $channel\r\n'
        'Application: $application\r\n'
        'Data: $appData\r\n'
        'CallerIDNum: <unknown>\r\n'
        'CallerIDName: <unknown>\r\n'
        'Reason: 0\r\n'
        'Uniqueid: 1234567890.${_actionCounter++}\r\n'
        '\r\n';

    client.write(event);
    print('📡 Sent OriginateResponse event');

    // Simulate ChanSpy or Playback events
    if (application == 'ChanSpy') {
      _simulateChanSpyEvents(client, channel!, appData!);
    } else if (application == 'Playback' || application == 'ControlPlayback') {
      _simulatePlaybackEvents(client, channel!, appData!);
    }
  }

  void _simulateChanSpyEvents(Socket client, String spyerChannel, String spyeeChannel) {
    // Extract target channel from ChanSpy data
    final targetChannel = spyeeChannel.split(',').first;

    Future.delayed(Duration(seconds: 1), () {
      final event = 'Event: ChanSpyStart\r\n'
          'SpyerChannel: $spyerChannel\r\n'
          'SpyeeChannel: $targetChannel\r\n'
          'Uniqueid: 1234567890.${_actionCounter++}\r\n'
          '\r\n';

      client.write(event);
      print('📡 Sent ChanSpyStart event');
    });

    // Simulate spy session for 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      final event = 'Event: ChanSpyStop\r\n'
          'SpyerChannel: $spyerChannel\r\n'
          'Uniqueid: 1234567890.${_actionCounter++}\r\n'
          '\r\n';

      client.write(event);
      print('📡 Sent ChanSpyStop event');

      // Send Hangup after spy stops
      _sendHangupEvent(client, spyerChannel);
    });
  }

  void _simulatePlaybackEvents(Socket client, String channel, String filename) {
    Future.delayed(Duration(seconds: 1), () {
      final event = 'Event: PlaybackStart\r\n'
          'Channel: $channel\r\n'
          'Playback: $filename\r\n'
          'Uniqueid: 1234567890.${_actionCounter++}\r\n'
          '\r\n';

      client.write(event);
      print('📡 Sent PlaybackStart event');
    });

    // Simulate playback for 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      final event = 'Event: PlaybackFinish\r\n'
          'Channel: $channel\r\n'
          'Playback: $filename\r\n'
          'Uniqueid: 1234567890.${_actionCounter++}\r\n'
          '\r\n';

      client.write(event);
      print('📡 Sent PlaybackFinish event');

      // Send Hangup after playback finishes
      _sendHangupEvent(client, channel);
    });
  }

  void _sendHangupEvent(Socket client, String channel) {
    final event = 'Event: Hangup\r\n'
        'Channel: $channel\r\n'
        'Cause: 16\r\n'
        'Cause-txt: Normal Clearing\r\n'
        'Uniqueid: 1234567890.${_actionCounter++}\r\n'
        '\r\n';

    client.write(event);
    print('📡 Sent Hangup event');
  }

  void _handleHangup(Socket client, Map<String, String> data) {
    final actionId = data['ActionID'] ?? '';
    final channel = data['Channel'];

    final response = 'Response: Success\r\n'
        'ActionID: $actionId\r\n'
        'Message: Hangup queued\r\n'
        '\r\n';

    client.write(response);
    print('✅ Hangup queued: $channel');

    // Send hangup event
    Future.delayed(Duration(milliseconds: 500), () {
      _sendHangupEvent(client, channel!);
    });
  }

  void _handleControlPlayback(Socket client, Map<String, String> data) {
    final actionId = data['ActionID'] ?? '';
    final channel = data['Channel'];
    final control = data['Control'];

    final response = 'Response: Success\r\n'
        'ActionID: $actionId\r\n'
        'Message: Control sent\r\n'
        '\r\n';

    client.write(response);
    print('✅ ControlPlayback: $channel -> $control');
  }

  void _handleCoreShowChannels(Socket client, Map<String, String> data) {
    final actionId = data['ActionID'] ?? '';

    // Send success response
    final response = 'Response: Success\r\n'
        'ActionID: $actionId\r\n'
        'EventList: start\r\n'
        'Message: Channels will follow\r\n'
        '\r\n';

    client.write(response);

    // Send mock channels
    final channels = [
      {
        'Channel': 'SIP/201-00000001',
        'ChannelState': '6',
        'ChannelStateDesc': 'Up',
        'CallerIDNum': '201',
        'CallerIDName': 'Alice',
        'ConnectedLineNum': '202',
        'ConnectedLineName': 'Bob',
        'Context': 'from-internal',
        'Exten': '202',
        'Priority': '1',
      },
      {
        'Channel': 'SIP/202-00000002',
        'ChannelState': '6',
        'ChannelStateDesc': 'Up',
        'CallerIDNum': '202',
        'CallerIDName': 'Bob',
        'ConnectedLineNum': '201',
        'ConnectedLineName': 'Alice',
        'Context': 'from-internal',
        'Exten': '201',
        'Priority': '1',
      },
    ];

    for (final channelData in channels) {
      final event = 'Event: CoreShowChannel\r\n'
          'ActionID: $actionId\r\n' +
          channelData.entries.map((e) => '${e.key}: ${e.value}').join('\r\n') +
          '\r\nUniqueid: 1234567890.${_actionCounter++}\r\n'
          '\r\n';

      client.write(event);
    }

    // Send complete event
    final complete = 'Event: CoreShowChannelsComplete\r\n'
        'ActionID: $actionId\r\n'
        'EventList: Complete\r\n'
        'ListItems: ${channels.length}\r\n'
        '\r\n';

    client.write(complete);
    print('✅ Sent ${channels.length} channels');
  }

  void _sendError(Socket client, String actionId, String message) {
    final response = 'Response: Error\r\n'
        'ActionID: $actionId\r\n'
        'Message: $message\r\n'
        '\r\n';

    client.write(response);
    print('❌ Error: $message');
  }

  Future<void> stop() async {
    print('🛑 Stopping Mock AMI Server...');
    for (var client in _clients) {
      await client.close();
    }
    _clients.clear();
    await _serverSocket?.close();
    print('✅ Mock AMI Server stopped');
  }
}

void main() async {
  final server = MockAmiServer(port: 5038);
  await server.start();

  print('Press Ctrl+C to stop the server');
  print('');
  print('You can test with:');
  print('  dart run lib/core/ami_listen_client.dart');
  print('');

  // Keep server running
  await ProcessSignal.sigint.watch().first;
  await server.stop();
}

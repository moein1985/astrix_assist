import 'package:astrix_assist/core/ami_listen_client.dart';
import 'package:astrix_assist/core/app_config.dart';

/// Test program for AmiListenClient
/// 
/// Usage:
/// 1. Start mock server: dart tools/mock_ami_server.dart
/// 2. Run this test: dart run tools/test_ami_client.dart
/// 
/// Or test with real Isabel:
/// dart run tools/test_ami_client.dart --real
void main(List<String> args) async {
  final useRealServer = args.contains('--real');
  
  final host = useRealServer ? AppConfig.defaultAmiHost : 'localhost';
  final port = AppConfig.defaultAmiPort;
  final username = AppConfig.defaultAmiUsername;
  final secret = AppConfig.defaultAmiSecret;

  print('🧪 Testing AMI Listen Client');
  print('');
  print('Server: ${useRealServer ? "Real Isabel" : "Mock Server"}');
  print('Host: $host:$port');
  print('Username: $username');
  print('');
  
  final client = AmiListenClient(
    host: host,
    port: port,
    username: username,
    secret: secret,
  );

  // Listen to events
  client.eventsStream.listen((event) {
    print('');
    print('📡 EVENT RECEIVED:');
    event.forEach((key, value) {
      print('   $key: $value');
    });
    print('');
  });

  try {
    // Test 1: Connect and login
    print('─' * 50);
    print('TEST 1: Connect and Login');
    print('─' * 50);
    await client.connect();
    print('✅ Connected and logged in');
    print('');
    
    await Future.delayed(Duration(seconds: 1));

    // Test 2: Get active channels
    print('─' * 50);
    print('TEST 2: Get Active Channels');
    print('─' * 50);
    final channels = await client.getActiveChannels();
    print('Found ${channels.length} active channels:');
    for (final channel in channels) {
      print('  - ${channel['Channel']}: ${channel['CallerIDName']} -> ${channel['ConnectedLineName']}');
    }
    print('');
    
    await Future.delayed(Duration(seconds: 1));

    // Test 3: Originate Listen (ChanSpy)
    print('─' * 50);
    print('TEST 3: Originate Listen Call (ChanSpy)');
    print('─' * 50);
    final listenActionId = await client.originateListen(
      targetChannel: 'SIP/202',
      listenerExtension: '201',
      whisperMode: false,
    );
    print('✅ Listen call originated (ActionID: $listenActionId)');
    print('Waiting 8 seconds for events...');
    await Future.delayed(Duration(seconds: 8));
    print('');

    // Test 4: Originate Playback
    print('─' * 50);
    print('TEST 4: Originate Playback Call');
    print('─' * 50);
    final playbackActionId = await client.originatePlayback(
      targetExtension: '201',
      recordingPath: '/var/spool/asterisk/monitor/test-recording.wav',
      allowControl: true,
    );
    print('✅ Playback call originated (ActionID: $playbackActionId)');
    print('Waiting 3 seconds...');
    await Future.delayed(Duration(seconds: 3));
    print('');

    // Test 5: Control Playback
    print('─' * 50);
    print('TEST 5: Control Playback (Pause)');
    print('─' * 50);
    await client.controlPlayback(
      channel: 'Local/201@playback-context',
      command: 'pause',
    );
    print('✅ Playback paused');
    await Future.delayed(Duration(seconds: 2));
    
    print('');
    print('TEST 5b: Control Playback (Restart)');
    await client.controlPlayback(
      channel: 'Local/201@playback-context',
      command: 'restart',
    );
    print('✅ Playback restarted');
    await Future.delayed(Duration(seconds: 2));
    print('');

    // Test 6: Hangup
    print('─' * 50);
    print('TEST 6: Hangup Channel');
    print('─' * 50);
    await client.hangup('Local/201@playback-context');
    print('✅ Channel hung up');
    await Future.delayed(Duration(seconds: 2));
    print('');

    // Test 7: Disconnect
    print('─' * 50);
    print('TEST 7: Disconnect');
    print('─' * 50);
    await client.disconnect();
    print('✅ Disconnected');
    print('');
    
    print('─' * 50);
    print('✅ ALL TESTS COMPLETED SUCCESSFULLY');
    print('─' * 50);

  } catch (e, stackTrace) {
    print('');
    print('❌ TEST FAILED:');
    print('Error: $e');
    print('Stack trace:');
    print(stackTrace);
  } finally {
    client.dispose();
  }
}

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:logger/logger.dart';

/// AMI TCP Client for Listen and Playback features
/// Connects directly to Asterisk AMI for ChanSpy and Playback operations
class AmiListenClient {
  Socket? _socket;
  final String host;
  final int port;
  final String username;
  final String secret;
  final Logger logger = Logger();
  
  StreamSubscription? _subscription;
  final Map<String, Completer<Map<String, String>>> _pendingActions = {};
  final Map<String, Completer<void>> _pendingAsyncActions = {};
  final StreamController<Map<String, String>> _eventsController = 
      StreamController<Map<String, String>>.broadcast();
  
  /// Stream of AMI events (ChanSpyStart, ChanSpyStop, PlaybackStart, etc.)
  Stream<Map<String, String>> get eventsStream => _eventsController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  String? _currentBuffer;

  AmiListenClient({
    required this.host,
    required this.port,
    required this.username,
    required this.secret,
  });

  /// Connect to Asterisk AMI
  Future<void> connect() async {
    if (_socket != null) {
      logger.w('⚠️ Already connected or connecting, disconnecting first...');
      await disconnect();
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    try {
      logger.i('🔌 Connecting to AMI Listen Client at $host:$port (user: $username)');
      _socket = await Socket.connect(
        host,
        port,
        timeout: Duration(seconds: 10),
      );
      logger.i('✅ Socket connected successfully');
      _setupListener();
      
      // Wait for welcome banner
      await Future.delayed(Duration(milliseconds: 500));
      
      // Login
      await login();
      _isConnected = true;
      logger.i('✅ AMI Listen Client ready');
    } catch (e) {
      logger.e('❌ Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void _setupListener() {
    _currentBuffer = '';
    
    _subscription = _socket!.listen(
      (data) {
        final response = utf8.decode(data);
        _currentBuffer = (_currentBuffer ?? '') + response;
        
        // Process complete AMI messages (separated by \r\n\r\n)
        final messages = _currentBuffer!.split('\r\n\r\n');
        
        // Keep the last incomplete message in buffer
        _currentBuffer = messages.removeLast();
        
        for (final message in messages) {
          if (message.trim().isEmpty) continue;
          _processAmiMessage(message);
        }
      },
      onError: (error) {
        logger.e('❌ Socket error: $error');
        _isConnected = false;
        
        // Complete all pending actions with error
        for (var completer in _pendingActions.values) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
        for (var completer in _pendingAsyncActions.values) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
        _pendingActions.clear();
        _pendingAsyncActions.clear();
      },
      onDone: () {
        logger.i('🔌 Socket disconnected');
        _isConnected = false;
      },
    );
  }

  void _processAmiMessage(String message) {
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
    
    if (data.isEmpty) return;
    
    // Handle responses to actions
    if (data.containsKey('ActionID')) {
      final actionId = data['ActionID']!;
      
      // Check for error response
      if (data['Response'] == 'Error') {
        logger.e('❌ Action $actionId failed: ${data['Message']}');
        if (_pendingActions.containsKey(actionId)) {
          if (!_pendingActions[actionId]!.isCompleted) {
            _pendingActions[actionId]!.completeError(
              Exception('AMI Error: ${data['Message'] ?? 'Unknown error'}')
            );
          }
          _pendingActions.remove(actionId);
        }
        if (_pendingAsyncActions.containsKey(actionId)) {
          if (!_pendingAsyncActions[actionId]!.isCompleted) {
            _pendingAsyncActions[actionId]!.completeError(
              Exception('AMI Error: ${data['Message'] ?? 'Unknown error'}')
            );
          }
          _pendingAsyncActions.remove(actionId);
        }
        return;
      }
      
      // Success response
      if (data['Response'] == 'Success') {
        logger.i('✅ Action $actionId succeeded');
        if (_pendingActions.containsKey(actionId)) {
          if (!_pendingActions[actionId]!.isCompleted) {
            _pendingActions[actionId]!.complete(data);
          }
          _pendingActions.remove(actionId);
        }
        if (_pendingAsyncActions.containsKey(actionId)) {
          if (!_pendingAsyncActions[actionId]!.isCompleted) {
            _pendingAsyncActions[actionId]!.complete();
          }
          _pendingAsyncActions.remove(actionId);
        }
        return;
      }
    }
    
    // Handle events
    if (data.containsKey('Event')) {
      final eventType = data['Event']!;
      logger.i('📡 Event received: $eventType');
      
      // Broadcast to event stream
      _eventsController.add(data);
      
      // Log specific listen/playback events
      switch (eventType) {
        case 'ChanSpyStart':
          logger.i('🎧 ChanSpy started: ${data['SpyerChannel']} -> ${data['SpyeeChannel']}');
          break;
        case 'ChanSpyStop':
          logger.i('🎧 ChanSpy stopped: ${data['SpyerChannel']}');
          break;
        case 'PlaybackStart':
          logger.i('▶️  Playback started: ${data['Playback']}');
          break;
        case 'PlaybackFinish':
          logger.i('⏹️  Playback finished: ${data['Playback']}');
          break;
        case 'OriginateResponse':
          logger.i('📞 Originate response: ${data['Response']} - ${data['Reason']}');
          break;
        case 'Hangup':
          logger.i('📴 Hangup: ${data['Channel']} - ${data['Cause']}');
          break;
      }
    }
  }

  /// Login to AMI
  Future<void> login() async {
    final actionId = _generateActionId();
    final completer = Completer<Map<String, String>>();
    _pendingActions[actionId] = completer;
    
    final cmd = 'Action: Login\r\n'
        'Username: $username\r\n'
        'Secret: $secret\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('🔐 Logging in to AMI...');
    _socket!.write(cmd);
    
    try {
      await completer.future.timeout(Duration(seconds: 5));
      logger.i('✅ Login successful');
    } catch (e) {
      logger.e('❌ Login failed: $e');
      _pendingActions.remove(actionId);
      rethrow;
    }
  }

  /// Originate a call for listening (ChanSpy)
  /// 
  /// Example:
  /// ```dart
  /// await client.originateListen(
  ///   targetChannel: 'SIP/202',
  ///   listenerExtension: '201',
  ///   whisperMode: false,
  /// );
  /// ```
  Future<String> originateListen({
    required String targetChannel,
    required String listenerExtension,
    bool whisperMode = false,
    bool bargeMode = false,
  }) async {
    final actionId = _generateActionId();
    final completer = Completer<void>();
    _pendingAsyncActions[actionId] = completer;
    
    // Determine ChanSpy options
    String spyOptions = 'q'; // quiet mode (no beep)
    if (whisperMode) {
      spyOptions += 'w'; // whisper mode
    }
    if (bargeMode) {
      spyOptions += 'B'; // barge mode
    }
    
    final cmd = 'Action: Originate\r\n'
        'Channel: Local/$listenerExtension@spy-context\r\n'
        'Application: ChanSpy\r\n'
        'Data: $targetChannel,$spyOptions\r\n'
        'CallerID: Listen <$listenerExtension>\r\n'
        'Async: true\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('📞 Originating listen call: $listenerExtension -> $targetChannel (whisper=$whisperMode, barge=$bargeMode)');
    _socket!.write(cmd);
    
    try {
      await completer.future.timeout(Duration(seconds: 10));
      logger.i('✅ Listen call originated (ActionID: $actionId)');
      return actionId;
    } catch (e) {
      logger.e('❌ Originate listen failed: $e');
      _pendingAsyncActions.remove(actionId);
      rethrow;
    }
  }

  /// Originate a call for playing back recorded audio
  /// 
  /// Example:
  /// ```dart
  /// await client.originatePlayback(
  ///   targetExtension: '201',
  ///   recordingPath: '/var/spool/asterisk/monitor/recording.wav',
  /// );
  /// ```
  Future<String> originatePlayback({
    required String targetExtension,
    required String recordingPath,
    bool allowControl = true,
  }) async {
    final actionId = _generateActionId();
    final completer = Completer<void>();
    _pendingAsyncActions[actionId] = completer;
    
    // Remove file extension for Asterisk
    String playbackFile = recordingPath;
    if (playbackFile.endsWith('.wav') || 
        playbackFile.endsWith('.gsm') || 
        playbackFile.endsWith('.mp3')) {
      playbackFile = playbackFile.substring(0, playbackFile.lastIndexOf('.'));
    }
    
    final application = allowControl ? 'ControlPlayback' : 'Playback';
    
    final cmd = 'Action: Originate\r\n'
        'Channel: Local/$targetExtension@playback-context\r\n'
        'Application: $application\r\n'
        'Data: $playbackFile\r\n'
        'CallerID: Playback <system>\r\n'
        'Async: true\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('📞 Originating playback call: $targetExtension <- $recordingPath');
    _socket!.write(cmd);
    
    try {
      await completer.future.timeout(Duration(seconds: 10));
      logger.i('✅ Playback call originated (ActionID: $actionId)');
      return actionId;
    } catch (e) {
      logger.e('❌ Originate playback failed: $e');
      _pendingAsyncActions.remove(actionId);
      rethrow;
    }
  }

  /// Control playback (pause, restart, stop, forward, reverse)
  /// 
  /// Commands:
  /// - 'pause' - Pause playback
  /// - 'restart' - Restart from beginning
  /// - 'stop' - Stop playback
  /// - 'forward' - Skip forward 3 seconds
  /// - 'reverse' - Skip backward 3 seconds
  Future<void> controlPlayback({
    required String channel,
    required String command,
  }) async {
    final actionId = _generateActionId();
    final completer = Completer<void>();
    _pendingAsyncActions[actionId] = completer;
    
    final cmd = 'Action: ControlPlayback\r\n'
        'Channel: $channel\r\n'
        'Control: $command\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('🎮 Controlling playback: $channel -> $command');
    _socket!.write(cmd);
    
    try {
      await completer.future.timeout(Duration(seconds: 5));
      logger.i('✅ Playback control sent');
    } catch (e) {
      logger.e('❌ Control playback failed: $e');
      _pendingAsyncActions.remove(actionId);
      rethrow;
    }
  }

  /// Hangup a channel
  Future<void> hangup(String channel) async {
    final actionId = _generateActionId();
    final completer = Completer<void>();
    _pendingAsyncActions[actionId] = completer;
    
    final cmd = 'Action: Hangup\r\n'
        'Channel: $channel\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('📴 Hanging up channel: $channel');
    _socket!.write(cmd);
    
    try {
      await completer.future.timeout(Duration(seconds: 5));
      logger.i('✅ Hangup successful');
    } catch (e) {
      logger.e('❌ Hangup failed: $e');
      _pendingAsyncActions.remove(actionId);
      rethrow;
    }
  }

  /// Get active channels
  Future<List<Map<String, String>>> getActiveChannels() async {
    final actionId = _generateActionId();
    final completer = Completer<List<Map<String, String>>>();
    final List<Map<String, String>> channels = [];
    
    // Listen for CoreShowChannel events
    final eventSubscription = eventsStream.listen((event) {
      if (event['Event'] == 'CoreShowChannel' && event['ActionID'] == actionId) {
        channels.add(event);
      } else if (event['Event'] == 'CoreShowChannelsComplete' && event['ActionID'] == actionId) {
        if (!completer.isCompleted) {
          completer.complete(channels);
        }
      }
    });
    
    final cmd = 'Action: CoreShowChannels\r\n'
        'ActionID: $actionId\r\n'
        '\r\n';
    
    logger.i('📋 Getting active channels...');
    _socket!.write(cmd);
    
    try {
      final result = await completer.future.timeout(Duration(seconds: 10));
      logger.i('✅ Got ${result.length} active channels');
      return result;
    } catch (e) {
      logger.e('❌ Get channels failed: $e');
      rethrow;
    } finally {
      eventSubscription.cancel();
    }
  }

  /// Generate unique action ID
  String _generateActionId() {
    return 'listen_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Disconnect from AMI
  Future<void> disconnect() async {
    if (_socket == null) return;
    
    logger.i('🔌 Disconnecting from AMI...');
    
    try {
      // Send Logoff action
      _socket!.write('Action: Logoff\r\n\r\n');
      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      logger.w('Error during logoff: $e');
    }
    
    await _subscription?.cancel();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    
    // Clear pending actions
    for (var completer in _pendingActions.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Connection closed'));
      }
    }
    for (var completer in _pendingAsyncActions.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Connection closed'));
      }
    }
    _pendingActions.clear();
    _pendingAsyncActions.clear();
    
    logger.i('✅ Disconnected from AMI');
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _eventsController.close();
  }
}

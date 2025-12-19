import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:logger/logger.dart';

class AmiDataSource {
  Socket? _socket;
  final String host;
  final int port;
  final String username;
  final String secret;
  final Logger logger = Logger();
  StreamSubscription? _subscription;
  Completer<String>? _loginCompleter;
  Completer<List<String>>? _queueCompleter;
  List<String> _queueEvents = [];
  Completer<List<String>>? _callsCompleter;
  List<String> _callEvents = [];
  Completer<List<String>>? _queueStatusCompleter;
  List<String> _queueStatusEvents = [];
  Completer<String>? _hangupCompleter;
  Completer<String>? _originateCompleter;

  AmiDataSource({required this.host, required this.port, required this.username, required this.secret});

  Future<void> connect() async {
    logger.i('Connecting to AMI at $host:$port');
    _socket = await Socket.connect(host, port, timeout: Duration(seconds: 5));
    logger.i('Connected successfully');
    _setupListener();
  }

  void _setupListener() {
    _subscription = _socket!.listen((data) {
      final response = utf8.decode(data);

      if (_loginCompleter != null && !(_loginCompleter!.isCompleted)) {
        if (response.contains('Authentication accepted')) {
          _loginCompleter!.complete('success');
        } else if (response.contains('Authentication failed')) {
          _loginCompleter!.complete('failed');
        }
      }

      if (_queueCompleter != null && !(_queueCompleter!.isCompleted)) {
        final events = response.split(RegExp('\\r\\n\\r\\n|\\n\\n'));
        for (final event in events) {
          if (event.contains('Event: PeerEntry')) {
            _queueEvents.add(event);
          }
          if (event.contains('Event: PeerlistComplete')) {
            if (!_queueCompleter!.isCompleted) {
              _queueCompleter!.complete(_queueEvents);
            }
          }
        }
      }

      if (_callsCompleter != null && !(_callsCompleter!.isCompleted)) {
        final events = response.split(RegExp('\\r\\n\\r\\n|\\n\\n'));
        for (final event in events) {
          if (event.contains('Event: CoreShowChannel')) {
            _callEvents.add(event);
          }
          if (event.contains('Event: CoreShowChannelsComplete')) {
            if (!_callsCompleter!.isCompleted) {
              _callsCompleter!.complete(_callEvents);
            }
          }
        }
      }

      if (_queueStatusCompleter != null && !(_queueStatusCompleter!.isCompleted)) {
        final events = response.split(RegExp('\\r\\n\\r\\n|\\n\\n'));
        for (final event in events) {
          if (event.contains('Event: QueueParams') || event.contains('Event: QueueMember') || event.contains('Event: QueueEntry')) {
            _queueStatusEvents.add(event);
          }
          if (event.contains('Event: QueueStatusComplete')) {
            if (!_queueStatusCompleter!.isCompleted) {
              _queueStatusCompleter!.complete(_queueStatusEvents);
            }
          }
        }
      }

      if (_hangupCompleter != null && !(_hangupCompleter!.isCompleted)) {
        if (response.contains('Response: Success') || response.contains('Event: Hangup')) {
          _hangupCompleter!.complete('success');
        } else if (response.contains('Response: Error')) {
          _hangupCompleter!.completeError(Exception('Hangup failed'));
        }
      }

      if (_originateCompleter != null && !(_originateCompleter!.isCompleted)) {
        if (response.contains('Response: Success')) {
          _originateCompleter!.complete('success');
        } else if (response.contains('Response: Error')) {
          _originateCompleter!.completeError(Exception('Originate failed'));
        }
      }
    }, onError: (error) {
      logger.e('Socket error: $error');
      _loginCompleter?.completeError(error);
      _queueCompleter?.completeError(error);
      _callsCompleter?.completeError(error);
      _queueStatusCompleter?.completeError(error);
      _hangupCompleter?.completeError(error);
      _originateCompleter?.completeError(error);
    }, onDone: () {
      logger.i('Socket done');
    });
  }

  Future<String> login() async {
    _loginCompleter = Completer<String>();
    final loginCmd = 'Action: Login\r\nUsername: $username\r\nSecret: $secret\r\n\r\n';
    logger.i('Sending login command');
    _socket!.write(loginCmd);
    return _loginCompleter!.future;
  }

  Future<List<String>> getQueueStatus() async {
    _queueCompleter = Completer<List<String>>();
    _queueEvents = [];
    final cmd = 'Action: SIPpeers\r\n\r\n';  // تغییر به SIPpeers برای گرفتن extensions
    logger.i('Sending SIPpeers command');
    _socket!.write(cmd);
    return _queueCompleter!.future.timeout(Duration(seconds: 10));
  }

  Future<List<String>> getActiveCalls() async {
    _callsCompleter = Completer<List<String>>();
    _callEvents = [];
    final cmd = 'Action: CoreShowChannels\r\n\r\n';
    logger.i('Sending CoreShowChannels command');
    _socket!.write(cmd);
    return _callsCompleter!.future.timeout(Duration(seconds: 10));
  }

  Future<List<String>> getQueueStatuses() async {
    _queueStatusCompleter = Completer<List<String>>();
    _queueStatusEvents = [];
    final cmd = 'Action: QueueStatus\r\n\r\n';
    logger.i('Sending QueueStatus command');
    _socket!.write(cmd);
    return _queueStatusCompleter!.future.timeout(Duration(seconds: 10));
  }

  Future<String> hangup(String channel) async {
    _hangupCompleter = Completer<String>();
    final cmd = 'Action: Hangup\r\nChannel: $channel\r\n\r\n';
    logger.i('Sending Hangup for $channel');
    _socket!.write(cmd);
    return _hangupCompleter!.future.timeout(Duration(seconds: 5));
  }

  Future<String> originate({required String channel, required String exten, required String context, int priority = 1}) async {
    _originateCompleter = Completer<String>();
    final cmd = 'Action: Originate\r\nChannel: $channel\r\nExten: $exten\r\nContext: $context\r\nPriority: $priority\r\nAsync: true\r\n\r\n';
    logger.i('Sending Originate from $channel to $exten');
    _socket!.write(cmd);
    return _originateCompleter!.future.timeout(Duration(seconds: 8));
  }

  void disconnect() {
    logger.i('Disconnecting from AMI');
    _subscription?.cancel();
    _socket?.destroy();
  }
}
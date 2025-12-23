import 'package:flutter/material.dart';
import 'package:astrix_assist/core/ami_listen_client.dart';
import 'package:astrix_assist/core/app_config.dart';

/// Example Flutter page demonstrating AmiListenClient usage
/// 
/// This shows how to integrate the AMI client with Flutter UI
class AmiListenExample extends StatefulWidget {
  const AmiListenExample({super.key});

  @override
  State<AmiListenExample> createState() => _AmiListenExampleState();
}

class _AmiListenExampleState extends State<AmiListenExample> {
  AmiListenClient? _client;
  bool _isConnected = false;
  final List<String> _events = [];
  String? _activeListenActionId;
  String? _activePlaybackActionId;

  @override
  void initState() {
    super.initState();
    _initClient();
  }

  void _initClient() {
    _client = AmiListenClient(
      host: AppConfig.defaultAmiHost,
      port: AppConfig.defaultAmiPort,
      username: AppConfig.defaultAmiUsername,
      secret: AppConfig.defaultAmiSecret,
    );

    // Listen to AMI events
    _client!.eventsStream.listen((event) {
      if (!mounted) return;
      
      final eventType = event['Event'] ?? 'Unknown';
      final timestamp = DateTime.now().toString().substring(11, 19);
      
      setState(() {
        _events.insert(0, '[$timestamp] $eventType');
        
        // Track active sessions
        if (eventType == 'ChanSpyStart') {
          // Listen session started
        } else if (eventType == 'ChanSpyStop') {
          _activeListenActionId = null;
        } else if (eventType == 'PlaybackStart') {
          // Playback started
        } else if (eventType == 'PlaybackFinish') {
          _activePlaybackActionId = null;
        }
      });
    });
  }

  Future<void> _connect() async {
    try {
      await _client!.connect();
      setState(() {
        _isConnected = true;
        _events.insert(0, '[${_timestamp()}] Connected to AMI');
      });
      _showSnackBar('Connected to Isabel AMI', isError: false);
    } catch (e) {
      _showSnackBar('Connection failed: $e', isError: true);
    }
  }

  Future<void> _disconnect() async {
    try {
      await _client!.disconnect();
      setState(() {
        _isConnected = false;
        _activeListenActionId = null;
        _activePlaybackActionId = null;
        _events.insert(0, '[${_timestamp()}] Disconnected from AMI');
      });
      _showSnackBar('Disconnected', isError: false);
    } catch (e) {
      _showSnackBar('Disconnect failed: $e', isError: true);
    }
  }

  Future<void> _startListen() async {
    if (!_isConnected) {
      _showSnackBar('Not connected to AMI', isError: true);
      return;
    }

    try {
      final actionId = await _client!.originateListen(
        targetChannel: 'SIP/202', // Channel to listen to
        listenerExtension: '201', // Extension that will listen
        whisperMode: false,
      );
      
      setState(() {
        _activeListenActionId = actionId;
        _events.insert(0, '[${_timestamp()}] Started listening (ID: $actionId)');
      });
      
      _showSnackBar('Listen session started', isError: false);
    } catch (e) {
      _showSnackBar('Failed to start listening: $e', isError: true);
    }
  }

  Future<void> _startPlayback() async {
    if (!_isConnected) {
      _showSnackBar('Not connected to AMI', isError: true);
      return;
    }

    try {
      final actionId = await _client!.originatePlayback(
        targetExtension: '201',
        recordingPath: '/var/spool/asterisk/monitor/test-recording.wav',
        allowControl: true,
      );
      
      setState(() {
        _activePlaybackActionId = actionId;
        _events.insert(0, '[${_timestamp()}] Started playback (ID: $actionId)');
      });
      
      _showSnackBar('Playback started', isError: false);
    } catch (e) {
      _showSnackBar('Failed to start playback: $e', isError: true);
    }
  }

  Future<void> _pausePlayback() async {
    if (!_isConnected || _activePlaybackActionId == null) {
      _showSnackBar('No active playback', isError: true);
      return;
    }

    try {
      await _client!.controlPlayback(
        channel: 'Local/201@playback-context',
        command: 'pause',
      );
      
      _showSnackBar('Playback paused', isError: false);
    } catch (e) {
      _showSnackBar('Failed to pause: $e', isError: true);
    }
  }

  Future<void> _stopSession() async {
    if (!_isConnected) {
      _showSnackBar('Not connected to AMI', isError: true);
      return;
    }

    try {
      // Hangup the active channel
      if (_activeListenActionId != null) {
        await _client!.hangup('Local/201@spy-context');
      } else if (_activePlaybackActionId != null) {
        await _client!.hangup('Local/201@playback-context');
      }
      
      setState(() {
        _activeListenActionId = null;
        _activePlaybackActionId = null;
      });
      
      _showSnackBar('Session stopped', isError: false);
    } catch (e) {
      _showSnackBar('Failed to stop session: $e', isError: true);
    }
  }

  String _timestamp() {
    return DateTime.now().toString().substring(11, 19);
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _client?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AMI Listen Client Test'),
        backgroundColor: _isConnected ? Colors.green : Colors.grey,
      ),
      body: Column(
        children: [
          // Connection controls
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.cancel,
                        color: _isConnected ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(_isConnected ? 'Connected' : 'Disconnected'),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _isConnected ? _disconnect : _connect,
                        child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action controls
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isConnected && _activeListenActionId == null 
                            ? _startListen 
                            : null,
                        icon: Icon(Icons.headset),
                        label: Text('Start Listen'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isConnected && _activePlaybackActionId == null 
                            ? _startPlayback 
                            : null,
                        icon: Icon(Icons.play_arrow),
                        label: Text('Start Playback'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isConnected && _activePlaybackActionId != null 
                            ? _pausePlayback 
                            : null,
                        icon: Icon(Icons.pause),
                        label: Text('Pause'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isConnected && 
                                  (_activeListenActionId != null || 
                                   _activePlaybackActionId != null)
                            ? _stopSession 
                            : null,
                        icon: Icon(Icons.stop),
                        label: Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Events log
          Expanded(
            child: Card(
              margin: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Events Log',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _events.clear();
                            });
                          },
                          child: Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: _events.isEmpty
                        ? Center(
                            child: Text(
                              'No events yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  _events[index],
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A resilient SSE (Server-Sent Events) client with automatic reconnection.
/// Handles network errors and reconnects with exponential backoff.
class SseClient {
  final String url;
  final Map<String, String> headers;
  final Duration reconnectDelay;
  final Duration maxReconnectDelay;
  final int maxRetries;

  StreamController<Map<String, dynamic>>? _controller;
  HttpClient? _client;
  HttpClientRequest? _request;
  HttpClientResponse? _response;
  int _retryCount = 0;
  bool _isClosed = false;
  Timer? _reconnectTimer;

  SseClient({
    required this.url,
    this.headers = const {},
    this.reconnectDelay = const Duration(seconds: 2),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.maxRetries = 10,
  });

  /// Get a stream of events from the SSE endpoint.
  /// Automatically reconnects on errors up to [maxRetries] times.
  Stream<Map<String, dynamic>> get stream {
    _controller ??= StreamController<Map<String, dynamic>>(
      onListen: _connect,
      onCancel: close,
    );
    return _controller!.stream;
  }

  Future<void> _connect() async {
    if (_isClosed) return;

    try {
      _client = HttpClient();
      final uri = Uri.parse(url);
      _request = await _client!.getUrl(uri);
      
      // Add headers
      headers.forEach((key, value) {
        _request!.headers.add(key, value);
      });
      _request!.headers.add('Accept', 'text/event-stream');
      _request!.headers.add('Cache-Control', 'no-cache');

      _response = await _request!.close();

      if (_response!.statusCode != 200) {
        _handleError('SSE connection failed with status ${_response!.statusCode}');
        return;
      }

      // Reset retry count on successful connection
      _retryCount = 0;

      // Parse SSE stream
      await for (final chunk in _response!.transform(utf8.decoder).transform(const LineSplitter())) {
        if (_isClosed) break;
        
        if (chunk.startsWith('data: ')) {
          final data = chunk.substring(6);
          try {
            final parsed = jsonDecode(data);
            if (parsed is Map<String, dynamic>) {
              _controller?.add(parsed);
            }
          } catch (_) {
            // Skip invalid JSON
          }
        }
      }

      // Connection closed normally
      if (!_isClosed) {
        _scheduleReconnect();
      }
    } catch (e) {
      if (!_isClosed) {
        _handleError('SSE error: $e');
      }
    }
  }

  void _handleError(String message) {
    if (_isClosed) return;

    _cleanupConnection();

    if (_retryCount < maxRetries) {
      _scheduleReconnect();
    } else {
      _controller?.addError(message);
      close();
    }
  }

  void _scheduleReconnect() {
    if (_isClosed) return;

    _retryCount++;
    
    // Exponential backoff with max delay
    final delay = Duration(
      milliseconds: (reconnectDelay.inMilliseconds * (1 << (_retryCount - 1)))
          .clamp(reconnectDelay.inMilliseconds, maxReconnectDelay.inMilliseconds),
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, _connect);
  }

  void _cleanupConnection() {
    _request = null;
    _response = null;
    _client?.close(force: true);
    _client = null;
  }

  /// Close the SSE connection and clean up resources.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _cleanupConnection();

    await _controller?.close();
    _controller = null;
  }
}

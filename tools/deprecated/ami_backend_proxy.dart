import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Simple configurable AMI proxy for local testing and gradual replacement of the mock.
/// Usage:
/// - Simulate mode (default): dart run tools/ami_backend_proxy.dart
/// - Proxy mode (forward to real AMI HTTP adapter):
///     AMI_PROXY_FORWARD=http://real-ami-adapter:8080 dart run tools/ami_backend_proxy.dart
/// Security:
/// - Expects header `Authorization: Bearer <token>`; token 'test-token' accepted in simulate mode.

final _auditFile = File('tools/ami_backend_audit.log');
Database? _db;
bool _dbInitialized = false;

/// Parse JWT token and extract user_id and role from claims.
/// Returns a map with 'userId' and 'role' keys, or null if invalid.
/// For local testing, accepts 'test-token' as a special case.
Map<String, String>? _parseJwt(String token) {
  if (token == 'test-token') {
    // Special test token for local development
    return {'userId': 'test-user', 'role': 'supervisor'};
  }

  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    // Decode payload (second part)
    var payload = parts[1];
    // Add padding if needed
    switch (payload.length % 4) {
      case 2:
        payload += '==';
        break;
      case 3:
        payload += '=';
        break;
    }

    final decoded = utf8.decode(base64Url.decode(payload));
    final claims = jsonDecode(decoded) as Map<String, dynamic>;

    // Extract user_id and role from claims
    // Common JWT claims: sub (subject/user_id), role, roles, scope
    final userId = claims['sub']?.toString() ?? 
                   claims['user_id']?.toString() ?? 
                   claims['userId']?.toString();
    
    final role = claims['role']?.toString() ?? 
                 claims['roles']?.toString() ?? 
                 claims['scope']?.toString() ?? 
                 'user';

    if (userId == null) return null;

    return {'userId': userId, 'role': role};
  } catch (e) {
    stderr.writeln('JWT parse error: $e');
    return null;
  }
}

void main(List<String> args) async {
  final ip = InternetAddress.loopbackIPv4;
  final port = int.tryParse(Platform.environment['AMI_BACKEND_PORT'] ?? '') ?? 8081;
  final forwardTo = Platform.environment['AMI_PROXY_FORWARD'];
  final simulate = forwardTo == null;

  final server = await HttpServer.bind(ip, port);
  stderr.writeln('AMI backend proxy running at http://${ip.address}:$port/ (simulate=$simulate)');

  final jobs = <String, String>{};
  final sseControllers = <StreamController<String>>[];

  // Initialize database
  _ensureDb();

  await for (final req in server) {
    // Handle requests asynchronously
    _handleRequest(req, simulate, forwardTo, ip, port, jobs, sseControllers);
  }
}

void _handleRequest(HttpRequest req, bool simulate, String? forwardTo, InternetAddress ip, int port, Map<String, String> jobs, List<StreamController<String>> sseControllers) async {
  try {
    final path = req.uri.path;

    // Authorization handling
    final auth = req.headers.value(HttpHeaders.authorizationHeader);
    if (auth == null || !auth.startsWith('Bearer ')) {
      _json(req, {'error': 'Missing Authorization header'}, status: HttpStatus.unauthorized);
      return;
    }

    final token = auth.substring(7);
    final jwtData = _parseJwt(token);
    
    if (jwtData == null) {
      _json(req, {'error': 'Invalid or expired token'}, status: HttpStatus.forbidden);
      return;
    }

    final userId = jwtData['userId']!;
    final role = jwtData['role']!;

    // basic audit to file with user_id
    unawaited(_audit({'method': req.method, 'path': path, 'user_id': userId, 'role': role, 'time': DateTime.now().toIso8601String()}));

    if (path == '/recordings' && req.method == 'GET') {
      if (simulate) {
        final list = [
          {'id': 'rec1', 'filename': 'sample1.mp3', 'url': 'http://${ip.address}:$port/recordings/rec1/stream'},
        ];
        _json(req, list);
        return;
      } else {
        final res = await _forwardGet(forwardTo!, req.uri.path);
        final bytes = await _collectResponseBytes(res);
        _raw(req, res.statusCode, bytes, res.headers.contentType?.value);
        return;
      }
    }

    if (path.startsWith('/recordings/') && req.method == 'GET') {
      final parts = path.split('/').where((s) => s.isNotEmpty).toList();
      if (parts.length >= 2) {
        final id = parts[1];
        if (parts.length == 3 && parts[2] == 'stream') {
          if (simulate) {
            req.response.statusCode = HttpStatus.found;
            req.response.headers.set(HttpHeaders.locationHeader, 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3');
            await req.response.close();
            return;
          } else {
            final res = await _forwardGet(forwardTo!, req.uri.path);
            final bytes = await _collectResponseBytes(res);
            _raw(req, res.statusCode, bytes, res.headers.contentType?.value);
            return;
          }
        }

        if (simulate) {
          final meta = {'id': id, 'filename': 'sample1.mp3', 'url': 'http://${ip.address}:$port/recordings/$id/stream'};
          _json(req, meta);
          return;
        } else {
          final res = await _forwardGet(forwardTo!, req.uri.path);
          final bytes = await _collectResponseBytes(res);
          _raw(req, res.statusCode, bytes, res.headers.contentType?.value);
          return;
        }
      }
    }

    if (path == '/ami/originate/listen' && req.method == 'POST') {
      final body = await utf8.decoder.bind(req).join();
      final payload = body.isNotEmpty ? jsonDecode(body) : {};
      // require supervisor/qa roles
      if (!(role == 'supervisor' || role == 'qa' || role == 'admin')) {
        _json(req, {'error': 'forbidden: insufficient role'}, status: HttpStatus.forbidden);
        return;
      }

      final jobId = DateTime.now().millisecondsSinceEpoch.toString();
      jobs[jobId] = 'pending';

      // simulate progression
      if (simulate) {
        Timer(const Duration(seconds: 1), () {
          jobs[jobId] = 'connecting';
          _emitSse(sseControllers, jsonEncode({'jobId': jobId, 'status': 'connecting'}));
        });
        Timer(const Duration(seconds: 3), () {
          jobs[jobId] = 'listening';
          _emitSse(sseControllers, jsonEncode({'jobId': jobId, 'status': 'listening'}));
        });

        _json(req, {'jobId': jobId, 'status': 'pending', 'payload': payload});
        unawaited(_auditDb({'user_id': userId, 'action': 'originate_listen', 'jobId': jobId, 'payload': payload, 'time': DateTime.now().toIso8601String()}));
        return;
      } else {
        final res = await _forwardPost(forwardTo!, req.uri.path, body);
        final bytes = await _collectResponseBytes(res);
        _raw(req, res.statusCode, bytes, res.headers.contentType?.value);
        return;
      }
    }

    if (path == '/ami/originate/playback' && req.method == 'POST') {
      final body = await utf8.decoder.bind(req).join();
      final payload = body.isNotEmpty ? jsonDecode(body) : {};
      // require supervisor/qa roles
      if (!(role == 'supervisor' || role == 'qa' || role == 'admin')) {
        _json(req, {'error': 'forbidden: insufficient role'}, status: HttpStatus.forbidden);
        return;
      }

      final jobId = DateTime.now().millisecondsSinceEpoch.toString();
      jobs[jobId] = 'playing';
      _json(req, {'jobId': jobId, 'status': 'playing', 'payload': payload});
      unawaited(_auditDb({'user_id': userId, 'action': 'originate_playback', 'jobId': jobId, 'payload': payload, 'time': DateTime.now().toIso8601String()}));
      return;
    }

    if (path == '/ami/control/playback' && req.method == 'POST') {
      final body = await utf8.decoder.bind(req).join();
      final payload = body.isNotEmpty ? jsonDecode(body) : {};
      final jobId = payload['jobId']?.toString();
      final command = payload['command']?.toString();
      if (jobId != null && jobs.containsKey(jobId)) {
        jobs[jobId] = command == 'stop' ? 'stopped' : jobs[jobId]!;
        _json(req, {'jobId': jobId, 'status': jobs[jobId], 'command': command});
        unawaited(_auditDb({'user_id': userId, 'action': 'control_playback', 'jobId': jobId, 'command': command, 'time': DateTime.now().toIso8601String()}));
      } else {
        req.response.statusCode = HttpStatus.notFound;
        _json(req, {'error': 'job not found'});
      }
      return;
    }

    if (path.startsWith('/ami/jobs/') && req.method == 'GET') {
      final parts = path.split('/').where((s) => s.isNotEmpty).toList();
      if (parts.length >= 3) {
        final id = parts[2];
        final status = jobs[id] ?? 'unknown';
        _json(req, {'jobId': id, 'status': status});
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
      return;
    }

    if (path == '/ami/events' && req.method == 'GET') {
      req.response.statusCode = HttpStatus.ok;
      req.response.headers.set(HttpHeaders.contentTypeHeader, 'text/event-stream');
      final controller = StreamController<String>();
      sseControllers.add(controller);
      controller.add('event: ping\ndata: ${DateTime.now().toIso8601String()}\n\n');
      await for (final msg in controller.stream) {
        try {
          req.response.write(msg);
          await req.response.flush();
        } catch (_) {
          break;
        }
      }
      sseControllers.remove(controller);
      await req.response.close();
      return;
    }

    // fallback
    req.response.statusCode = HttpStatus.notFound;
    await req.response.close();
  } catch (e, st) {
    stderr.writeln('Error: $e\n$st');
    try {
      req.response.statusCode = HttpStatus.internalServerError;
      _json(req, {'error': e.toString()});
    } catch (_) {}
  }
}

void _json(HttpRequest req, Object obj, {int status = HttpStatus.ok}) {
  req.response.statusCode = status;
  req.response.headers.contentType = ContentType.json;
  req.response.write(jsonEncode(obj));
  req.response.close();
}

void _raw(HttpRequest req, int status, List<int> body, String? contentType) {
  req.response.statusCode = status;
  if (contentType != null) req.response.headers.contentType = ContentType.parse(contentType);
  req.response.add(body);
  req.response.close();
}

Future<HttpClientResponse> _forwardGet(String forwardTo, String path) async {
  final client = HttpClient();
  final uri = Uri.parse(forwardTo + path);
  final req = await client.getUrl(uri);
  return await req.close();
}

Future<HttpClientResponse> _forwardPost(String forwardTo, String path, String body) async {
  final client = HttpClient();
  final uri = Uri.parse(forwardTo + path);
  final req = await client.postUrl(uri);
  req.headers.contentType = ContentType.json;
  req.write(body);
  return await req.close();
}

Future<List<int>> _collectResponseBytes(HttpClientResponse res) async {
  final chunks = await res.toList();
  return chunks.expand((c) => c).toList();
}

void _emitSse(List<StreamController<String>> controllers, String data) {
  final payload = 'data: $data\n\n';
  for (final c in controllers) {
    if (!c.isClosed) c.add(payload);
  }
}

void _ensureDb() {
  if (_dbInitialized) return;
  try {
    _db = sqlite3.open('tools/ami_audit.db');
    _db!.execute('''
      CREATE TABLE IF NOT EXISTS ami_audit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        action TEXT NOT NULL,
        target TEXT,
        recording_id TEXT,
        job_id TEXT,
        reason TEXT,
        timestamp TEXT NOT NULL,
        duration INTEGER,
        meta TEXT
      );
    ''');
    _dbInitialized = true;
  } catch (e) {
    stderr.writeln('DB init error: $e');
  }
}

Future<void> _auditDb(Map<String, Object?> entry) async {
  try {
    if (!_dbInitialized || _db == null) return;
    final userId = entry['user_id']?.toString();
    final action = entry['action']?.toString() ?? entry['method']?.toString() ?? 'unknown';
    final target = entry['target']?.toString();
    final recordingId = entry['recording_id']?.toString();
    final jobId = entry['jobId']?.toString() ?? entry['job_id']?.toString();
    final reason = entry['reason']?.toString();
    final timestamp = entry['time']?.toString() ?? DateTime.now().toIso8601String();
    final duration = entry['duration'] is int ? entry['duration'] as int : null;
    final meta = entry.containsKey('payload') ? jsonEncode(entry['payload']) : null;

    _db!.execute(
      'INSERT INTO ami_audit (user_id, action, target, recording_id, job_id, reason, timestamp, duration, meta) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [userId, action, target, recordingId, jobId, reason, timestamp, duration, meta],
    );
  } catch (e) {
    stderr.writeln('DB audit insert error: $e');
  }
}

Future<void> _audit(Map<String, Object?> entry) async {
  try {
    await _auditFile.create(recursive: true);
    await _auditFile.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
  } catch (_) {}
}

void unawaited(Future<void> f) {}



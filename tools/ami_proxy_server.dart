import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Simple AMI-proxy mock for local testing.
/// - Auth: expects `Authorization: Bearer test-token`
/// - Endpoints:
///   GET  /recordings
///   GET  /recordings/:id
///   GET  /recordings/:id/stream  -> 302 redirect to sample mp3
///   POST /ami/originate/listen    -> returns jobId (async state)
///   POST /ami/originate/playback  -> returns jobId
///   POST /ami/control/playback    -> control playback (stop/pause)
///   GET  /ami/jobs/:id            -> job status
///   GET  /ami/events              -> Server-Sent Events (simple simulated stream)

const sampleMp3 = 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3';

final _auditFile = File('tools/ami_audit.log');

Future<void> main(List<String> args) async {
  final ip = InternetAddress.loopbackIPv4;
  final port = 8081;
  final server = await HttpServer.bind(ip, port);
  final jobs = <String, String>{}; // jobId -> status
  final sseControllers = <StreamController<String>>[];

  stderr.writeln('AMI proxy mock running at http://${ip.address}:$port/');

  await for (final req in server) {
    try {
      final path = req.uri.path;

      // simple auth check: expect Authorization: Bearer test-token
      final auth = req.headers.value(HttpHeaders.authorizationHeader);
      if (auth == null || !auth.startsWith('Bearer ')) {
        req.response.statusCode = HttpStatus.unauthorized;
        _json(req, {'error': 'Missing Authorization header'});
        continue;
      }
      final token = auth.substring(7);
      if (token != 'test-token') {
        req.response.statusCode = HttpStatus.forbidden;
        _json(req, {'error': 'Invalid token'});
        continue;
      }

      // audit minimal request info
      unawaited(_audit({'method': req.method, 'path': path, 'time': DateTime.now().toIso8601String()}));

      if (path == '/recordings' && req.method == 'GET') {
        final list = [
          {
            'id': 'rec1',
            'filename': 'sample1.mp3',
            'url': 'http://${ip.address}:$port/recordings/rec1/stream'
          },
        ];
        _json(req, list);

      } else if (path.startsWith('/recordings/') && req.method == 'GET') {
        final parts = path.split('/').where((s) => s.isNotEmpty).toList();
        if (parts.length >= 2) {
          final id = parts[1];
          if (parts.length == 3 && parts[2] == 'stream') {
            // redirect to an external sample mp3
            req.response.statusCode = HttpStatus.found; // 302
            req.response.headers.set(HttpHeaders.locationHeader, sampleMp3);
            await req.response.close();
            continue;
          }

          final meta = {
            'id': id,
            'filename': 'sample1.mp3',
            'url': 'http://${ip.address}:$port/recordings/$id/stream'
          };
          _json(req, meta);
        } else {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
        }

      } else if (path == '/ami/originate/listen' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final payload = body.isNotEmpty ? jsonDecode(body) : {};
        final jobId = DateTime.now().millisecondsSinceEpoch.toString();
        jobs[jobId] = 'pending';

        // simulate progression and notify sse controllers
        Timer(const Duration(seconds: 1), () {
          jobs[jobId] = 'connecting';
          _emitSse(sseControllers, jsonEncode({'jobId': jobId, 'status': 'connecting'}));
        });
        Timer(const Duration(seconds: 3), () {
          jobs[jobId] = 'listening';
          _emitSse(sseControllers, jsonEncode({'jobId': jobId, 'status': 'listening'}));
        });

        _json(req, {'jobId': jobId, 'status': 'pending', 'payload': payload});
        unawaited(_audit({'action': 'originate_listen', 'jobId': jobId, 'payload': payload, 'time': DateTime.now().toIso8601String()}));

      } else if (path == '/ami/originate/playback' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final payload = body.isNotEmpty ? jsonDecode(body) : {};
        final jobId = DateTime.now().millisecondsSinceEpoch.toString();
        jobs[jobId] = 'playing';
        _json(req, {'jobId': jobId, 'status': 'playing', 'payload': payload});
        unawaited(_audit({'action': 'originate_playback', 'jobId': jobId, 'payload': payload, 'time': DateTime.now().toIso8601String()}));

      } else if (path == '/ami/control/playback' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final payload = body.isNotEmpty ? jsonDecode(body) : {};
        final jobId = payload['jobId']?.toString();
        final command = payload['command']?.toString();
        if (jobId != null && jobs.containsKey(jobId)) {
          jobs[jobId] = command == 'stop' ? 'stopped' : jobs[jobId]!;
          _json(req, {'jobId': jobId, 'status': jobs[jobId], 'command': command});
          unawaited(_audit({'action': 'control_playback', 'jobId': jobId, 'command': command, 'time': DateTime.now().toIso8601String()}));
        } else {
          req.response.statusCode = HttpStatus.notFound;
          _json(req, {'error': 'job not found'});
        }

      } else if (path.startsWith('/ami/jobs/') && req.method == 'GET') {
        final parts = path.split('/').where((s) => s.isNotEmpty).toList();
        if (parts.length >= 3) {
          final id = parts[2];
          final status = jobs[id] ?? 'unknown';
          _json(req, {'jobId': id, 'status': status});
        } else {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
        }

      } else if (path == '/ami/events' && req.method == 'GET') {
        // simple SSE endpoint
        req.response.statusCode = HttpStatus.ok;
        req.response.headers.set(HttpHeaders.contentTypeHeader, 'text/event-stream');
        final controller = StreamController<String>();
        sseControllers.add(controller);
        // send a keepalive once
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

      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    } catch (e, st) {
      stderr.writeln('Error: $e\n$st');
      try {
        req.response.statusCode = HttpStatus.internalServerError;
        _json(req, {'error': e.toString()});
      } catch (_) {}
    }
  }
}

void _json(HttpRequest req, Object obj) {
  req.response.headers.contentType = ContentType.json;
  req.response.write(jsonEncode(obj));
  req.response.close();
}

Future<void> _audit(Map<String, Object?> entry) async {
  try {
    await _auditFile.create(recursive: true);
    await _auditFile.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
  } catch (_) {}
}

void _emitSse(List<StreamController<String>> controllers, String data) {
  final payload = 'data: $data\n\n';
  for (final c in controllers) {
    if (!c.isClosed) c.add(payload);
  }
}


void unawaited(Future<void> f) {}

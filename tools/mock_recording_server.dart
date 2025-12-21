import 'dart:io';
import 'dart:convert';

/// Simple mock recording server.
/// Endpoints:
/// GET /recordings -> list of recordings JSON
/// GET /recordings/{id} -> metadata { id, url }
/// GET /recordings/{id}/stream -> redirects (302) to public mp3 URL

const sampleMp3 = 'https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3';

Future<void> main(List<String> args) async {
  final ip = InternetAddress.loopbackIPv4;
  final port = 8080;
  final server = await HttpServer.bind(ip, port);

  await for (final req in server) {
    try {
      final path = req.uri.path;
      if (path == '/recordings' && req.method == 'GET') {
        final list = [
          {'id': 'rec1', 'filename': 'sample1.mp3', 'url': 'http://${ip.address}:$port/recordings/rec1/stream'},
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

          final meta = {'id': id, 'filename': 'sample1.mp3', 'url': 'http://${ip.address}:$port/recordings/$id/stream'};
          _json(req, meta);
        } else {
          req.response.statusCode = HttpStatus.notFound;
          await req.response.close();
        }
      } else {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
      }
    } catch (e, st) {
      stderr.writeln('Error handling request: $e\n$st');
      try {
        req.response.statusCode = 500;
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

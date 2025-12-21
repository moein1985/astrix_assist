import 'dart:async';
import 'package:dio/dio.dart';

class AmiApi {
  AmiApi._();

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('AMI_PROXY_URL', defaultValue: 'http://10.0.2.2:8081'),
    connectTimeout: const Duration(seconds: 5),
  ))..options.headers['Authorization'] = 'Bearer test-token';

  static Future<Response> getRecordings() => _dio.get('/recordings');

  static Future<Response> getRecordingMeta(String id) => _dio.get('/recordings/$id');

  static Future<Response> originateListen(Map<String, dynamic> payload) => _dio.post('/ami/originate/listen', data: payload);

  static Future<Response> originatePlayback(Map<String, dynamic> payload) => _dio.post('/ami/originate/playback', data: payload);

  static Future<Response> controlPlayback(Map<String, dynamic> payload) => _dio.post('/ami/control/playback', data: payload);

  static Future<Response> getJobStatus(String jobId) => _dio.get('/ami/jobs/$jobId');

  static Stream<Map<String, dynamic>> pollJob(String jobId, {Duration interval = const Duration(seconds: 1)}) async* {
    while (true) {
      try {
        final res = await getJobStatus(jobId);
        yield res.data as Map<String, dynamic>;
        final status = (res.data as Map<String, dynamic>)['status'] as String?;
        if (status == 'listening' || status == 'stopped' || status == 'playing' || status == 'unknown') break;
      } catch (_) {}
      await Future.delayed(interval);
    }
  }
}

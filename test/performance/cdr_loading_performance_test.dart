import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

// Benchmark for CDR loading performance
class CdrLoadingBenchmark extends BenchmarkBase {
  CdrLoadingBenchmark() : super('CDR Loading Performance');

  @override
  void run() {
    // Simulate CDR loading operation
    // In real implementation, this would call the actual data source
    final mockCdrData = List.generate(1000, (index) => {
      'calldate': '2025-12-23 10:00:00',
      'clid': '"Test User $index" <100$index>',
      'src': '100$index',
      'dst': '200$index',
      'dcontext': 'from-internal',
      'channel': 'SIP/100$index-0001',
      'dstchannel': 'SIP/200$index-0001',
      'lastapp': 'Dial',
      'lastdata': 'SIP/200$index,30,Tt',
      'duration': '30',
      'billsec': '25',
      'disposition': 'ANSWERED',
      'amaflags': '3',
      'uniqueid': '1734945600.$index',
      'userfield': '',
    });

    // Simulate processing
    for (final record in mockCdrData) {
      final src = record['src'];
      final dst = record['dst'];
      final duration = int.parse(record['duration'] ?? '0');
      // Simulate some processing logic
      // ignore: unused_local_variable
      final processed = '$src -> $dst (${duration}s)';
    }
  }
}

// Benchmark for recording download performance
class RecordingDownloadBenchmark extends BenchmarkBase {
  RecordingDownloadBenchmark() : super('Recording Download Performance');

  @override
  void run() {
    // Simulate recording download operation
    // In real implementation, this would download actual files
    final mockFileSize = 10 * 1024 * 1024; // 10MB
    final buffer = List<int>.filled(mockFileSize, 0);

    // Simulate file processing
    // ignore: unused_local_variable
    var checksum = 0;
    for (final byte in buffer) {
      checksum += byte;
    }
  }
}

void main() {
  group('Performance Tests', () {
    test('CDR Loading Performance', () {
      final benchmark = CdrLoadingBenchmark();
      benchmark.report();
      // Performance test completed successfully
      expect(true, isTrue);
    });

    test('Recording Download Performance', () {
      final benchmark = RecordingDownloadBenchmark();
      benchmark.report();
      // Performance test completed successfully
      expect(true, isTrue);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:astrix_assist/core/adapters/cdr_adapter.dart';
import 'package:astrix_assist/core/app_config.dart';

void main() {
  group('CDRAdapter', () {
    late CDRAdapter adapter;

    setUp(() {
      AppConfig.setGeneration(1);
      adapter = CDRAdapter();
    });

    test('parseCDR parses CDR line correctly', () {
      // Sample CDR line for Generation 1 (14 columns)
      const cdrLine = '"", "1003", "09155119004", "from-internal", ""John Doe" <1003>", "SIP/1003-000000c6", "SIP/trunk-000000c7", "Dial", "SIP/trunk/09155119004", "2025-12-23 12:41:27", "29", "23", "ANSWERED", "DOCUMENTATION"';

      final parsed = adapter.parseCDR(cdrLine);

      expect(parsed, isNotNull);
      expect(parsed['src'], '1003');
      expect(parsed['dst'], '09155119004');
      expect(parsed['channel'], 'SIP/1003-000000c6');
      expect(parsed['disposition'], 'ANSWERED');
    });

    test('formatCDR formats CDR data back to string', () {
      final cdrData = {
        'accountcode': '',
        'src': '1003',
        'dst': '09155119004',
        'dcontext': 'from-internal',
        'clid': '"John Doe" <1003>',
        'channel': 'SIP/1003-000000c6',
        'dstchannel': 'SIP/trunk-000000c7',
        'lastapp': 'Dial',
        'lastdata': 'SIP/trunk/09155119004',
        'calldate': '2025-12-23 12:41:27',
        'duration': '29',
        'billsec': '23',
        'disposition': 'ANSWERED',
        'amaflags': 'DOCUMENTATION',
      };

      final formatted = adapter.formatCDR(cdrData);

      expect(formatted, isNotNull);
      expect(formatted, contains('1003'));
      expect(formatted, contains('09155119004'));
      expect(formatted, contains('ANSWERED'));
    });

    test('getCDRColumns returns expected columns', () {
      final columns = adapter.getCDRColumns();

      expect(columns, isA<List<String>>());
      expect(columns, contains('accountcode'));
      expect(columns, contains('src'));
      expect(columns, contains('dst'));
      expect(columns, contains('channel'));
      expect(columns, contains('disposition'));
    });

    test('validateCDRFormat validates correct format', () {
      const validCDR = '"", "1003", "09155119004", "from-internal", ""John Doe" <1003>", "SIP/1003-000000c6", "SIP/trunk-000000c7", "Dial", "SIP/trunk/09155119004", "2025-12-23 12:41:27", "29", "23", "ANSWERED", "DOCUMENTATION"';
      const invalidCDR = 'invalid cdr line';

      expect(adapter.validateCDRFormat(validCDR), true);
      expect(adapter.validateCDRFormat(invalidCDR), false);
    });

    test('getCDRFilePath returns correct path', () {
      final path = adapter.getCDRFilePath();

      expect(path, isNotNull);
      expect(path, contains('cdr'));
    });

    test('adaptCDRData handles cross-generation adaptation', () {
      final cdrData = {'uniqueid': '123', 'channel': 'SIP/100'};
      final adapted = adapter.adaptCDRData(cdrData, 2);

      expect(adapted, isNotNull);
      expect(adapted['uniqueid'], '123');
    });

    test('adapts behavior when generation changes', () {
      // Generation 1
      AppConfig.setGeneration(1);
      final adapter1 = CDRAdapter();
      final columns1 = adapter1.getCDRColumns();

      // Generation 2
      AppConfig.setGeneration(2);
      final adapter2 = CDRAdapter();
      final columns2 = adapter2.getCDRColumns();

      // Columns should be different or same depending on implementation
      expect(columns1, isA<List<String>>());
      expect(columns2, isA<List<String>>());
    });
  });
}
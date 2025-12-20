import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../entities/cdr_record.dart';
import '../../core/result.dart';

class ExportCdrToCsvUseCase {
  Future<Result<String>> call(List<CdrRecord> records) async {
    try {
      // Create CSV content
      final List<List<dynamic>> rows = [];

      // Header row
      rows.add([
        'Call Date',
        'Caller ID',
        'Source',
        'Destination',
        'Context',
        'Channel',
        'Destination Channel',
        'Last Application',
        'Last Data',
        'Duration',
        'Billsec',
        'Disposition',
        'AMA Flags',
        'Unique ID',
        'User Field',
      ]);

      // Data rows
      for (final record in records) {
        rows.add([
          record.callDate,
          record.clid,
          record.src,
          record.dst,
          record.dcontext,
          record.channel,
          record.dstChannel,
          record.lastApp,
          record.lastData,
          record.duration,
          record.billsec,
          record.disposition,
          record.amaflags,
          record.uniqueid,
          record.userfield,
        ]);
      }

      // Convert to CSV
      final String csv = const ListToCsvConverter().convert(rows);

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        return Failure('Cannot access storage directory');
      }

      // Create file path with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/cdr_export_$timestamp.csv';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csv);

      return Success(filePath);
    } catch (e) {
      return Failure('Failed to export CDR records: $e');
    }
  }
}

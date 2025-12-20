import 'dart:io';
import 'package:mysql1/mysql1.dart';
import '../models/cdr_model.dart';

class CdrDataSource {
  final String host;
  final int port;
  final String user;
  final String password;
  final String db;

  CdrDataSource({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.db,
  });

  Future<List<CdrModel>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    MySqlConnection? conn;
    try {
      final settings = ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: db,
      );

      conn = await MySqlConnection.connect(settings);

      // Build query with filters
      final whereConditions = <String>[];
      
      if (startDate != null) {
        whereConditions.add("calldate >= '${_formatDateTime(startDate)}'");
      }
      if (endDate != null) {
        whereConditions.add("calldate <= '${_formatDateTime(endDate)}'");
      }
      if (src != null && src.isNotEmpty) {
        whereConditions.add("src LIKE '%$src%'");
      }
      if (dst != null && dst.isNotEmpty) {
        whereConditions.add("dst LIKE '%$dst%'");
      }
      if (disposition != null && disposition.isNotEmpty && disposition != 'ALL') {
        whereConditions.add("disposition = '$disposition'");
      }

      final whereClause = whereConditions.isNotEmpty 
          ? 'WHERE ${whereConditions.join(' AND ')}' 
          : '';

      final query = '''
        SELECT calldate, clid, src, dst, dcontext, channel, dstchannel, 
               lastapp, lastdata, duration, billsec, disposition, 
               amaflags, uniqueid, userfield
        FROM cdr
        $whereClause
        ORDER BY calldate DESC
        LIMIT $limit
      ''';

      final results = await conn.query(query);
      final records = <CdrModel>[];

      for (var row in results) {
        records.add(CdrModel(
          callDate: row['calldate']?.toString() ?? '',
          clid: row['clid']?.toString() ?? '',
          src: row['src']?.toString() ?? '',
          dst: row['dst']?.toString() ?? '',
          dcontext: row['dcontext']?.toString() ?? '',
          channel: row['channel']?.toString() ?? '',
          dstChannel: row['dstchannel']?.toString() ?? '',
          lastApp: row['lastapp']?.toString() ?? '',
          lastData: row['lastdata']?.toString() ?? '',
          duration: row['duration']?.toString() ?? '0',
          billsec: row['billsec']?.toString() ?? '0',
          disposition: row['disposition']?.toString() ?? '',
          amaflags: row['amaflags']?.toString() ?? '',
          uniqueid: row['uniqueid']?.toString() ?? '',
          userfield: row['userfield']?.toString() ?? '',
        ));
      }

      return records;
    } on SocketException catch (e) {
      throw Exception('Cannot connect to MySQL server: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching CDR: $e');
    } finally {
      await conn?.close();
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

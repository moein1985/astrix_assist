import 'package:logger/logger.dart';
import '../models/cdr_model.dart';
import '../../core/services/asterisk_ssh_manager.dart';

/// CDR DataSource using SSH + Python Script
/// Replaces MySQL-based CDR datasource
class SshCdrDataSource {
  final AsteriskSshManager sshManager;
  final Logger _logger = Logger();

  SshCdrDataSource({required this.sshManager});

  /// Get CDR records with filters
  Future<List<CdrModel>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    try {
      _logger.i('📞 getCdrRecords called with: startDate=$startDate, endDate=$endDate, src=$src, dst=$dst, disposition=$disposition, limit=$limit');
      
      // Calculate days based on date range
      final days = _calculateDays(startDate, endDate);
      _logger.d('📅 Calculated days: $days');
      
      // Fetch CDRs from server via Python script
      _logger.d('🔍 Calling sshManager.getCdrs with days=$days, limit=$limit');
      final response = await sshManager.getCdrs(
        days: days,
        limit: limit,
      );

      _logger.d('📥 Response received: success=${response.isSuccess}, error=${response.error}');
      if (!response.isSuccess) {
        _logger.e('❌ Failed to fetch CDRs: ${response.error}');
        throw Exception('Failed to fetch CDRs: ${response.error}');
      }

      // Parse JSON records to CdrModel
      final records = response.data?.records ?? [];
      _logger.d('📋 Raw records count: ${records.length}');
      
      if (records.isEmpty) {
        _logger.w('⚠️ No records returned from server');
      } else {
        _logger.d('📄 First record sample: ${records.first}');
      }
      
      final allParsed = records.map((record) => _parseCdrRecord(record)).toList();
      _logger.d('✅ Parsed ${allParsed.length} records');
      
      final cdrModels = allParsed
          .where((model) => _matchesFilters(
                model,
                startDate: startDate,
                endDate: endDate,
                src: src,
                dst: dst,
                disposition: disposition,
              ))
          .toList();

      _logger.i('✅ After filtering: ${cdrModels.length} CDR records (from ${records.length} raw)');
      if (cdrModels.length < records.length) {
        _logger.w('⚠️ Filtered out ${records.length - cdrModels.length} records');
      }
      return cdrModels;
    } catch (e) {
      _logger.e('Error fetching CDRs: $e');
      rethrow;
    }
  }

  /// Calculate number of days from date range
  int _calculateDays(DateTime? startDate, DateTime? endDate) {
    if (startDate == null) return 7; // Default 7 days

    final end = endDate ?? DateTime.now();
    final diff = end.difference(startDate);
    
    // Add 1 day buffer and cap at reasonable limit
    final days = diff.inDays + 1;
    return days.clamp(1, 90); // Max 90 days
  }

  /// Parse JSON record to CdrModel
  CdrModel _parseCdrRecord(Map<String, dynamic> record) {
    return CdrModel(
      callDate: record['calldate']?.toString() ?? '',
      clid: record['clid']?.toString() ?? '',
      src: record['src']?.toString() ?? '',
      dst: record['dst']?.toString() ?? '',
      dcontext: record['dcontext']?.toString() ?? '',
      channel: record['channel']?.toString() ?? '',
      dstChannel: record['dstchannel']?.toString() ?? '',
      lastApp: record['lastapp']?.toString() ?? '',
      lastData: record['lastdata']?.toString() ?? '',
      duration: record['duration']?.toString() ?? '0',
      billsec: record['billsec']?.toString() ?? '0',
      disposition: record['disposition']?.toString() ?? '',
      amaflags: record['amaflags']?.toString() ?? '',
      uniqueid: record['uniqueid']?.toString() ?? '',
      userfield: record['userfield']?.toString() ?? '',
    );
  }

  /// Check if record matches filters
  bool _matchesFilters(
    CdrModel model, {
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
  }) {
    // Date filter
    if (startDate != null || endDate != null) {
      final callDate = _parseCallDate(model.callDate);
      if (callDate != null) {
        if (startDate != null && callDate.isBefore(startDate)) return false;
        if (endDate != null && callDate.isAfter(endDate)) return false;
      }
    }

    // Source filter
    if (src != null && src.isNotEmpty) {
      if (!model.src.contains(src)) return false;
    }

    // Destination filter
    if (dst != null && dst.isNotEmpty) {
      if (!model.dst.contains(dst)) return false;
    }

    // Disposition filter
    if (disposition != null && disposition.isNotEmpty && disposition != 'ALL') {
      if (model.disposition != disposition) return false;
    }

    return true;
  }

  /// Parse call date string (assumes server timezone)
  DateTime? _parseCallDate(String dateStr) {
    try {
      // Support multiple date formats
      final formats = [
        RegExp(r'(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})'),
        RegExp(r'(\d{4})/(\d{2})/(\d{2}) (\d{2}):(\d{2}):(\d{2})'),
      ];

      for (final format in formats) {
        final match = format.firstMatch(dateStr);
        if (match != null) {
          // Parse as local time (server's timezone)
          // This is important for proper timezone handling
          return DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
            int.parse(match.group(4)!),
            int.parse(match.group(5)!),
            int.parse(match.group(6)!),
          );
        }
      }

      // Fallback: try parse directly
      return DateTime.parse(dateStr);
    } catch (e) {
      _logger.w('Failed to parse date: $dateStr');
      return null;
    }
  }

  /// Get CDR by unique ID
  Future<CdrModel?> getCdrByUniqueId(String uniqueId) async {
    try {
      // Fetch recent CDRs (last 30 days)
      final response = await sshManager.getCdrs(days: 30, limit: 5000);

      if (!response.isSuccess) {
        return null;
      }

      final records = response.data?.records ?? [];
      final matching = records.firstWhere(
        (record) => record['uniqueid']?.toString() == uniqueId,
        orElse: () => <String, dynamic>{},
      );

      if (matching.isEmpty) return null;

      return _parseCdrRecord(matching);
    } catch (e) {
      _logger.e('Error fetching CDR by uniqueid: $e');
      return null;
    }
  }
}

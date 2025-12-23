import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/generation/generation_config.dart';

/// Adapter for Call Detail Record (CDR) parsing and formatting
/// Handles different CDR formats across Asterisk generations
class CDRAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Parses a CDR line according to the current generation's format
  Map<String, dynamic> parseCDR(String cdrLine) {
    return _config.parseCDR(cdrLine);
  }

  /// Formats a CDR map back to string format for the current generation
  String formatCDR(Map<String, dynamic> cdrData) {
    return _config.formatCDR(cdrData);
  }

  /// Gets the expected CDR columns for the current generation
  List<String> getCDRColumns() {
    return _config.cdrColumns;
  }

  /// Validates if a CDR line matches the expected format for the current generation
  bool validateCDRFormat(String cdrLine) {
    try {
      final parsed = parseCDR(cdrLine);
      return parsed.isNotEmpty && parsed.containsKey('channel');
    } catch (e) {
      return false;
    }
  }

  /// Gets the CDR file path for the current generation
  String getCDRFilePath() {
    return _config.cdrFilePath;
  }

  /// Adapts CDR data from one generation format to another if needed
  Map<String, dynamic> adaptCDRData(Map<String, dynamic> cdrData, int targetGeneration) {
    // For now, return the data as-is. Cross-generation adaptation
    // would be implemented based on specific requirements
    return cdrData;
  }
}
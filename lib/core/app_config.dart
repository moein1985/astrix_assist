import 'generation/generation_config.dart';
import 'generation/generation_1_config.dart';
import 'generation/generation_2_config.dart';
import 'generation/generation_3_config.dart';
import 'generation/generation_4_config.dart';

/// Application Configuration with Multi-Generation Support
///
/// This class manages application-wide configuration including:
/// - Generation selection (compile-time and runtime)
/// - Repository mode (mock vs real)
/// - Connection settings
/// - Feature flags
class AppConfig {
  // ===========================================================================
  // GENERATION CONFIGURATION
  // ===========================================================================

  /// Compile-time generation selector (1-4)
  /// تغییر این عدد برای انتخاب نسل پیش‌فرض در production
  static const int defaultGeneration = 4; // Rocky 9 + Asterisk 18+

  /// Runtime override (برای testing)
  static int? _runtimeGeneration;

  /// Singleton instance cache
  static final Map<int, GenerationConfig> _configCache = {};

  /// Get current active generation config
  static GenerationConfig get current {
    final gen = _runtimeGeneration ?? defaultGeneration;
    return getConfig(gen);
  }

  /// Get config for specific generation
  static GenerationConfig getConfig(int generation) {
    if (!_configCache.containsKey(generation)) {
      _configCache[generation] = _createConfig(generation);
    }
    return _configCache[generation]!;
  }

  static GenerationConfig _createConfig(int gen) {
    switch (gen) {
      case 1:
        return Generation1Config();
      case 2:
        return Generation2Config();
      case 3:
        return Generation3Config();
      case 4:
        return Generation4Config();
      default:
        throw ArgumentError(
          'Invalid generation: $gen. Must be between 1 and 4.',
        );
    }
  }

  /// Set generation at runtime (برای testing)
  ///
  /// توجه: این متد فقط در محیط test استفاده می‌شود
  /// در production از defaultGeneration استفاده می‌شود
  static void setGeneration(int gen) {
    if (gen < 1 || gen > 4) {
      throw ArgumentError('Generation must be between 1 and 4');
    }
    _runtimeGeneration = gen;
    _configCache.clear(); // Clear cache on generation change
  }

  /// Reset to default generation (برای testing)
  static void resetGeneration() {
    _runtimeGeneration = null;
    _configCache.clear();
  }

  /// Get all supported generations
  static List<int> get supportedGenerations => [1, 2, 3, 4];

  /// Check if generation is supported
  static bool isGenerationSupported(int gen) {
    return gen >= 1 && gen <= 4;
  }

  /// Get generation info
  static String getGenerationInfo(int gen) {
    return getConfig(gen).description;
  }

  // ===========================================================================
  // REPOSITORY CONFIGURATION
  // ===========================================================================

  /// Set to `true` to use Mock repositories (fake data)
  /// Set to `false` to use Real repositories (Asterisk AMI)
  static const bool useMockRepositories = false;

  // ===========================================================================
  // CONNECTION SETTINGS
  // ===========================================================================

  /// Default Asterisk AMI connection settings
  static const String defaultAmiHost = '192.168.85.88';
  static const String defaultAmiUsername = 'moein_api';
  static const String defaultAmiSecret = '123456';

  /// Get AMI port based on current generation
  static int get defaultAmiPort => current.defaultAMIPort;

  /// Default SSH connection settings (replaces MySQL access)
  /// SSH is used for:
  /// - CDR retrieval via Python script
  /// - Downloading call recordings
  /// - System info and AMI auto-setup
  static const String defaultSshHost = '192.168.85.88';
  static const String defaultSshUsername = 'root';
  static const String defaultSshPassword = ''; // Will be set by user

  /// Get SSH port based on current generation
  static int get defaultSshPort => current.defaultSSHPort;

  /// Get recordings path based on current generation
  static String get defaultRecordingsPath => current.recordingBasePath;

  // ===========================================================================
  // FEATURE FLAGS
  // ===========================================================================

  /// Check if a feature is supported in current generation
  static bool isFeatureSupported(String feature) {
    return current.isFeatureSupported(feature);
  }

  /// Check if AMI command is supported in current generation
  static bool isAmiCommandSupported(String command) {
    return current.isCommandSupported(command);
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get Python command for current generation
  static String getPythonCommand() => current.getPythonCommand();

  /// Get recording path for specific date
  static String getRecordingPath(DateTime callDate) {
    return current.getRecordingPath(callDate);
  }

  /// Adapt AMI command for current generation
  static String adaptAmiCommand(String command) {
    return current.adaptAMICommand(command);
  }

  /// Get CDR file path for current generation
  static String get cdrFilePath => current.cdrFilePath;

  /// Get CDR column count for current generation
  static int get cdrColumnCount => current.cdrColumnCount;

  /// Get CDR columns for current generation
  static List<String> get cdrColumns => current.cdrColumns;
}


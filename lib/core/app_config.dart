/// Application Configuration
/// 
/// Change these values to configure the app behavior.
/// 
/// For development/testing with mock data:
///   Set [useMockRepositories] to `true`
/// 
/// For production with real Asterisk server:
///   Set [useMockRepositories] to `false`
class AppConfig {
  /// Set to `true` to use Mock repositories (fake data)
  /// Set to `false` to use Real repositories (Asterisk AMI)
  static const bool useMockRepositories = false;
  
  /// Default Asterisk AMI connection settings
  static const String defaultAmiHost = '192.168.85.88';
  static const int defaultAmiPort = 5038;
  static const String defaultAmiUsername = 'moein_api';
  static const String defaultAmiSecret = '123456';
  
  /// Default SSH connection settings (replaces MySQL access)
  /// SSH is used for:
  /// - CDR retrieval via Python script
  /// - Downloading call recordings
  /// - System info and AMI auto-setup
  static const String defaultSshHost = '192.168.85.88';
  static const int defaultSshPort = 22;
  static const String defaultSshUsername = 'root';
  static const String defaultSshPassword = ''; // Will be set by user
  static const String defaultRecordingsPath = '/var/spool/asterisk/monitor';
}


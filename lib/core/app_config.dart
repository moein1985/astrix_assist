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
  static const bool useMockRepositories = true;
  
  /// Default Asterisk AMI connection settings
  static const String defaultAmiHost = '192.168.85.88';
  static const int defaultAmiPort = 5038;
  static const String defaultAmiUsername = 'moein_api';
  static const String defaultAmiSecret = '123456';
  
  /// Default MySQL/CDR connection settings
  static const String defaultDbHost = '192.168.85.88';
  static const int defaultDbPort = 3306;
  static const String defaultDbUser = 'root';
  static const String defaultDbPassword = '';
  static const String defaultDbName = 'asteriskcdrdb';
}

/// Generation Configuration Interface
///
/// Defines the contract for generation-specific configurations
/// Each generation (1-4) implements this interface with its specific settings
abstract class GenerationConfig {
  // Identification
  int get generation;
  String get name;
  String get description;
  String get osName;
  String get osVersion;
  String get asteriskVersion;
  String get pythonVersion;

  // Paths
  String get cdrFilePath;
  String get recordingBasePath;
  String getRecordingPath(DateTime callDate);
  String get pythonScriptPath;

  // Features
  List<String> get supportedAmiCommands;
  List<String> get supportedRecordingFormats;
  bool get supportsCoreShowChannels;
  bool get supportsPJSIP;
  bool get supportsJSON;
  bool get supportsCEL;

  // CDR Configuration
  int get cdrColumnCount;
  List<String> get cdrColumns;
  bool get supportsTimezone;
  String get defaultTimezone;

  // SSH Configuration
  List<String> get supportedAuthMethods;
  int get defaultSSHPort;
  bool get requiresKeyAuth;
  bool get supports2FA;

  // AMI Configuration
  int get defaultAMIPort;
  String get amiVersion;

  // SSH Configuration
  String get pythonPath;
  List<String> get sshOptions;
  List<String> get supportedPythonFeatures;
  List<String> get systemPaths;

  // Python Script Configuration
  String getPythonCommand();
  Map<String, String> getPythonScriptArgs();

  // Compatibility Methods
  String adaptAMICommand(String command);
  String adaptSSHCommand(String command);
  Map<String, dynamic> parseAMIResponse(String response);
  Map<String, dynamic> adaptAMIResponse(
    String command,
    Map<String, dynamic> response,
  );
  String getAMILoginCommand(String username, String password);
  String getAMILogoutCommand();
  bool isAMISuccessResponse(String response);
  Map<String, dynamic> parseCDR(String cdrLine);
  String formatCDR(Map<String, dynamic> cdrData);
  Map<String, dynamic> adaptCDRRecord(Map<String, dynamic> record);

  // Validation
  bool isCommandSupported(String command);
  bool isFeatureSupported(String feature);
}
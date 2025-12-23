import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/generation/generation_config.dart';

/// Adapter for SSH connections and commands
/// Handles SSH connectivity and command adaptation for different generations
class SSHAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Gets the SSH connection parameters for the current generation
  Map<String, dynamic> getConnectionParams({
    required String host,
    required int port,
    required String username,
    String? password,
    String? keyPath,
  }) {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'keyPath': keyPath,
      'pythonPath': _config.pythonPath,
      'sshOptions': _config.sshOptions,
    };
  }

  /// Adapts a command for execution on the current generation's system
  String adaptCommand(String command) {
    return _config.adaptSSHCommand(command);
  }

  /// Gets the Python executable path for the current generation
  String getPythonExecutable() {
    return _config.pythonPath;
  }

  /// Checks if the current generation supports a specific Python feature
  bool supportsPythonFeature(String feature) {
    return _config.supportedPythonFeatures.contains(feature);
  }

  /// Gets the system paths that should be available for the current generation
  List<String> getSystemPaths() {
    return _config.systemPaths;
  }

  /// Validates that the remote system matches the expected generation
  Future<bool> validateGeneration() async {
    // This would typically run a command to check the system version
    // For now, return true as validation logic would be implemented
    // in the actual SSH service layer
    return true;
  }
}
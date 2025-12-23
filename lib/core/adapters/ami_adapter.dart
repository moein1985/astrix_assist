import 'package:astrix_assist/core/app_config.dart';
import 'package:astrix_assist/core/generation/generation_config.dart';

/// Adapter for Asterisk Manager Interface (AMI) commands and responses
/// Adapts commands and responses based on the current generation configuration
class AMIAdapter {
  final GenerationConfig _config = AppConfig.current;

  /// Adapts an AMI command for the current generation
  String adaptCommand(String command) {
    return _config.adaptAMICommand(command);
  }

  /// Parses an AMI response for the current generation
  Map<String, dynamic> parseResponse(String response) {
    return _config.parseAMIResponse(response);
  }

  /// Gets the login command for the current generation
  String getLoginCommand(String username, String password) {
    return _config.getAMILoginCommand(username, password);
  }

  /// Checks if a response indicates success for the current generation
  bool isSuccessResponse(String response) {
    return _config.isAMISuccessResponse(response);
  }

  /// Gets the logout command for the current generation
  String getLogoutCommand() {
    return _config.getAMILogoutCommand();
  }

  /// Adapts an AMI response based on command type for the current generation
  Map<String, dynamic> adaptResponse(String command, String response) {
    final parsedResponse = parseResponse(response);
    return _config.adaptAMIResponse(command, parsedResponse);
  }
}
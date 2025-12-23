import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import '../ssh_service.dart';
import '../ssh_config.dart';
import 'script_models.dart';

/// Manager for Asterisk SSH operations and Python script execution
class AsteriskSshManager {
  final SshConfig config;
  final Logger _logger = Logger();
  
  late final SshService _sshService;
  
  static const String scriptVersion = '1.0.0';
  static const String remoteScriptPath = '/usr/local/bin/astrix_collector.py';
  static const String fallbackScriptPath = '/tmp/astrix_collector.py';
  
  String? _deployedScriptPath;
  bool _scriptDeployed = false;

  AsteriskSshManager(this.config, [SshService? sshService]) {
    _sshService = sshService ?? SshService(config);
  }
  
  /// Get SSH service instance (for recording downloads)
  SshService get sshService => _sshService;

  /// Connect to SSH server
  Future<void> connect() async {
    await _sshService.connect();
    _logger.i('SSH connected to ${config.host}');
  }

  /// Disconnect from SSH server
  void disconnect() {
    _sshService.disconnect();
    _scriptDeployed = false;
    _deployedScriptPath = null;
  }

  /// Ensure script is deployed and up to date
  Future<void> ensureScriptDeployed() async {
    if (_scriptDeployed && _deployedScriptPath != null) {
      return;
    }

    try {
      // Try to deploy to /usr/local/bin first
      _deployedScriptPath = await _deployScript(remoteScriptPath);
      _scriptDeployed = true;
      _logger.i('Script deployed to $_deployedScriptPath');
    } catch (e) {
      // If failed, try /tmp
      try {
        _deployedScriptPath = await _deployScript(fallbackScriptPath);
        _scriptDeployed = true;
        _logger.i('Script deployed to $_deployedScriptPath (fallback location)');
      } catch (e2) {
        _logger.e('Failed to deploy script: $e2');
        rethrow;
      }
    }
  }

  Future<String> _deployScript(String remotePath) async {
    // Read script from assets
    final scriptContent = await rootBundle.loadString('assets/scripts/astrix_collector.py');
    
    // Check if script exists and version matches
    final checkCmd = 'python --version 2>&1 && [ -f "$remotePath" ] && python "$remotePath" info 2>/dev/null || echo "not_found"';
    
    try {
      final result = await _executeCommand(checkCmd, timeout: 5);
      
      // Check if we need to upload
      bool needsUpload = result.contains('not_found');
      
      if (!needsUpload && result.contains('"script_version"')) {
        // Parse version from existing script
        try {
          final jsonMatch = RegExp(r'\{.*"script_version".*\}', dotAll: true).firstMatch(result);
          if (jsonMatch != null) {
            final json = jsonDecode(jsonMatch.group(0)!);
            final remoteVersion = json['data']?['script_version'] as String?;
            
            if (remoteVersion != null && remoteVersion == scriptVersion) {
              _logger.i('Script already deployed with correct version');
              return remotePath;
            }
          }
        } catch (_) {
          // If parsing fails, re-upload
          needsUpload = true;
        }
      }
      
      // Upload script
      await _uploadScript(scriptContent, remotePath);
      
      // Make executable
      await _executeCommand('chmod +x "$remotePath"');
      
      return remotePath;
    } catch (e) {
      _logger.e('Error deploying script: $e');
      rethrow;
    }
  }

  Future<void> _uploadScript(String content, String remotePath) async {
    try {
      await _sshService.connect();
      
      // Upload using cat with here-document (no temp file needed)
      await _executeCommand('cat > "$remotePath" << \'EOFSCRIPT\'\n$content\nEOFSCRIPT');
      
      _logger.i('Script uploaded to $remotePath');
    } catch (e) {
      _logger.e('Script upload failed: $e');
      rethrow;
    }
  }

  /// Execute Python script command
  Future<String> _executeScript(String command, {int timeout = 30}) async {
    await ensureScriptDeployed();
    
    // Detect Python command (python or python3)
    final pythonCmd = await _detectPythonCommand();
    
    final fullCommand = '$pythonCmd "$_deployedScriptPath" $command';
    
    return await _executeCommand(fullCommand, timeout: timeout);
  }

  Future<String> _detectPythonCommand() async {
    // Try python3 first (modern systems)
    try {
      final result = await _executeCommand('which python3 2>/dev/null && python3 --version 2>&1', timeout: 3);
      if (result.contains('Python')) {
        return 'python3';
      }
    } catch (_) {}
    
    // Try python2 (older CentOS)
    try {
      final result = await _executeCommand('which python2 2>/dev/null && python2 --version 2>&1', timeout: 3);
      if (result.contains('Python')) {
        return 'python2';
      }
    } catch (_) {}
    
    // Try generic python
    try {
      final result = await _executeCommand('which python 2>/dev/null && python --version 2>&1', timeout: 3);
      if (result.contains('Python')) {
        return 'python';
      }
    } catch (_) {}
    
    // Fallback to python3 as default
    _logger.w('No Python found, using python3 as fallback');
    return 'python3';
  }

  Future<String> _executeCommand(String command, {int timeout = 30}) async {
    // Use public API of SshService
    return await _sshService.executeCommand(command);
  }

  /// Get system information
  Future<ScriptResponse<SystemInfo>> getSystemInfo() async {
    try {
      final output = await _executeScript('info');
      final json = jsonDecode(output) as Map<String, dynamic>;
      
      return ScriptResponse<SystemInfo>.fromJson(
        json,
        (data) => SystemInfo.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      _logger.e('Failed to get system info: $e');
      return ScriptResponse<SystemInfo>(
        success: false,
        error: e.toString(),
        errorCode: 'EXECUTION_ERROR',
      );
    }
  }

  /// Get CDR records
  Future<ScriptResponse<CdrListResponse>> getCdrs({
    int days = 7,
    int limit = 1000,
  }) async {
    try {
      _logger.i('📞 getCdrs called with days=$days, limit=$limit');
      final command = 'cdr --days $days --limit $limit';
      _logger.d('🔧 Executing command: $command');
      
      final output = await _executeScript(command, timeout: 60);
      _logger.d('📤 Script output length: ${output.length} chars');
      
      if (output.isEmpty) {
        _logger.w('⚠️ Empty output from script');
      }
      
      final json = jsonDecode(output) as Map<String, dynamic>;
      _logger.d('📦 Decoded JSON keys: ${json.keys.join(", ")}');
      
      // Log debug info if available
      if (json.containsKey('debug_info')) {
        _logger.d('🔍 Debug Info: ${json['debug_info']}');
      }
      
      // Log hint if available
      if (json.containsKey('hint')) {
        _logger.w('💡 Hint: ${json['hint']}');
      }
      
      final response = ScriptResponse<CdrListResponse>.fromJson(
        json,
        (data) => CdrListResponse.fromJson(data as Map<String, dynamic>),
      );
      
      if (response.data != null) {
        final recordCount = response.data!.records.length;
        _logger.i('✅ getCdrs returning $recordCount records');
        if (recordCount > 0) {
          _logger.d('📋 First record: ${response.data!.records.first}');
        }
      } else {
        _logger.w('⚠️ Response data is null');
      }
      
      return response;
    } catch (e) {
      _logger.e('❌ Failed to get CDRs: $e');
      _logger.e('Stack trace: ${StackTrace.current}');
      return ScriptResponse<CdrListResponse>(
        success: false,
        error: e.toString(),
        errorCode: 'EXECUTION_ERROR',
      );
    }
  }

  /// Get recordings list
  Future<ScriptResponse<RecordingsListResponse>> getRecordings({
    int days = 7,
  }) async {
    try {
      final output = await _executeScript('recordings --days $days', timeout: 60);
      final json = jsonDecode(output) as Map<String, dynamic>;
      
      return ScriptResponse<RecordingsListResponse>.fromJson(
        json,
        (data) => RecordingsListResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      _logger.e('Failed to get recordings: $e');
      return ScriptResponse<RecordingsListResponse>(
        success: false,
        error: e.toString(),
        errorCode: 'EXECUTION_ERROR',
      );
    }
  }

  /// Check AMI status
  Future<ScriptResponse<AmiStatus>> checkAmi() async {
    try {
      final output = await _executeScript('check-ami');
      final json = jsonDecode(output) as Map<String, dynamic>;
      
      return ScriptResponse<AmiStatus>.fromJson(
        json,
        (data) => AmiStatus.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      _logger.e('Failed to check AMI: $e');
      return ScriptResponse<AmiStatus>(
        success: false,
        error: e.toString(),
        errorCode: 'EXECUTION_ERROR',
      );
    }
  }

  /// Setup AMI (enable and create user)
  Future<ScriptResponse<AmiCredentials>> setupAmi({
    String username = 'astrix_assist',
    String? password,
  }) async {
    try {
      final passArg = password != null ? '--pass "$password"' : '';
      final output = await _executeScript('setup-ami --user "$username" $passArg');
      final json = jsonDecode(output) as Map<String, dynamic>;
      
      return ScriptResponse<AmiCredentials>.fromJson(
        json,
        (data) => AmiCredentials.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      _logger.e('Failed to setup AMI: $e');
      return ScriptResponse<AmiCredentials>(
        success: false,
        error: e.toString(),
        errorCode: 'EXECUTION_ERROR',
      );
    }
  }

  /// Download recording file (delegates to existing SSH service)
  Future<dynamic> downloadRecording(String remotePath, {String? localPath}) async {
    return await _sshService.downloadRecording(remotePath, localPath: localPath);
  }
}

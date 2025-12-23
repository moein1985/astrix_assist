/// Response from Python script execution
class ScriptResponse<T> {
  final bool success;
  final String? timestamp;
  final T? data;
  final String? error;
  final String? errorCode;

  ScriptResponse({
    required this.success,
    this.timestamp,
    this.data,
    this.error,
    this.errorCode,
  });

  factory ScriptResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ScriptResponse<T>(
      success: json['success'] as bool? ?? false,
      timestamp: json['timestamp'] as String?,
      data: dataParser != null
          ? (json['data'] != null 
              ? dataParser(json['data']) 
              : dataParser(json)) // Parse from root if 'data' key doesn't exist
          : json['data'] as T?,
      error: json['error'] as String?,
      errorCode: json['error_code'] as String?,
    );
  }

  bool get isSuccess => success && error == null;
  bool get hasError => !success || error != null;
}

/// System information from Asterisk server
class SystemInfo {
  final String pythonVersion;
  final String asteriskVersion;
  final String? cdrPath;
  final String? recordingPath;
  final String? configPath;
  final bool? cdrEnabled;
  final String scriptVersion;

  SystemInfo({
    required this.pythonVersion,
    required this.asteriskVersion,
    this.cdrPath,
    this.recordingPath,
    this.configPath,
    this.cdrEnabled,
    required this.scriptVersion,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      pythonVersion: json['python_version'] as String? ?? 'unknown',
      asteriskVersion: json['asterisk_version'] as String? ?? 'unknown',
      cdrPath: json['cdr_path'] as String?,
      recordingPath: json['recording_path'] as String?,
      configPath: json['config_path'] as String?,
      cdrEnabled: json['cdr_enabled'] as bool?,
      scriptVersion: json['script_version'] as String? ?? 'unknown',
    );
  }
}

/// AMI status check result
class AmiStatus {
  final bool enabled;
  final bool userExists;
  final String configPath;

  AmiStatus({
    required this.enabled,
    required this.userExists,
    required this.configPath,
  });

  factory AmiStatus.fromJson(Map<String, dynamic> json) {
    return AmiStatus(
      enabled: json['enabled'] as bool? ?? false,
      userExists: json['user_exists'] as bool? ?? false,
      configPath: json['config_path'] as String? ?? '',
    );
  }
}

/// AMI setup credentials
class AmiCredentials {
  final String username;
  final String password;
  final String host;
  final int port;

  AmiCredentials({
    required this.username,
    required this.password,
    required this.host,
    required this.port,
  });

  factory AmiCredentials.fromJson(Map<String, dynamic> json) {
    return AmiCredentials(
      username: json['username'] as String? ?? 'astrix_assist',
      password: json['password'] as String? ?? '',
      host: json['host'] as String? ?? 'localhost',
      port: json['port'] as int? ?? 5038,
    );
  }
}

/// CDR list response
class CdrListResponse {
  final int count;
  final List<Map<String, dynamic>> records;

  CdrListResponse({
    required this.count,
    required this.records,
  });

  factory CdrListResponse.fromJson(Map<String, dynamic> json) {
    return CdrListResponse(
      count: json['count'] as int? ?? 0,
      records: (json['records'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

/// Recording file info
class RecordingInfo {
  final String path;
  final String filename;
  final int size;
  final String modified;

  RecordingInfo({
    required this.path,
    required this.filename,
    required this.size,
    required this.modified,
  });

  factory RecordingInfo.fromJson(Map<String, dynamic> json) {
    return RecordingInfo(
      path: json['path'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      modified: json['modified'] as String? ?? '',
    );
  }
}

/// Recordings list response
class RecordingsListResponse {
  final int count;
  final List<RecordingInfo> recordings;

  RecordingsListResponse({
    required this.count,
    required this.recordings,
  });

  factory RecordingsListResponse.fromJson(Map<String, dynamic> json) {
    return RecordingsListResponse(
      count: json['count'] as int? ?? 0,
      recordings: (json['recordings'] as List?)
              ?.map((e) => RecordingInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

import 'package:equatable/equatable.dart';

/// تنظیمات اتصال SSH برای دانلود فایل‌های ضبط شده
class SshConfig extends Equatable {
  final String host;
  final int port;
  final String username;
  final String authMethod; // 'password' or 'privateKey'
  final String? password;
  final String? privateKey;
  final String recordingsPath;

  const SshConfig({
    required this.host,
    this.port = 22,
    required this.username,
    this.authMethod = 'password',
    this.password,
    this.privateKey,
    this.recordingsPath = '/var/spool/asterisk/monitor',
  });

  /// ایجاد از SharedPreferences
  factory SshConfig.fromJson(Map<String, dynamic> json) {
    return SshConfig(
      host: json['host'] as String? ?? '',
      port: json['port'] as int? ?? 22,
      username: json['username'] as String? ?? '',
      authMethod: json['authMethod'] as String? ?? 'password',
      password: json['password'] as String?,
      privateKey: json['privateKey'] as String?,
      recordingsPath: json['recordingsPath'] as String? ?? '/var/spool/asterisk/monitor',
    );
  }

  /// تبدیل به Map برای ذخیره
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'authMethod': authMethod,
      'password': password,
      'privateKey': privateKey,
      'recordingsPath': recordingsPath,
    };
  }

  /// بررسی اعتبار تنظیمات
  bool get isValid {
    if (host.isEmpty || username.isEmpty) return false;
    if (authMethod == 'password' && (password == null || password!.isEmpty)) {
      return false;
    }
    if (authMethod == 'privateKey' && (privateKey == null || privateKey!.isEmpty)) {
      return false;
    }
    return true;
  }

  /// تنظیمات پیش‌فرض
  static const SshConfig defaultConfig = SshConfig(
    host: '192.168.85.88',
    port: 22,
    username: 'root',
    authMethod: 'password',
    password: null,
    recordingsPath: '/var/spool/asterisk/monitor',
  );

  SshConfig copyWith({
    String? host,
    int? port,
    String? username,
    String? authMethod,
    String? password,
    String? privateKey,
    String? recordingsPath,
  }) {
    return SshConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authMethod: authMethod ?? this.authMethod,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      recordingsPath: recordingsPath ?? this.recordingsPath,
    );
  }

  @override
  List<Object?> get props => [
        host,
        port,
        username,
        authMethod,
        password,
        privateKey,
        recordingsPath,
      ];

  @override
  String toString() {
    return 'SshConfig(host: $host, port: $port, username: $username, authMethod: $authMethod)';
  }
}

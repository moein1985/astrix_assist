import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'ssh_config.dart';

/// سرویس SSH برای دانلود فایل‌های ضبط شده از سرور Asterisk
class SshService {
  final SshConfig config;
  final Logger _logger = Logger();
  
  SSHClient? _client;
  SftpClient? _sftp;
  bool _isConnected = false;
  DateTime? _lastActivity;
  Timer? _keepAliveTimer;

  // Connection settings
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _keepAliveInterval = Duration(seconds: 30);
  static const Duration _idleTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;

  SshService(this.config);

  /// بررسی سلامت اتصال
  Future<bool> isConnectionHealthy() async {
    if (!_isConnected || _client == null) return false;
    
    try {
      // اگر idle بیش از حد باشد، اتصال رو بست کن
      if (_lastActivity != null && 
          DateTime.now().difference(_lastActivity!) > _idleTimeout) {
        _logger.w('Connection idle timeout, disconnecting');
        await disconnect();
        return false;
      }
      
      // تست سریع با دستور echo
      final result = await _client!.run('echo "test"');
      return result.isNotEmpty;
    } catch (e) {
      _logger.w('Connection health check failed: $e');
      return false;
    }
  }

  /// شروع keep-alive برای جلوگیری از timeout
  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(_keepAliveInterval, (timer) async {
      if (_isConnected && _client != null) {
        try {
          await _client!.run('echo "keepalive"');
          _logger.d('Keep-alive ping sent');
        } catch (e) {
          _logger.w('Keep-alive failed, connection may be dead: $e');
        }
      }
    });
  }

  /// اجرای عملیات با مدیریت خودکار session
  Future<T> _executeWithRecovery<T>(Future<T> Function() operation) async {
    _lastActivity = DateTime.now();
    
    // اگر اتصال سالم نیست، reconnect کن
    if (!await isConnectionHealthy()) {
      _logger.i('Connection unhealthy, attempting reconnect');
      await disconnect();
      await connect();
    }
    
    try {
      return await operation();
    } catch (e) {
      // اگر خطای اتصال بود، یک بار reconnect و retry کن
      if (_isConnectionError(e)) {
        _logger.w('Connection error detected, attempting recovery: $e');
        await disconnect();
        await connect();
        return await operation(); // یک بار دیگه امتحان کن
      }
      rethrow;
    }
  }

  /// بررسی اینکه آیا خطا مربوط به اتصال هست
  bool _isConnectionError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('socket') ||
           errorStr.contains('connection') ||
           errorStr.contains('timeout') ||
           errorStr.contains('closed');
  }

  /// اتصال به سرور SSH با retry logic
  Future<void> connect() async {
    if (await isConnectionHealthy()) {
      _logger.d('SSH already connected and healthy');
      return;
    }

    // اگر اتصال قبلی داریم ولی سالم نیست، قطعش کن
    if (_client != null) {
      await disconnect();
    }

    int attempt = 0;
    Exception? lastError;

    while (attempt < _maxRetries) {
      attempt++;
      
      try {
        _logger.i('Connecting to SSH (attempt $attempt/$_maxRetries): ${config.username}@${config.host}:${config.port}');
        
        final socket = await SSHSocket.connect(
          config.host,
          config.port,
          timeout: _connectionTimeout,
        );

        if (config.authMethod == 'password') {
          _client = SSHClient(
            socket,
            username: config.username,
            onPasswordRequest: () => config.password ?? '',
          );
        } else {
          // Private key authentication
          _client = SSHClient(
            socket,
            username: config.username,
            identities: SSHKeyPair.fromPem(config.privateKey!),
          );
        }

        _sftp = await _client!.sftp();
        _isConnected = true;
        _lastActivity = DateTime.now();
        _startKeepAlive(); // شروع keep-alive
        
        _logger.i('SSH connection established successfully on attempt $attempt');
        return;
        
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        _logger.w('SSH connection attempt $attempt failed: $e');
        
        _client = null;
        _sftp = null;
        _isConnected = false;
        
        // اگر آخرین تلاش نبود، کمی صبر کن (exponential backoff)
        if (attempt < _maxRetries) {
          final delay = Duration(milliseconds: 500 * (1 << (attempt - 1))); // 500ms, 1s, 2s
          _logger.d('Waiting ${delay.inMilliseconds}ms before retry');
          await Future.delayed(delay);
        }
      }
    }

    // اگر همه تلاش‌ها شکست خورد
    _logger.e('Failed to connect to SSH server after $_maxRetries attempts');
    throw lastError ?? Exception('SSH connection failed after $_maxRetries attempts');
  }

  /// قطع اتصال
  Future<void> disconnect() async {
    try {
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      
      _sftp?.close();
      _client?.close();
      
      _sftp = null;
      _client = null;
      _isConnected = false;
      _lastActivity = null;
      
      _logger.i('SSH disconnected');
    } catch (e) {
      _logger.e('Error disconnecting SSH: $e');
    }
  }

  /// بررسی وجود فایل در سرور
  Future<bool> fileExists(String remotePath) async {
    return await _executeWithRecovery(() async {
      final stat = await _sftp!.stat(remotePath);
      return !stat.isDirectory; // Check it's a file, not a directory
    });
  }

  /// دریافت لیست فایل‌های ضبط شده در یک تاریخ خاص
  /// 
  /// [date] به فرمت YYYY-MM-DD
  /// برمی‌گرداند: لیست نام فایل‌ها (فقط نام، نه مسیر کامل)
  Future<List<String>> listRecordings(String date) async {
    return await _executeWithRecovery(() async {
      // تبدیل تاریخ به فرمت مسیر: /var/spool/asterisk/monitor/2025/01/15/
      // Extract only date part (YYYY-MM-DD) if datetime is passed
      final dateOnly = date.length > 10 ? date.substring(0, 10) : date;
      final dateParts = dateOnly.split('-');
      if (dateParts.length != 3) {
        throw ArgumentError('Date must be in YYYY-MM-DD format');
      }
      
      final year = dateParts[0];
      final month = dateParts[1];
      final day = dateParts[2];
      
      final remotePath = '${config.recordingsPath}/$year/$month/$day';
      
      _logger.d('Listing recordings in: $remotePath');

      // بررسی وجود پوشه
      final items = await _sftp!.listdir(remotePath);
      
      final recordings = <String>[];
      for (final item in items) {
        if (!item.attr.isDirectory) { // Check it's a file
          final filename = item.filename;
          // فقط فایل‌های wav, mp3, gsm
          if (filename.endsWith('.wav') ||
              filename.endsWith('.mp3') ||
              filename.endsWith('.gsm')) {
            recordings.add(filename);
          }
        }
      }

      _logger.i('Found ${recordings.length} recordings');
      return recordings;
    });
  }

  /// دانلود یک فایل ضبط شده
  /// 
  /// [remotePath] مسیر کامل فایل در سرور
  /// [localPath] مسیر محلی برای ذخیره (اختیاری، اگر null باشد در temp ذخیره می‌شود)
  /// 
  /// برمی‌گرداند: فایل دانلود شده
  Future<File> downloadRecording(String remotePath, {String? localPath}) async {
    return await _executeWithRecovery(() async {
      _logger.i('Downloading: $remotePath');

      // اگر مسیر محلی مشخص نشده، در temp ذخیره کن
      if (localPath == null) {
        final tempDir = await getTemporaryDirectory();
        final filename = remotePath.split('/').last;
        localPath = '${tempDir.path}/recordings/$filename';
      }

      // ایجاد پوشه در صورت عدم وجود
      final localFile = File(localPath!);
      await localFile.parent.create(recursive: true);

      // دانلود فایل
      final remoteFile = await _sftp!.open(remotePath);
      final sink = localFile.openWrite();

      try {
        await for (final chunk in remoteFile.read()) {
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }

      _logger.i('Downloaded successfully: $localPath');
      return localFile;
    });
  }

  /// دانلود فایل ضبط بر اساس uniqueid تماس
  /// 
  /// این متد خودکار مسیر فایل را پیدا می‌کند
  Future<File?> downloadRecordingByUniqueId(String uniqueid, String callDate) async {
    return await _executeWithRecovery(() async {
      // لیست فایل‌های آن روز
      final recordings = await listRecordings(callDate);
      
      // پیدا کردن فایل با uniqueid
      final filename = recordings.firstWhere(
        (name) => name.contains(uniqueid),
        orElse: () => '',
      );

      if (filename.isEmpty) {
        _logger.w('Recording not found for uniqueid: $uniqueid');
        return null;
      }

      // ساخت مسیر کامل
      // Extract only date part (YYYY-MM-DD) if datetime is passed
      final dateOnly = callDate.length > 10 ? callDate.substring(0, 10) : callDate;
      final dateParts = dateOnly.split('-');
      final year = dateParts[0];
      final month = dateParts[1];
      final day = dateParts[2];
      final remotePath = '${config.recordingsPath}/$year/$month/$day/$filename';

      // دانلود
      return await downloadRecording(remotePath);
    });
  }

  /// اجرای یک دستور SSH در سرور
  /// 
  /// برای debugging و تست
  Future<String> executeCommand(String command) async {
    return await _executeWithRecovery(() async {
      final result = await _client!.run(command);
      final output = String.fromCharCodes(result);
      
      return output.trim();
    });
  }

  /// تست اتصال
  Future<bool> testConnection() async {
    try {
      await connect();
      
      // تست با لیست کردن پوشه recordings
      final output = await executeCommand('ls -la ${config.recordingsPath}');
      
      await disconnect();
      
      return output.isNotEmpty;
    } catch (e) {
      _logger.e('Connection test failed: $e');
      return false;
    }
  }

  bool get isConnected => _isConnected;
}

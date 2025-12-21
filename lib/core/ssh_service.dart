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

  SshService(this.config);

  /// اتصال به سرور SSH
  Future<void> connect() async {
    if (_isConnected && _client != null) {
      _logger.d('SSH already connected');
      return;
    }

    try {
      _logger.i('Connecting to SSH: ${config.username}@${config.host}:${config.port}');

      final socket = await SSHSocket.connect(
        config.host,
        config.port,
        timeout: const Duration(seconds: 10),
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
      
      _logger.i('SSH connected successfully');
    } catch (e) {
      _logger.e('SSH connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// قطع اتصال
  void disconnect() {
    try {
      _sftp?.close();
      _client?.close();
      _isConnected = false;
      _logger.i('SSH disconnected');
    } catch (e) {
      _logger.e('Error disconnecting SSH: $e');
    }
  }

  /// بررسی وجود فایل در سرور
  Future<bool> fileExists(String remotePath) async {
    if (!_isConnected) await connect();

    try {
      final stat = await _sftp!.stat(remotePath);
      return !stat.isDirectory; // Check it's a file, not a directory
    } catch (e) {
      _logger.w('File not found: $remotePath - $e');
      return false;
    }
  }

  /// دریافت لیست فایل‌های ضبط شده در یک تاریخ خاص
  /// 
  /// [date] به فرمت YYYY-MM-DD
  /// برمی‌گرداند: لیست نام فایل‌ها (فقط نام، نه مسیر کامل)
  Future<List<String>> listRecordings(String date) async {
    if (!_isConnected) await connect();

    try {
      // تبدیل تاریخ به فرمت مسیر: /var/spool/asterisk/monitor/2025/01/15/
      final dateParts = date.split('-');
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
    } catch (e) {
      _logger.e('Error listing recordings: $e');
      // اگر پوشه وجود نداشت، لیست خالی برگردان
      return [];
    }
  }

  /// دانلود یک فایل ضبط شده
  /// 
  /// [remotePath] مسیر کامل فایل در سرور
  /// [localPath] مسیر محلی برای ذخیره (اختیاری، اگر null باشد در temp ذخیره می‌شود)
  /// 
  /// برمی‌گرداند: فایل دانلود شده
  Future<File> downloadRecording(String remotePath, {String? localPath}) async {
    if (!_isConnected) await connect();

    try {
      _logger.i('Downloading: $remotePath');

      // اگر مسیر محلی مشخص نشده، در temp ذخیره کن
      if (localPath == null) {
        final tempDir = await getTemporaryDirectory();
        final filename = remotePath.split('/').last;
        localPath = '${tempDir.path}/recordings/$filename';
      }

      // ایجاد پوشه در صورت عدم وجود
      final localFile = File(localPath);
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
    } catch (e) {
      _logger.e('Error downloading file: $e');
      rethrow;
    }
  }

  /// دانلود فایل ضبط بر اساس uniqueid تماس
  /// 
  /// این متد خودکار مسیر فایل را پیدا می‌کند
  Future<File?> downloadRecordingByUniqueId(String uniqueid, String callDate) async {
    try {
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
      final dateParts = callDate.split('-');
      final year = dateParts[0];
      final month = dateParts[1];
      final day = dateParts[2];
      final remotePath = '${config.recordingsPath}/$year/$month/$day/$filename';

      // دانلود
      return await downloadRecording(remotePath);
    } catch (e) {
      _logger.e('Error downloading recording by uniqueid: $e');
      return null;
    }
  }

  /// اجرای یک دستور SSH در سرور
  /// 
  /// برای debugging و تست
  Future<String> executeCommand(String command) async {
    if (!_isConnected) await connect();

    try {
      _logger.d('Executing: $command');
      
      final result = await _client!.run(command);
      final output = String.fromCharCodes(result);
      
      _logger.d('Command output: $output');
      return output.trim();
    } catch (e) {
      _logger.e('Error executing command: $e');
      rethrow;
    }
  }

  /// تست اتصال
  Future<bool> testConnection() async {
    try {
      await connect();
      
      // تست با لیست کردن پوشه recordings
      final output = await executeCommand('ls -la ${config.recordingsPath}');
      
      disconnect();
      
      return output.isNotEmpty;
    } catch (e) {
      _logger.e('Connection test failed: $e');
      return false;
    }
  }

  bool get isConnected => _isConnected;
}

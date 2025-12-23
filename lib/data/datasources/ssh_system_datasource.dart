import 'package:logger/logger.dart';
import '../../core/services/asterisk_ssh_manager.dart';
import '../../core/services/script_models.dart';

/// System information DataSource using SSH + Python Script
class SshSystemDataSource {
  final AsteriskSshManager sshManager;
  final Logger _logger = Logger();

  SshSystemDataSource({required this.sshManager});

  /// Get system information
  Future<SystemInfo?> getSystemInfo() async {
    try {
      final response = await sshManager.getSystemInfo();

      if (!response.isSuccess) {
        _logger.e('Failed to get system info: ${response.error}');
        return null;
      }

      return response.data;
    } catch (e) {
      _logger.e('Error fetching system info: $e');
      return null;
    }
  }

  /// Check AMI status
  Future<AmiStatus?> checkAmiStatus() async {
    try {
      final response = await sshManager.checkAmi();

      if (!response.isSuccess) {
        _logger.e('Failed to check AMI: ${response.error}');
        return null;
      }

      return response.data;
    } catch (e) {
      _logger.e('Error checking AMI: $e');
      return null;
    }
  }

  /// Setup AMI (enable and create user)
  Future<AmiCredentials?> setupAmi({
    String username = 'astrix_assist',
    String? password,
  }) async {
    try {
      final response = await sshManager.setupAmi(
        username: username,
        password: password,
      );

      if (!response.isSuccess) {
        _logger.e('Failed to setup AMI: ${response.error}');
        return null;
      }

      _logger.i('AMI setup successful: ${response.data?.username}');
      return response.data;
    } catch (e) {
      _logger.e('Error setting up AMI: $e');
      return null;
    }
  }

  /// Get recordings list
  Future<List<RecordingInfo>> getRecordings({int days = 7}) async {
    try {
      final response = await sshManager.getRecordings(days: days);

      if (!response.isSuccess) {
        _logger.e('Failed to get recordings: ${response.error}');
        return [];
      }

      return response.data?.recordings ?? [];
    } catch (e) {
      _logger.e('Error fetching recordings: $e');
      return [];
    }
  }
}

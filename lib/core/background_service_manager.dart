import 'package:workmanager/workmanager.dart';
import 'package:logger/logger.dart';
import 'notification_service.dart';

const String _checkConnectionTaskName = 'checkConnection';
const String _checkQueueStatusTaskName = 'checkQueueStatus';

class BackgroundServiceManager {
  static final BackgroundServiceManager _instance =
      BackgroundServiceManager._internal();
  final Logger logger = Logger();

  factory BackgroundServiceManager() {
    return _instance;
  }

  BackgroundServiceManager._internal();

  Future<void> initialize() async {
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      logger.i('BackgroundServiceManager initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize BackgroundServiceManager: $e');
    }
  }

  Future<void> scheduleConnectionCheck() async {
    try {
      await Workmanager().registerPeriodicTask(
        _checkConnectionTaskName,
        _checkConnectionTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        initialDelay: const Duration(minutes: 1),
      );
      logger.i('Connection check scheduled every 15 minutes');
    } catch (e) {
      logger.e('Failed to schedule connection check: $e');
    }
  }

  Future<void> scheduleQueueStatusCheck() async {
    try {
      await Workmanager().registerPeriodicTask(
        _checkQueueStatusTaskName,
        _checkQueueStatusTaskName,
        frequency: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        initialDelay: const Duration(minutes: 1),
      );
      logger.i('Queue status check scheduled every 5 minutes');
    } catch (e) {
      logger.e('Failed to schedule queue status check: $e');
    }
  }

  Future<void> cancelConnectionCheck() async {
    try {
      await Workmanager().cancelByTag(_checkConnectionTaskName);
      logger.i('Connection check cancelled');
    } catch (e) {
      logger.e('Failed to cancel connection check: $e');
    }
  }

  Future<void> cancelQueueStatusCheck() async {
    try {
      await Workmanager().cancelByTag(_checkQueueStatusTaskName);
      logger.i('Queue status check cancelled');
    } catch (e) {
      logger.e('Failed to cancel queue status check: $e');
    }
  }

  Future<void> cancelAllBackgroundTasks() async {
    try {
      await Workmanager().cancelAll();
      logger.i('All background tasks cancelled');
    } catch (e) {
      logger.e('Failed to cancel all background tasks: $e');
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((
    String taskName,
    Map<String, dynamic>? inputData,
  ) async {
    try {
      final notificationService = NotificationService();

      if (taskName == _checkConnectionTaskName) {
        // Check if connection is still alive
        // This is a simple check - in real app, ping the server
        await notificationService.showNotification(
          title: 'وضعیت بررسی',
          body: 'سرور هنوز فعال است',
          type: NotificationType.alertMessage,
        );
      } else if (taskName == _checkQueueStatusTaskName) {
        // Check queue status
        // In real app, query queue status from database or AMI
        await notificationService.showNotification(
          title: 'وضعیت صف بررسی شد',
          body: 'صف‌ها در حالت عادی هستند',
          type: NotificationType.alertMessage,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  });
}

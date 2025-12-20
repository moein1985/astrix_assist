import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

enum NotificationType {
  connectionLost,
  connectionRestored,
  queueOverflow,
  extensionOffline,
  extensionOnline,
  callIncoming,
  alertMessage,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger logger = Logger();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      logger.i('NotificationService initialized successfully');
    } catch (e) {
      logger.e('Failed to initialize NotificationService: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'astrix_assist_channel',
            'Astrix Notifications',
            channelDescription: 'Notifications for Astrix Assist',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        type.hashCode,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      logger.i('Notification shown: $title');
    } catch (e) {
      logger.e('Failed to show notification: $e');
    }
  }

  Future<void> showConnectionLostNotification() async {
    await showNotification(
      title: 'اتصال قطع شد',
      body: 'اتصال به سرور Asterisk قطع شده است',
      type: NotificationType.connectionLost,
    );
  }

  Future<void> showConnectionRestoredNotification() async {
    await showNotification(
      title: 'اتصال برقرار شد',
      body: 'اتصال به سرور Asterisk دوباره برقرار شده است',
      type: NotificationType.connectionRestored,
    );
  }

  Future<void> showQueueOverflowNotification({
    required String queueName,
    required int waitingCalls,
  }) async {
    await showNotification(
      title: 'صف شلوغ است',
      body: 'صف $queueName: $waitingCalls تماس در انتظار',
      type: NotificationType.queueOverflow,
      payload: queueName,
    );
  }

  Future<void> showExtensionOfflineNotification({
    required String extensionNumber,
  }) async {
    await showNotification(
      title: 'داخلی آفلاین شد',
      body: 'داخلی $extensionNumber آفلاین شده است',
      type: NotificationType.extensionOffline,
      payload: extensionNumber,
    );
  }

  Future<void> showExtensionOnlineNotification({
    required String extensionNumber,
  }) async {
    await showNotification(
      title: 'داخلی متصل شد',
      body: 'داخلی $extensionNumber دوباره متصل شده است',
      type: NotificationType.extensionOnline,
      payload: extensionNumber,
    );
  }

  Future<void> showCallIncomingNotification({
    required String callerNumber,
    required String callerName,
  }) async {
    await showNotification(
      title: 'تماس دریافتی',
      body: '$callerName ($callerNumber)',
      type: NotificationType.callIncoming,
      payload: callerNumber,
    );
  }

  Future<void> cancelNotification(NotificationType type) async {
    try {
      await _notificationsPlugin.cancel(type.hashCode);
      logger.i('Notification canceled: ${type.toString()}');
    } catch (e) {
      logger.e('Failed to cancel notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      logger.i('All notifications canceled');
    } catch (e) {
      logger.e('Failed to cancel all notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    logger.i('Notification tapped: ${response.payload}');
    // Handle notification tap
  }
}

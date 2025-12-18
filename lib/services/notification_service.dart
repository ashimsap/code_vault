import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    // **THE FIX: Provide the resource NAME ONLY. Android will find it.**
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showConnectionNotification(String ipAddress) async {
    final notificationId = ipAddress.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'new_connection', // channel ID
      'New Connections', // channel name
      channelDescription: 'Notifications for new client connections.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      notificationId, 
      'New Client Connection',
      'A new client is requesting permission from: $ipAddress',
      notificationDetails,
    );
  }
}

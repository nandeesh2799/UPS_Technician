import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // 2. Request Permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // 3. Set Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        showNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
        );
      }
    });

    // 5. Handle Notification Taps (Background & Terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    _messaging.getInitialMessage().then((message) {
      if (message != null) _handleMessageTap(message);
    });

    // 6. Get FCM Token
    String? token = await _messaging.getToken();
    debugPrint("FCM Token: $token");

    // 7. Handle Token Refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
      FirebaseService().updateFcmToken(newToken);
    });
  }

  static void _handleMessageTap(RemoteMessage message) {
    debugPrint("Message tapped: ${message.data}");
    // Example: Navigate to a specific screen based on data
    // GlobalKeys.navigatorKey.currentState?.pushNamed('/notifications');
  }

  static Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'ups_service_channel', 
      'UPS Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(id, title, body, platformChannelSpecifics);
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

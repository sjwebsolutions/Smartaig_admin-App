import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static NotificationService get to => Get.find();

  Future<NotificationService> init() async {
    // 1. Request permissions for iOS and Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    }

    // 2. Request native Android 13+ Notification Permission
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 3. Set foreground notification presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Register high priority notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'callback_notification_channel',
      'Callback & Alert Notifications',
      description: 'Channel for callback requests and urgent admin alerts',
      importance: Importance.max,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // 5. Subscribe to all relevant callback, leave, announcement, banner, and admin topics asynchronously
    final List<String> topics = [
      'all',
      'admins',
      'admin',
      'school_admin',
      'admin_notifications',
      'callback_requests',
      'callback_request',
      'callbacks',
      'callback',
      'admin_callbacks',
      'admin_callback_requests',
      'teacher_leaves',
      'teacher_leave_requests',
      'student_leaves',
      'student_leave_requests',
      'leave_requests',
      'leaves',
      'announcements',
      'announcement',
      'banners',
      'banner',
      'announcements_all',
      'banners_all',
      'notifications',
    ];

    Future.microtask(() async {
      for (String topic in topics) {
        try {
          await _messaging.subscribeToTopic(topic);
        } catch (e) {
          // Continue subscribing
        }
      }
    });

    // 6. Fetch & sync FCM token with backend server
    try {
      String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        print("FCM Token: $token");
        AuthService().updateFcmTokenOnServer(token);
      }
      _messaging.onTokenRefresh.listen((newToken) {
        print("FCM Token Refreshed: $newToken");
        AuthService().updateFcmTokenOnServer(newToken);
      });
    } catch (e) {
      print("Error fetching FCM token: $e");
    }

    // 7. Foreground notifications listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      String title = notification?.title ?? 
          message.data['title'] ?? 
          message.data['heading'] ?? 
          message.data['subject'] ?? 
          (message.data['type']?.toString().contains('callback') == true ? 'New Callback Request' : null) ??
          'New Callback Request';

      String body = notification?.body ?? 
          message.data['body'] ?? 
          message.data['message'] ?? 
          message.data['content'] ?? 
          message.data['reason'] ?? 
          (message.data['parent_name'] != null ? 'Callback request from ${message.data['parent_name']}' : null) ??
          'You have received a new callback request.';

      _localNotifications.show(
        notification?.hashCode ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            styleInformation: const BigTextStyleInformation(''),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );
    });

    // 8. Handle when app is opened from a notification (terminated state)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data.toString());
    }

    // 9. Handle when app is opened from a notification (background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data.toString());
    });

    return this;
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      print("Notification Tapped with payload: $payload");
    }
  }

  Future<String?> getToken() async {
    String? token = await _messaging.getToken();
    print("FCM Token: $token");
    return token;
  }

  Future<void> showLocalNotification(String title, String body, {String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'callback_notification_channel',
      'Callback & Alert Notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
        sound: 'default',
      ),
    );
    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

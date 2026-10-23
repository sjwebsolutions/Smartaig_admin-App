import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';
import 'package:smart_aig_admins_app/view_models/getX/notification_controller.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  static NotificationService get to => Get.find();

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint("Audio sound play error: $e");
    }
  }

  Future<NotificationService> init() async {
    // Enable iOS Playback Audio Category so sound plays even on silent / simulator
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.notification,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error setting AudioContext: $e");
    }

    // 1. Request permissions for iOS and Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
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
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // 5. Asynchronously register FCM Token and subscribe to topics
    Future.microtask(() async {
      await syncFcmTokenAndSubscriptions();
    });

    // 6. Listen for FCM token refreshes and re-sync
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("FCM Token Refreshed: $newToken");
      await AuthService().updateFcmTokenOnServer(newToken);
      await _subscribeToDefaultTopics();
    });

    // 7. Foreground notifications listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;

      String title = notification?.title ?? 
          message.data['title'] ?? 
          message.data['heading'] ?? 
          message.data['subject'] ?? 
          (message.data['type']?.toString().contains('callback') == true ? 'New Callback Request 📞' : null) ??
          'New Callback Request 📞';

      String body = notification?.body ?? 
          message.data['body'] ?? 
          message.data['message'] ?? 
          message.data['content'] ?? 
          message.data['reason'] ?? 
          (message.data['parent_name'] != null ? 'Callback request from ${message.data['parent_name']}' : null) ??
          'You have received a new callback request.';

      try {
        NotificationController.to.incrementUnread();
      } catch (_) {}

      showLocalNotification(title, body, payload: message.data.isNotEmpty ? message.data.toString() : null);
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

  /// Ensures APNs token is checked quickly on iOS without blocking
  Future<bool> _ensureApnsTokenReady() async {
    if (Platform.isIOS) {
      try {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) return true;
        for (int i = 0; i < 3; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) {
            debugPrint('iOS APNs token acquired: $apnsToken');
            return true;
          }
        }
      } catch (e) {
        debugPrint("APNs check error: $e");
      }
    }
    return true;
  }

  /// Syncs FCM Token with backend and subscribes to default topics
  Future<void> syncFcmTokenAndSubscriptions() async {
    await _ensureApnsTokenReady();

    // Fetch & sync FCM token with backend server
    try {
      String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("FCM Token (${Platform.operatingSystem}): $token");
        await AuthService().updateFcmTokenOnServer(token);
      }
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }

    await _subscribeToDefaultTopics();
  }

  Future<void> _subscribeToDefaultTopics() async {
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
      'support_crew',
      'support_crew_banners',
      'notifications',
    ];

    for (String topic in topics) {
      await subscribeToTopicSafely(topic);
    }
  }

  /// Safely subscribe to any single topic
  Future<void> subscribeToTopicSafely(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint("Successfully subscribed to topic: $topic");
    } catch (e) {
      debugPrint("Error subscribing to topic $topic: $e");
    }
  }

  /// Subscribe to school-specific topics when dashboard or user details load
  Future<void> syncSchoolTopics(String schoolCode) async {
    final cleanCode = schoolCode.trim();
    if (cleanCode.isEmpty) return;

    final List<String> schoolTopics = [
      'callback_requests_$cleanCode',
      'callbacks_$cleanCode',
      'callback_$cleanCode',
      'announcements_$cleanCode',
      'banners_$cleanCode',
      'school_$cleanCode',
      'admin_$cleanCode',
    ];

    for (String topic in schoolTopics) {
      await subscribeToTopicSafely(topic);
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      debugPrint("Notification Tapped with payload: $payload");
    }
  }

  Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM Token: $e");
      return null;
    }
  }

  Future<void> showLocalNotification(String title, String body, {String? payload}) async {
    _playNotificationSound();

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
    
    int id = DateTime.now().microsecondsSinceEpoch.remainder(1000000).abs();
    if (id == 0) id = 1;

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );

    try {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        icon: const Icon(Icons.phone_callback_rounded, color: Colors.greenAccent),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        isDismissible: true,
      );
    } catch (_) {}
  }
}

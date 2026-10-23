import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/view_models/getX/announcement_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';

class NotificationController extends GetxController {
  static NotificationController get to {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return Get.put(NotificationController(), permanent: true);
  }

  static const String _keyLastViewedTime = 'notification_last_viewed_time';
  static const String _keyLastTotalCount = 'notification_last_total_count';

  final RxInt unreadCount = 0.obs;
  DateTime? lastViewedTime;
  int lastTotalCount = 0;
  bool _isLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _initPersistence();
  }

  Future<void> _initPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_keyLastViewedTime);
      if (timeStr != null && timeStr.isNotEmpty) {
        lastViewedTime = DateTime.tryParse(timeStr);
      }
      lastTotalCount = prefs.getInt(_keyLastTotalCount) ?? 0;
      _isLoaded = true;

      // Sync count if controllers already have data
      syncUnreadCount();

      // Listen to future data changes
      _bindListeners();
    } catch (e) {
      debugPrint("NotificationController _initPersistence error: $e");
      _isLoaded = true;
    }
  }

  void _bindListeners() {
    if (Get.isRegistered<AnnouncementController>()) {
      ever(Get.find<AnnouncementController>().announcements, (_) => syncUnreadCount());
    }
    if (Get.isRegistered<DashboardController>()) {
      ever(Get.find<DashboardController>().dashboardData, (_) => syncUnreadCount());
    }
  }

  /// Calculates unread count from available data
  void syncUnreadCount() {
    if (!_isLoaded) return;

    final announcementController = Get.isRegistered<AnnouncementController>()
        ? Get.find<AnnouncementController>()
        : null;
    final dashboardController = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : null;

    final dashData = dashboardController?.dashboardData.value;
    final pendingCallbacks = dashData?.callbackRequests?.pending ?? 0;
    final pendingTeacherLeaves = dashData?.teacherLeaves?.totalPendingCount ?? 0;
    final pendingStudentLeaves = dashData?.studentLeaves?.totalPendingCount ?? 0;
    final totalAnnouncements = announcementController?.totalAnnouncements ?? 0;

    final currentTotal = totalAnnouncements +
        pendingCallbacks +
        pendingTeacherLeaves +
        pendingStudentLeaves;

    if (lastViewedTime == null) {
      // User hasn't opened notification screen yet
      unreadCount.value = currentTotal;
    } else {
      // Calculate how many new items appeared since last view
      if (currentTotal > lastTotalCount) {
        unreadCount.value = currentTotal - lastTotalCount;
      } else if (unreadCount.value < 0) {
        unreadCount.value = 0;
      }
    }
  }

  /// Called whenever a push notification arrives
  void incrementUnread() {
    unreadCount.value++;
  }

  /// Called when user opens/views the NotificationScreen
  Future<void> markAsViewed([int? currentTotal]) async {
    unreadCount.value = 0;
    lastViewedTime = DateTime.now();

    if (currentTotal != null) {
      lastTotalCount = currentTotal;
    } else {
      final announcementController = Get.isRegistered<AnnouncementController>()
          ? Get.find<AnnouncementController>()
          : null;
      final dashboardController = Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : null;
      final dashData = dashboardController?.dashboardData.value;
      final pendingCallbacks = dashData?.callbackRequests?.pending ?? 0;
      final pendingTeacherLeaves = dashData?.teacherLeaves?.totalPendingCount ?? 0;
      final pendingStudentLeaves = dashData?.studentLeaves?.totalPendingCount ?? 0;
      final totalAnnouncements = announcementController?.totalAnnouncements ?? 0;

      lastTotalCount = totalAnnouncements +
          pendingCallbacks +
          pendingTeacherLeaves +
          pendingStudentLeaves;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastViewedTime, lastViewedTime!.toIso8601String());
      await prefs.setInt(_keyLastTotalCount, lastTotalCount);
    } catch (e) {
      debugPrint("NotificationController markAsViewed save error: $e");
    }
  }
}

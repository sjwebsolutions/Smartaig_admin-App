import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/notification_model.dart';
import 'package:smart_aig_admins_app/services/api_notification_service.dart';

class NotificationController extends GetxController {
  static NotificationController get to {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return Get.put(NotificationController(), permanent: true);
  }

  static const String _keyLastViewedTime = 'notification_last_viewed_time';
  static const String _keyLastTotalCount = 'notification_last_total_count';

  final ApiNotificationService _apiService = ApiNotificationService();

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;

  int currentPage = 1;
  int lastPage = 1;
  bool hasMore = false;
  int retentionDays = 7;
  DateTime? lastViewedTime;
  int lastTotalCount = 0;

  @override
  void onInit() {
    super.onInit();
    _initPersistence();
    fetchNotifications();
  }

  Future<void> _initPersistence() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString(_keyLastViewedTime);
      if (timeStr != null && timeStr.isNotEmpty) {
        lastViewedTime = DateTime.tryParse(timeStr);
      }
      lastTotalCount = prefs.getInt(_keyLastTotalCount) ?? 0;
    } catch (e) {
      debugPrint("NotificationController _initPersistence error: $e");
    }
  }

  /// Fetches notifications from API (Page 1)
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (!isRefresh && notifications.isNotEmpty && isLoading.value) return;

    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _apiService.getNotifications(page: 1);
      if (response.success && response.data != null) {
        notifications.assignAll(response.data!.notifications);
        retentionDays = response.data!.retentionDays;

        if (response.data!.pagination != null) {
          currentPage = response.data!.pagination!.currentPage;
          lastPage = response.data!.pagination!.lastPage;
          hasMore = response.data!.pagination!.hasMore;
        } else {
          currentPage = 1;
          lastPage = 1;
          hasMore = false;
        }

        _calculateUnreadCount();
      } else {
        errorMessage.value = response.message.isNotEmpty
            ? response.message
            : "Failed to load notifications";
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      errorMessage.value = "Failed to load notifications. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetches next page of notifications from API
  Future<void> fetchMoreNotifications() async {
    if (isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;
    final nextPage = currentPage + 1;

    try {
      final response = await _apiService.getNotifications(page: nextPage);
      if (response.success && response.data != null) {
        notifications.addAll(response.data!.notifications);

        if (response.data!.pagination != null) {
          currentPage = response.data!.pagination!.currentPage;
          lastPage = response.data!.pagination!.lastPage;
          hasMore = response.data!.pagination!.hasMore;
        } else {
          hasMore = false;
        }

        _calculateUnreadCount();
      }
    } catch (e) {
      debugPrint("Error fetching more notifications: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _calculateUnreadCount() {
    final unreadItems = notifications.where((n) => !n.isRead).length;
    if (unreadItems > 0) {
      unreadCount.value = unreadItems;
    } else {
      if (lastViewedTime == null) {
        unreadCount.value = notifications.length;
      } else {
        if (notifications.length > lastTotalCount) {
          unreadCount.value = notifications.length - lastTotalCount;
        } else if (unreadCount.value < 0) {
          unreadCount.value = 0;
        }
      }
    }
  }

  /// Called when push notification arrives
  void incrementUnread() {
    unreadCount.value++;
    // Refetch to get updated API notifications list
    fetchNotifications(isRefresh: true);
  }

  /// Called when user opens/views the NotificationScreen
  Future<void> markAsViewed([int? currentTotal]) async {
    unreadCount.value = 0;
    lastViewedTime = DateTime.now();
    lastTotalCount = currentTotal ?? notifications.length;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastViewedTime, lastViewedTime!.toIso8601String());
      await prefs.setInt(_keyLastTotalCount, lastTotalCount);
    } catch (e) {
      debugPrint("NotificationController markAsViewed save error: $e");
    }
  }
}

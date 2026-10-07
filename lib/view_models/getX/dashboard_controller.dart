import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';
import 'package:smart_aig_admins_app/services/callback_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';

class DashboardController extends GetxController {
  final AuthService _authService = AuthService();
  final CallbackService _callbackService = CallbackService();
  
  var isLoading = true.obs;
  var hasError = false.obs;
  var dashboardData = Rxn<DashboardData>();
  Timer? _callbackCheckTimer;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    _startCallbackPolling();
  }

  void _startCallbackPolling() {
    _callbackCheckTimer?.cancel();
    _callbackCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNewCallbacksInBackground();
    });
  }

  Future<void> _checkNewCallbacksInBackground() async {
    try {
      final summaryRes = await _callbackService.getCallbackSummary();
      if (summaryRes.success && summaryRes.data != null) {
        final newPending = summaryRes.data!.pending;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int previousPending = prefs.getInt('last_callback_pending_count') ?? -1;

        if (previousPending != -1 && newPending > previousPending) {
          if (Get.isRegistered<NotificationService>()) {
            NotificationService.to.showLocalNotification(
              "New Callback Request 📞",
              "You have a new parent callback request waiting for response.",
              payload: "callback_request",
            );
          }
        }
        await prefs.setInt('last_callback_pending_count', newPending);
      }
    } catch (_) {}
  }

  Future<void> fetchDashboardData() async {
    try {
      if (kDebugMode) {
        debugPrint("DEBUG: fetchDashboardData started");
      }
      if (dashboardData.value == null) {
        isLoading.value = true;
      }
      hasError.value = false;

      final response = await _authService.getDashboardData();

      if (response.success && response.data != null) {
        dashboardData.value = response.data;
        hasError.value = false;

        final newCallbackPending = response.data?.callbackRequests?.pending ?? 0;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int previousPending = prefs.getInt('last_callback_pending_count') ?? -1;

        if (previousPending != -1 && newCallbackPending > previousPending) {
          if (Get.isRegistered<NotificationService>()) {
            NotificationService.to.showLocalNotification(
              "New Callback Request 📞",
              "You have $newCallbackPending pending callback request(s). Please review.",
              payload: "callback_request",
            );
          }
        }
        await prefs.setInt('last_callback_pending_count', newCallbackPending);

        final schoolCode = response.data!.school.schoolCode.trim();
        if (schoolCode.isNotEmpty) {
          try {
            final messaging = FirebaseMessaging.instance;
            messaging.subscribeToTopic('callback_requests_$schoolCode');
            messaging.subscribeToTopic('callbacks_$schoolCode');
            messaging.subscribeToTopic('announcements_$schoolCode');
            messaging.subscribeToTopic('banners_$schoolCode');
            messaging.subscribeToTopic('school_$schoolCode');
            messaging.subscribeToTopic('admin_$schoolCode');
          } catch (e) {
            if (kDebugMode) {
              debugPrint("Error subscribing to school code topics: $e");
            }
          }
        }

        if (kDebugMode) {
          debugPrint("DEBUG: Dashboard Data loaded successfully");
        }
      } else {
        if (dashboardData.value == null) {
          hasError.value = true;
        }
        if (kDebugMode) {
          debugPrint("DEBUG: Failed to load dashboard data. Success: ${response.success}");
        }
      }
    } catch (e) {
      if (dashboardData.value == null) {
        hasError.value = true;
      }
      if (kDebugMode) {
        debugPrint("DEBUG: Error in fetchDashboardData: $e");
      }
    } finally {
      isLoading.value = false;
      if (kDebugMode) {
        debugPrint("DEBUG: fetchDashboardData finished");
      }
    }
  }

  @override
  void onClose() {
    _callbackCheckTimer?.cancel();
    super.onClose();
  }
}

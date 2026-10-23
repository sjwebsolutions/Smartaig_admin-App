import 'dart:async';
import 'dart:convert';
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
    _loadCachedDashboardData();
    fetchDashboardData();
    _startCallbackPolling();
  }

  Future<void> _loadCachedDashboardData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedJson = prefs.getString('cached_dashboard_data');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final decoded = jsonDecode(cachedJson);
        if (decoded is Map<String, dynamic>) {
          dashboardData.value = DashboardData.fromJson(decoded);
          isLoading.value = false;
          if (kDebugMode) {
            debugPrint("DEBUG: Loaded cached dashboard data instantly");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error loading cached dashboard data: $e");
      }
    }
  }

  void _startCallbackPolling() {
    _callbackCheckTimer?.cancel();
    _callbackCheckTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkNewCallbacksInBackground();
    });
  }

  Future<void> _checkNewCallbacksInBackground() async {
    try {
      final summaryRes = await _callbackService.getCallbackSummary();
      if (summaryRes.success && summaryRes.data != null) {
        final newPending = summaryRes.data!.pending;
        final newTotal = summaryRes.data!.total;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int previousPending = prefs.getInt('last_callback_pending_count') ?? -1;
        final int previousTotal = prefs.getInt('last_callback_total_count') ?? -1;

        if ((previousPending != -1 && newPending > previousPending) ||
            (previousTotal != -1 && newTotal > previousTotal)) {
          if (Get.isRegistered<NotificationService>()) {
            NotificationService.to.showLocalNotification(
              "New Callback Request 📞",
              "You have a new parent callback request waiting for response.",
              payload: "callback_request",
            );
          }
          fetchDashboardData();
        }
        await prefs.setInt('last_callback_pending_count', newPending);
        await prefs.setInt('last_callback_total_count', newTotal);
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
        isLoading.value = false;

        // Save fresh dashboard data to local cache
        try {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_dashboard_data', jsonEncode(response.data!.toJson()));
        } catch (e) {
          if (kDebugMode) {
            debugPrint("Error saving cached dashboard data: $e");
          }
        }

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
            if (Get.isRegistered<NotificationService>()) {
              NotificationService.to.syncSchoolTopics(schoolCode);
            } else {
              final messaging = FirebaseMessaging.instance;
              messaging.subscribeToTopic('callback_requests_$schoolCode');
              messaging.subscribeToTopic('callbacks_$schoolCode');
              messaging.subscribeToTopic('announcements_$schoolCode');
              messaging.subscribeToTopic('banners_$schoolCode');
              messaging.subscribeToTopic('school_$schoolCode');
              messaging.subscribeToTopic('admin_$schoolCode');
            }
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

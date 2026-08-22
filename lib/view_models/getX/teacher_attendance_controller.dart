import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/teacher_attendance_report_model.dart';
import 'package:smart_aig_admins_app/services/teacher_attendance_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherAttendanceController extends GetxController {
  final TeacherAttendanceService _attendanceService = TeacherAttendanceService();

  var isLoading = true.obs;
  var attendanceData = Rxn<TeacherAttendanceData>();
  var success = false.obs;
  
  // Badge logic
  var unreadCount = 0.obs;
  int _lastNotifiedCount = -1;

  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
    fetchAttendanceSummary();
    _startAutoRefresh(); // Start automatic refresh here
  }

  Future<void> _loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    _lastNotifiedCount = prefs.getInt('last_notified_teacher_present_$today') ?? -1;
  }

  @override
  void onClose() {
    _refreshTimer?.cancel(); // Stop the timer when the screen is closed
    super.onClose();
  }

  void _startAutoRefresh() {
    // 5 seconds interval used here
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchAttendanceSummary(showLoading: false);
    });
  }

  Future<void> markAsRead() async {
    unreadCount.value = 0;
    if (attendanceData.value != null) {
      final prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toString().split(' ')[0];
      int currentPresent = attendanceData.value!.stats.present;
      await prefs.setInt('last_seen_teacher_present_$today', currentPresent);
      await prefs.setInt('last_notified_teacher_present_$today', currentPresent);
      _lastNotifiedCount = currentPresent;
    }
  }

  Future<void> fetchAttendanceSummary({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      final response = await _attendanceService.getTodaySummary();
      success.value = response.success;
      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();
        String today = DateTime.now().toString().split(' ')[0];
        
        int lastSeenCount = prefs.getInt('last_seen_teacher_present_$today') ?? 0;
        int currentPresentCount = response.data!.stats.present;

        // Update unread count based on difference from last seen
        if (currentPresentCount > lastSeenCount) {
          unreadCount.value = currentPresentCount - lastSeenCount;
        } else {
          unreadCount.value = 0;
        }

        // Trigger notification only if present count has increased since we last notified
        if (_lastNotifiedCount != -1 && currentPresentCount > _lastNotifiedCount) {
          NotificationService.to.showLocalNotification(
            "Teacher Attendance Updated",
            "New teacher attendance has been marked.",
          );
          
          // Update last notified count to prevent repeated alerts for same data
          _lastNotifiedCount = currentPresentCount;
          await prefs.setInt('last_notified_teacher_present_$today', currentPresentCount);
        } else if (_lastNotifiedCount == -1) {
          // Initialize lastNotifiedCount on first fetch
          _lastNotifiedCount = currentPresentCount;
          await prefs.setInt('last_notified_teacher_present_$today', currentPresentCount);
        }

        attendanceData.value = response.data;
        print("Teacher Attendance Data: ${response.data!.stats.totalStaff} total staff, $currentPresentCount present");
      }
    } catch (e) {
      print("TeacherAttendanceController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendAttendanceReminder(String teacherName, String teacherUid) async {
    try {
      final response = await _attendanceService.sendAttendanceReminder(teacherUid);
      
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          "Attendance reminder sent to $teacherName",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        
        // Also show a local notification for admin's confirmation
        await NotificationService.to.showLocalNotification(
          "Reminder Sent",
          "Notification successfully delivered to $teacherName",
        );
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to send reminder",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("TeacherAttendanceController Error: $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    }
  }
}

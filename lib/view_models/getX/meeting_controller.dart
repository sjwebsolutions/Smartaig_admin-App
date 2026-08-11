import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/meeting_model.dart';
import 'package:smart_aig_admins_app/services/meeting_service.dart';

class MeetingController extends GetxController {
  final MeetingService _meetingService = MeetingService();
  Timer? _timer;

  var isLoading = true.obs;
  var meetings = <Meeting>[].obs;

  List<Meeting> get todayOngoingMeetings {
    final now = DateTime.now();
    return meetings.where((m) {
      final meetingStart = m.startDateTime;
      final meetingEnd = m.endDateTime;
      
      final isToday = meetingStart.year == now.year &&
          meetingStart.month == now.month &&
          meetingStart.day == now.day;
      
      return isToday && now.isBefore(meetingEnd);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
    // Start a timer to refresh the UI every minute to update the meeting counter
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      meetings.refresh();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchMeetings() async {
    try {
      isLoading.value = true;
      final response = await _meetingService.getMeetings();
      if (response.success) {
        meetings.assignAll(response.data);
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch meetings",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

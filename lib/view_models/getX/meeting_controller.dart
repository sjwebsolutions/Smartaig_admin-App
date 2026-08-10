import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/meeting_model.dart';
import 'package:smart_aig_admins_app/services/meeting_service.dart';

class MeetingController extends GetxController {
  final MeetingService _meetingService = MeetingService();

  var isLoading = true.obs;
  var meetings = <Meeting>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
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

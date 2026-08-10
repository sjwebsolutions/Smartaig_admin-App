import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/deadlines_model.dart';
import 'package:smart_aig_admins_app/services/deadlines_services.dart';

class DeadlinesController extends GetxController {
  final DeadlinesService _deadlinesService = DeadlinesService();
  
  var isLoading = true.obs;
  var deadlinesList = <Deadline>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeadlines();
  }

  Future<void> fetchDeadlines() async {
    try {
      print("DEBUG: fetchDeadlines started");
      isLoading.value = true;
      final response = await _deadlinesService.getDeadlines();
      if (response.success == true && response.data != null) {
        deadlinesList.value = response.data!;
        print("DEBUG: Deadlines loaded successfully. Count: ${deadlinesList.length}");
      } else {
        print("DEBUG: Failed to load deadlines. Success: ${response.success}");
        Get.snackbar(
          "Error",
          "Failed to load deadlines",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      print("DEBUG: Error in fetchDeadlines: $e");
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
      print("DEBUG: fetchDeadlines finished");
    }
  }
}

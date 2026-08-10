import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';

class DashboardController extends GetxController {
  final AuthService _authService = AuthService();
  
  var isLoading = true.obs;
  var dashboardData = Rxn<DashboardData>();

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      print("DEBUG: fetchDashboardData started");
      isLoading.value = true;
      final response = await _authService.getDashboardData();
      if (response.success && response.data != null) {
        dashboardData.value = response.data;
        print("DEBUG: Dashboard Data loaded successfully");
      } else {
        print("DEBUG: Failed to load dashboard data. Success: ${response.success}");
        Get.snackbar(
          "Error",
          "Failed to load dashboard data",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      print("DEBUG: Error in fetchDashboardData: $e");
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
      print("DEBUG: fetchDashboardData finished");
    }
  }
}

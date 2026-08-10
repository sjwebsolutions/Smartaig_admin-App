import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/banner_model.dart';
import 'package:smart_aig_admins_app/models/banner_classes_model.dart';
import 'package:smart_aig_admins_app/services/banner_service.dart';

class BannerController extends GetxController {
  final BannerService _service = BannerService();

  var isLoading = true.obs;
  var banners = <BannerModel>[].obs;
  
  var isLoadingClasses = false.obs;
  var bannerClasses = <BannerClass>[].obs;
  
  var isPublishing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchBannerClasses();
  }

  Future<void> fetchBannerClasses() async {
    try {
      isLoadingClasses.value = true;
      final response = await _service.getBannerClasses();
      if (response.success && response.classes != null) {
        bannerClasses.assignAll(response.classes!);
      }
    } catch (e) {
      debugPrint("Error fetching banner classes: $e");
    } finally {
      isLoadingClasses.value = false;
    }
  }

  Future<void> publishBanner({
    required int id,
    required int audienceParents,
    required int audienceTeachers,
    required String targetType,
    List<int>? classIds,
    required int displayDays,
  }) async {
    try {
      isPublishing.value = true;
      final response = await _service.publishBanner(
        id: id,
        audienceParents: audienceParents,
        audienceTeachers: audienceTeachers,
        targetType: targetType,
        classIds: classIds,
        displayDays: displayDays,
      );

      print("🚩 [Banner Publish Controller Response]: $response");

      if (response['success'] == true) {
        Get.back(); // Close screen/dialog
        Get.snackbar(
          "Success",
          response['message'] ?? "Banner published successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchBanners(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to publish banner",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPublishing.value = false;
    }
  }

  Future<void> toggleBannerStatus(int id) async {
    try {
      final response = await _service.toggleBannerStatus(id);
      print("🚩 [Banner Toggle Response]: $response");
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Status updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchBanners(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to update status",
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
    }
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      final response = await _service.getBanners();
      if (response.success && response.publishedBanners != null) {
        banners.assignAll(response.publishedBanners!);
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch banners",
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

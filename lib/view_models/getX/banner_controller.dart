import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/banner_model.dart';
import 'package:smart_aig_admins_app/models/banner_classes_model.dart';
import 'package:smart_aig_admins_app/services/banner_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import '../../utils/custom_snackbar.dart';

class BannerController extends GetxController {
  final BannerService _service = BannerService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  var isLoading = true.obs;
  var banners = <BannerModel>[].obs;
  
  var isLoadingClasses = false.obs;
  var bannerClasses = <BannerClass>[].obs;
  
  var isPublishing = false.obs;

  // Banner counts for badges
  int get totalBanners => banners.length;
  int get activeBanners => banners.where((b) => b.status == 1).length;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    fetchBannerClasses();
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/ce49b0f5_1785475380_caac956a_1 (3).mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void playClickSound() {
    _playNotificationSound();
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

      if (response['success'] == true) {
        Get.back(); // Close screen/dialog
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Banner published successfully",
        );
        fetchBanners(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to publish banner",
        );
      }
    } catch (e) {
      debugPrint("Error in publishBanner: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to publish banner. Please check your connection and try again.",
      );
    } finally {
      isPublishing.value = false;
    }
  }

  Future<void> toggleBannerStatus(int id) async {
    try {
      final response = await _service.toggleBannerStatus(id);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Status updated successfully",
        );
        fetchBanners(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to update status",
        );
      }
    } catch (e) {
      debugPrint("Error in toggleBannerStatus: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to update status. Please try again.",
      );
    }
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      final response = await _service.getBanners();
      if (response.success && response.publishedBanners != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int previousCount = prefs.getInt('last_seen_banner_count') ?? -1;
        if (previousCount != -1 && response.publishedBanners!.length > previousCount) {
          _playNotificationSound();
          if (Get.isRegistered<NotificationService>()) {
            final firstTitle = response.publishedBanners!.first.bannerName.isNotEmpty 
                ? response.publishedBanners!.first.bannerName
                : "A new banner has been published.";
            NotificationService.to.showLocalNotification(
              "New Banner Published 🖼️",
              firstTitle,
              payload: "banner",
            );
          }
        }
        await prefs.setInt('last_seen_banner_count', response.publishedBanners!.length);
        banners.assignAll(response.publishedBanners!);
      } else {
        debugPrint("Failed to fetch banners");
      }
    } catch (e) {
      debugPrint("Error in fetchBanners: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

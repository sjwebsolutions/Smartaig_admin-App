import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/announcement_model.dart';
import 'package:smart_aig_admins_app/models/announcement_detail_model.dart';
import 'package:smart_aig_admins_app/models/announcement_type_model.dart';
import 'package:smart_aig_admins_app/models/targeting_data_model.dart';
import 'package:smart_aig_admins_app/services/announcement_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import '../../utils/custom_snackbar.dart';

class AnnouncementController extends GetxController {
  final AnnouncementService _service = AnnouncementService();

  var isLoading = true.obs;
  var announcements = <Announcement>[].obs;

  // Counter getter
  int get totalAnnouncements => announcements.length;

  var isLoadingDetails = false.obs;
  var announcementDetail = Rxn<AnnouncementDetail>();

  var isLoadingTypes = false.obs;
  var announcementTypes = <AnnouncementType>[].obs;

  var isLoadingTargetingData = false.obs;
  var classes = <ClassModel>[].obs;
  var streams = <StreamModel>[].obs;
  var sections = <SectionModel>[].obs;

  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
    fetchAnnouncementTypes();
    fetchTargetingData();
  }

  Future<void> createAnnouncement({
    required String title,
    required String description,
    required int typeId,
    File? image,
    required String fromDate,
    String? fromTime,
    required String toDate,
    String? toTime,
    required String targetType,
    List<Map<String, dynamic>>? targets,
  }) async {
    try {
      isSubmitting.value = true;
      final response = await _service.storeAnnouncement(
        title: title,
        description: description,
        typeId: typeId,
        image: image,
        fromDate: fromDate,
        fromTime: fromTime,
        toDate: toDate,
        toTime: toTime,
        targetType: targetType,
        targets: targets,
      );

      if (response.success) {
        Get.back();
        CustomSnackBar.showSuccess(
          "Success",
          response.message,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response.message,
        );
      }
    } catch (e) {
      debugPrint("Error creating announcement: $e");
      CustomSnackBar.showError(
        "Error",
        "Unable to create announcement. Please check your connection and try again.",
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateAnnouncement({
    required int id,
    required String title,
    required String description,
    required int typeId,
    File? image,
    required String fromDate,
    String? fromTime,
    required String toDate,
    String? toTime,
    required String targetType,
    List<Map<String, dynamic>>? targets,
  }) async {
    try {
      isSubmitting.value = true;
      final response = await _service.updateAnnouncement(
        id: id,
        title: title,
        description: description,
        typeId: typeId,
        image: image,
        fromDate: fromDate,
        fromTime: fromTime,
        toDate: toDate,
        toTime: toTime,
        targetType: targetType,
        targets: targets,
      );

      if (response.success) {
        Get.back();
        CustomSnackBar.showSuccess(
          "Success",
          response.message,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response.message,
        );
      }
    } catch (e) {
      debugPrint("Error updating announcement: $e");
      CustomSnackBar.showError(
        "Error",
        "Unable to update announcement. Please check your connection and try again.",
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> fetchTargetingData() async {
    try {
      isLoadingTargetingData.value = true;
      final response = await _service.getTargetingData();
      if (response.success && response.data != null) {
        classes.value = response.data!.classes;
        streams.value = response.data!.streams;
        sections.value = response.data!.sections;
      }
    } catch (e) {
      debugPrint("Error fetching targeting data: $e");
    } finally {
      isLoadingTargetingData.value = false;
    }
  }

  Future<void> fetchAnnouncementTypes() async {
    try {
      isLoadingTypes.value = true;
      final response = await _service.getAnnouncementTypes();
      if (response.success && response.data != null) {
        announcementTypes.value = response.data!;
      }
    } catch (e) {
      debugPrint("Error fetching types: $e");
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final response = await _service.getAnnouncements();
      if (response.success && response.data != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int previousCount = prefs.getInt('last_seen_announcement_count') ?? -1;
        if (previousCount != -1 && response.data!.length > previousCount) {
          if (Get.isRegistered<NotificationService>()) {
            final firstTitle = response.data!.first.title.isNotEmpty 
                ? response.data!.first.title 
                : "A new announcement has been posted.";
            NotificationService.to.showLocalNotification(
              "New Announcement 📢",
              firstTitle,
              payload: "announcement",
            );
          }
        }
        await prefs.setInt('last_seen_announcement_count', response.data!.length);
        announcements.value = response.data!;
      } else {
        debugPrint("Failed to fetch announcements: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error in fetchAnnouncements: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnnouncementDetails(int id) async {
    try {
      isLoadingDetails.value = true;
      final response = await _service.getAnnouncementDetails(id);
      if (response.success && response.data != null) {
        announcementDetail.value = response.data;
      } else {
        CustomSnackBar.showError(
          "Error",
          response.message ?? "Failed to fetch announcement details",
        );
      }
    } catch (e) {
      debugPrint("Error in fetchAnnouncementDetails: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to fetch announcement details. Please check your connection.",
      );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      final response = await _service.toggleAnnouncementStatus(id);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Status updated successfully",
        );
        fetchAnnouncements(); // Refresh list to see updated status
        fetchAnnouncementDetails(id); // Refresh current details
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to update status",
        );
      }
    } catch (e) {
      debugPrint("Error in toggleStatus: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to update status. Please try again.",
      );
    }
  }

  Future<void> lockAnnouncement(int id) async {
    try {
      final response = await _service.lockAnnouncement(id);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Announcement locked successfully",
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to lock announcement",
        );
      }
    } catch (e) {
      debugPrint("Error in lockAnnouncement: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to lock announcement. Please try again.",
      );
    }
  }

  Future<void> unlockAnnouncement(int id) async {
    try {
      final response = await _service.unlockAnnouncement(id);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Announcement unlocked successfully",
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to unlock announcement",
        );
      }
    } catch (e) {
      debugPrint("Error in unlockAnnouncement: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to unlock announcement. Please try again.",
      );
    }
  }

  Future<void> publishAnnouncement(int id, {required int sendToParents, required int sendToTeachers}) async {
    try {
      final response = await _service.publishAnnouncement(id, sendToParents: sendToParents, sendToTeachers: sendToTeachers);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Announcement published successfully",
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to publish announcement",
        );
      }
    } catch (e) {
      debugPrint("Error in publishAnnouncement: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to publish announcement. Please try again.",
      );
    }
  }

  Future<void> unpublishAnnouncement(int id) async {
    try {
      final response = await _service.unpublishAnnouncement(id);
      if (response['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "Announcement unpublished successfully",
        );
        fetchAnnouncements(); // Refresh list
      } else {
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Failed to unpublish announcement",
        );
      }
    } catch (e) {
      debugPrint("Error in unpublishAnnouncement: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to unpublish announcement. Please try again.",
      );
    }
  }
}

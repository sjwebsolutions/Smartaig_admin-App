import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/announcement_model.dart';
import 'package:smart_aig_admins_app/models/announcement_detail_model.dart';
import 'package:smart_aig_admins_app/models/announcement_type_model.dart';
import 'package:smart_aig_admins_app/models/targeting_data_model.dart';
import 'package:smart_aig_admins_app/models/create_announcement_response.dart';
import 'package:smart_aig_admins_app/services/announcement_service.dart';
import 'dart:io';

class AnnouncementController extends GetxController {
  final AnnouncementService _service = AnnouncementService();

  var isLoading = true.obs;
  var announcements = <Announcement>[].obs;

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
        Get.snackbar(
          "Success",
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response.message,
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
        Get.snackbar(
          "Success",
          response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response.message,
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
      } else {
        // Only show snackbar if it's not a background fetch or if error is critical
        // For types, we might want to be silent if it's just a lookup
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
        announcements.value = response.data!;
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to fetch announcements",
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

  Future<void> fetchAnnouncementDetails(int id) async {
    try {
      isLoadingDetails.value = true;
      final response = await _service.getAnnouncementDetails(id);
      if (response.success && response.data != null) {
        announcementDetail.value = response.data;
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to fetch announcement details",
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
      isLoadingDetails.value = false;
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      final response = await _service.toggleAnnouncementStatus(id);
      print("📢 [Announcement Toggle Response]: $response");
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Status updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list to see updated status
        fetchAnnouncementDetails(id); // Refresh current details
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

  Future<void> lockAnnouncement(int id) async {
    try {
      final response = await _service.lockAnnouncement(id);
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Announcement locked successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to lock announcement",
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

  Future<void> unlockAnnouncement(int id) async {
    try {
      final response = await _service.unlockAnnouncement(id);
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Announcement unlocked successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to unlock announcement",
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

  Future<void> publishAnnouncement(int id, {required int sendToParents, required int sendToTeachers}) async {
    try {
      final response = await _service.publishAnnouncement(id, sendToParents: sendToParents, sendToTeachers: sendToTeachers);
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Announcement published successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to publish announcement",
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

  Future<void> unpublishAnnouncement(int id) async {
    try {
      final response = await _service.unpublishAnnouncement(id);
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          response['message'] ?? "Announcement unpublished successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
        fetchAnnouncements(); // Refresh list
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to unpublish announcement",
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
}

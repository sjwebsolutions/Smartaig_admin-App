import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/event_pass_application_model.dart';
import 'package:smart_aig_admins_app/services/event_service.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_entry_controller.dart';

class EventPassApplicationsController extends GetxController {
  final EventService _eventService = EventService();

  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isUpdatingStatus = false.obs;

  var applicationsList = <EventPassApplicationModel>[].obs;
  var totalCount = 0.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'all'.obs;

  int? currentEventId;
  Timer? _debounceTimer;

  List<EventPassApplicationModel> get filteredApplicationsList {
    if (selectedStatus.value == 'all') {
      return applicationsList;
    }
    final String targetStatus = selectedStatus.value.toLowerCase();
    return applicationsList.where((item) {
      final String? status = item.approvalStatus?.toLowerCase();
      return status == targetStatus;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPassApplications();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchPassApplications();
    });
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    fetchPassApplications();
  }

  Future<void> fetchPassApplications({int? eventId}) async {
    if (eventId != null) {
      currentEventId = eventId;
    } else if (currentEventId == null) {
      if (Get.isRegistered<EventEntryController>()) {
        final entryCtrl = Get.find<EventEntryController>();
        if (entryCtrl.activeEventsList.isNotEmpty) {
          currentEventId = entryCtrl.activeEventsList.first.id;
        } else {
          await entryCtrl.fetchActiveEvents();
          if (entryCtrl.activeEventsList.isNotEmpty) {
            currentEventId = entryCtrl.activeEventsList.first.id;
          }
        }
      } else {
        final eventsRes = await _eventService.getActiveEvents();
        if (eventsRes.success && eventsRes.data.isNotEmpty) {
          currentEventId = eventsRes.data.first.id;
        }
      }
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final String? statusFilter = selectedStatus.value == 'all' ? null : selectedStatus.value;

      final response = await _eventService.getPassApplications(
        eventId: currentEventId,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        approvalStatus: statusFilter,
      );

      if (response.success) {
        applicationsList.assignAll(response.data);
        totalCount.value = response.totalCount > 0 ? response.totalCount : response.data.length;
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? "Failed to load pass applications.";
        applicationsList.clear();
        totalCount.value = 0;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = "An error occurred: $e";
      applicationsList.clear();
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePassStatus({
    required int passId,
    required String action, // "approve" or "reject"
    String? remarks,
  }) async {
    try {
      isUpdatingStatus.value = true;
      final response = await _eventService.updatePassStatus(
        passId: passId,
        action: action,
        remarks: remarks,
      );

      if (response.success) {
        Get.snackbar(
          "Status Updated",
          response.message ?? "Pass status updated to ${action == 'approve' ? 'Approved' : 'Rejected'}.",
          backgroundColor: action == 'approve' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        fetchPassApplications();
        return true;
      } else {
        Get.snackbar(
          "Update Failed",
          response.message ?? "Could not update pass status.",
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Update Error",
        "An error occurred: $e",
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}

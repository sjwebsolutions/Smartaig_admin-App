import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/student_leave_model.dart';
import 'package:smart_aig_admins_app/services/student_leave_service.dart';
import 'package:smart_aig_admins_app/utils/custom_snackbar.dart';

class StudentLeaveController extends GetxController {
  final StudentLeaveService _service = StudentLeaveService();

  var isLoading = true.obs;
  var isActionLoading = false.obs;
  var canApprove = false.obs;
  var leaveList = <StudentLeaveItem>[].obs;
  var selectedStatus = "Pending".obs; // "Pending", "Approved", "Rejected", "All"
  var selectedClassId = "".obs;
  var selectedSectionId = "".obs;
  var selectedStreamId = "".obs;
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentLeaves();
  }

  Future<void> fetchStudentLeaves({
    String? classId,
    String? sectionId,
    String? streamId,
    bool showLoading = true,
  }) async {
    if (showLoading || leaveList.isEmpty) {
      isLoading.value = true;
    }
    if (classId != null) selectedClassId.value = classId;
    if (sectionId != null) selectedSectionId.value = sectionId;
    if (streamId != null) selectedStreamId.value = streamId;

    try {
      final response = await _service.getStudentLeaves(
        classId: selectedClassId.value,
        sectionId: selectedSectionId.value,
        streamId: selectedStreamId.value,
      );

      canApprove.value = response.canApprove;
      leaveList.value = response.data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error in StudentLeaveController: $e");
      }
      if (showLoading || leaveList.isEmpty) {
        leaveList.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> approveLeave(int leaveId, {String? remarks}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.approveLeave(
        leaveId: leaveId,
        remarks: remarks,
      );

      if (res['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          res['message'] ?? "Leave application approved successfully.",
        );
        await fetchStudentLeaves(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError(
          "Error",
          res['message'] ?? "Failed to approve leave application.",
        );
        await fetchStudentLeaves(showLoading: false);
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "Something went wrong while approving leave application.",
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> rejectLeave(int leaveId, String rejectionReason) async {
    isActionLoading.value = true;
    try {
      final res = await _service.rejectLeave(
        leaveId: leaveId,
        rejectionReason: rejectionReason,
      );

      if (res['success'] == true) {
        CustomSnackBar.showSuccess(
          "Success",
          res['message'] ?? "Leave application rejected successfully.",
        );
        await fetchStudentLeaves(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError(
          "Error",
          res['message'] ?? "Failed to reject leave application.",
        );
        await fetchStudentLeaves(showLoading: false);
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "Something went wrong while rejecting leave application.",
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  List<StudentLeaveItem> get filteredLeaves {
    var list = leaveList.toList();

    // In 'All' tab, prioritize Pending items at the top
    if (selectedStatus.value == "All") {
      list.sort((a, b) {
        if (a.status.toLowerCase() == 'pending' && b.status.toLowerCase() != 'pending') {
          return -1;
        } else if (a.status.toLowerCase() != 'pending' && b.status.toLowerCase() == 'pending') {
          return 1;
        }
        return 0;
      });
    } else {
      list = list.where((item) {
        return item.status.toLowerCase() == selectedStatus.value.toLowerCase();
      }).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      list = list.where((item) {
        return item.studentName.toLowerCase().contains(query) ||
            item.admissionNumber.toLowerCase().contains(query) ||
            item.rollNo.toLowerCase().contains(query) ||
            item.className.toLowerCase().contains(query) ||
            item.sectionName.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  // Count getters
  int get totalCount => leaveList.length;
  int get pendingCount => leaveList.where((i) => i.status.toLowerCase() == 'pending').length;
  int get approvedCount => leaveList.where((i) => i.status.toLowerCase() == 'approved').length;
  int get rejectedCount => leaveList.where((i) => i.status.toLowerCase() == 'rejected').length;
}

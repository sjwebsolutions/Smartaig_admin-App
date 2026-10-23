import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/teacher_leave_model.dart';
import 'package:smart_aig_admins_app/services/teacher_leave_service.dart';
import 'package:smart_aig_admins_app/utils/custom_snackbar.dart';

class TeacherLeaveController extends GetxController {
  final TeacherLeaveService _service = TeacherLeaveService();

  var isLoading = true.obs;
  var isActionLoading = false.obs;
  var canApprove = false.obs;
  var leaveList = <TeacherLeaveItem>[].obs;
  var selectedStatus = "Pending".obs; // "Pending", "Approved", "Rejected", "All"
  var searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeacherLeaves();
  }

  Future<void> fetchTeacherLeaves({bool showLoading = true}) async {
    if (showLoading || leaveList.isEmpty) {
      isLoading.value = true;
    }

    try {
      final response = await _service.getTeacherLeaves();
      canApprove.value = response.canApprove;
      leaveList.value = response.data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error in TeacherLeaveController: $e");
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
          res['message'] ?? "Teacher leave application approved successfully.",
        );
        await fetchTeacherLeaves(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError(
          "Error",
          res['message'] ?? "Failed to approve teacher leave application.",
        );
        await fetchTeacherLeaves(showLoading: false);
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "Something went wrong while approving teacher leave application.",
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
          res['message'] ?? "Teacher leave application rejected successfully.",
        );
        await fetchTeacherLeaves(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError(
          "Error",
          res['message'] ?? "Failed to reject teacher leave application.",
        );
        await fetchTeacherLeaves(showLoading: false);
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError(
        "Error",
        "Something went wrong while rejecting teacher leave application.",
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  List<TeacherLeaveItem> get filteredLeaves {
    var list = leaveList.toList();

    // In 'All' tab, prioritize Pending items at top
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
        return item.teacherName.toLowerCase().contains(query) ||
            item.teacherCode.toLowerCase().contains(query) ||
            item.teacherPhone.toLowerCase().contains(query) ||
            item.teacherDesignation.toLowerCase().contains(query) ||
            item.leaveTypeLabel.toLowerCase().contains(query);
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

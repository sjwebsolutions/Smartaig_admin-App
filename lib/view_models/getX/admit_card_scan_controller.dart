import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/admit_card_scan_model.dart';
import 'package:smart_aig_admins_app/services/admit_card_scan_service.dart';
import 'package:smart_aig_admins_app/utils/custom_snackbar.dart';

class AdmitCardScanController extends GetxController {
  final AdmitCardScanService _service = AdmitCardScanService();

  var isLoading = false.obs;
  var isSuccess = false.obs;
  var hasSearched = false.obs;
  var message = ''.obs;
  var scanResult = Rxn<AdmitCardScanData>();

  // Computed getters for easy access in UI
  StudentInfo? get student => scanResult.value?.student;
  AdmitCardInfo? get admitCard => scanResult.value?.admitCard;
  List<DatesheetScheduleItem> get datesheetSchedule => scanResult.value?.datesheetSchedule ?? [];
  SeatingPlanInfo? get seatingPlan => scanResult.value?.seatingPlan;
  TodaySeatInfo? get todaySeat => scanResult.value?.seatingPlan?.todaySeat;
  List<SeatItemInfo> get allSeats => scanResult.value?.seatingPlan?.allSeats ?? [];
  FeeBalanceInfo? get feeBalance => scanResult.value?.feeBalance;

  /// Verify admit card with QR Code or Student ID / Roll No
  Future<bool> verifyAdmitCard({
    String? qrCode,
    dynamic studentId,
    bool showToast = true,
  }) async {
    try {
      isLoading.value = true;
      hasSearched.value = true;
      isSuccess.value = false;
      message.value = '';

      final response = await _service.verifyAdmitCard(
        qrCode: qrCode,
        studentId: studentId,
      );

      if (response.success && response.data != null) {
        scanResult.value = response.data;
        isSuccess.value = true;
        message.value = response.message ?? "Student admit card verified successfully.";

        if (showToast) {
          CustomSnackBar.showSuccess(
            "Verified",
            message.value,
          );
        }
        return true;
      } else {
        scanResult.value = null;
        isSuccess.value = false;
        message.value = response.message ?? "Admit card verification failed.";

        if (showToast) {
          CustomSnackBar.showError(
            "Verification Failed",
            message.value,
          );
        }
        return false;
      }
    } catch (e) {
      scanResult.value = null;
      isSuccess.value = false;
      message.value = e.toString();

      if (showToast) {
        CustomSnackBar.showError(
          "Error",
          message.value,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear the search result
  void clearResult() {
    scanResult.value = null;
    isSuccess.value = false;
    hasSearched.value = false;
    message.value = '';
  }

  /// Reset state completely
  void reset() {
    clearResult();
    isLoading.value = false;
  }
}

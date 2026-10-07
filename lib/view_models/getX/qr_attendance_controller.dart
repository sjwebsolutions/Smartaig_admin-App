import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/qr_scan_response_model.dart';
import 'package:smart_aig_admins_app/models/qr_settings_model.dart';
import 'package:smart_aig_admins_app/services/qr_attendance_service.dart';

class QrAttendanceController extends GetxController {
  final QrAttendanceService _service = QrAttendanceService();

  final RxBool isLoading = true.obs;
  final RxBool isSuccess = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final Rxn<QrSettingsData> settingsData = Rxn<QrSettingsData>();

  // Scan state
  final RxBool isScanning = false.obs;
  final Rxn<QrScanResponseModel> lastScanResult = Rxn<QrScanResponseModel>();

  // Convenience getters for UI
  bool get isQrAttendanceEnabled => settingsData.value?.qrAttendanceEnabled ?? false;
  bool get canScan => settingsData.value?.canScan ?? false;
  String? get permissionMessage => settingsData.value?.permissionMessage;
  bool get isAutoAbsentEnabled => settingsData.value?.autoAbsentEnabled ?? false;
  String? get autoAbsentCutoffTime => settingsData.value?.autoAbsentCutoffTime;
  ScannerInfo? get scannerInfo => settingsData.value?.scannerInfo;
  QrStats? get stats => settingsData.value?.stats;
  int get scannedByMeToday => settingsData.value?.stats?.scannedByMeToday ?? 0;
  int get totalPresentToday => settingsData.value?.stats?.totalPresentToday ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchQrSettings();
  }

  /// Fetch QR Attendance Settings
  Future<void> fetchQrSettings() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _service.getQrSettings();

      if (response.success && response.data != null) {
        settingsData.value = response.data;
        isSuccess.value = true;
      } else {
        settingsData.value = null;
        isSuccess.value = false;
        hasError.value = true;
        errorMessage.value = response.message ?? 'Failed to load QR attendance settings.';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("QrAttendanceController Error: $e");
      }
      settingsData.value = null;
      isSuccess.value = false;
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit Scanned QR Code
  Future<QrScanResponseModel> submitQrScan(String qrPayload) async {
    try {
      isScanning.value = true;
      final response = await _service.scanQrCode(qrPayload: qrPayload);
      lastScanResult.value = response;

      if (response.success) {
        // Silently update statistics in background
        _refreshStats();
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("submitQrScan Error: $e");
      }
      final errRes = QrScanResponseModel(
        success: false,
        message: e.toString(),
      );
      lastScanResult.value = errRes;
      return errRes;
    } finally {
      isScanning.value = false;
    }
  }

  /// Silently update stats without setting full isLoading = true
  Future<void> _refreshStats() async {
    try {
      final response = await _service.getQrSettings();
      if (response.success && response.data != null) {
        settingsData.value = response.data;
      }
    } catch (_) {}
  }

  /// Refresh QR settings
  Future<void> refreshSettings() async {
    await fetchQrSettings();
  }
}

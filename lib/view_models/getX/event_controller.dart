import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/event_pass_scan_model.dart';
import 'package:smart_aig_admins_app/models/event_today_scans_model.dart';
import 'package:smart_aig_admins_app/services/event_service.dart';

class EventController extends GetxController {
  final EventService _eventService = EventService();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var todayScansData = Rxn<EventTodayScansData>();
  var totalValidScansToday = 0.obs;
  var scansList = <EventScanItem>[].obs;

  // Pass Scanning state
  var isScanningPass = false.obs;
  var scanResultModel = Rxn<EventPassScanModel>();
  var scanPassErrorMessage = ''.obs;

  // Filter & Search states
  var myScansOnly = false.obs;
  var gateNameFilter = ''.obs;
  var selectedStatusFilter = 'all'.obs; // 'all', 'valid_entry', 'already_entered'
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayScans();
  }

  Future<void> fetchTodayScans({
    int? eventId,
    String? gateName,
    bool? myScans,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final bool queryMyScans = myScans ?? myScansOnly.value;
      final String queryGate = gateName ?? gateNameFilter.value;

      final response = await _eventService.getTodayScans(
        eventId: eventId,
        gateName: queryGate.isNotEmpty ? queryGate : null,
        myScansOnly: queryMyScans ? true : null,
        limit: limit,
      );

      if (response.success && response.data != null) {
        todayScansData.value = response.data;
        totalValidScansToday.value = response.data!.totalValidScansToday;
        scansList.assignAll(response.data!.scans);
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? "Failed to fetch event scans.";
        scansList.clear();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = "An error occurred while loading event scans: $e";
      scansList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<EventPassScanModel> scanPass({
    String? qrPayload,
    String? gateName,
    String? qrCode,
    String? passNumber,
    String? token,
  }) async {
    try {
      isScanningPass.value = true;
      scanPassErrorMessage.value = '';

      final response = await _eventService.scanPass(
        qrPayload: qrPayload,
        gateName: gateName,
        qrCode: qrCode,
        passNumber: passNumber,
        token: token,
      );

      scanResultModel.value = response;
      if (!response.success && response.message != null) {
        scanPassErrorMessage.value = response.message!;
      }

      // Refresh today scans list after scanning
      fetchTodayScans();

      return response;
    } catch (e) {
      scanPassErrorMessage.value = "Scan processing error: $e";
      final errModel = EventPassScanModel(
        success: false,
        message: scanPassErrorMessage.value,
      );
      scanResultModel.value = errModel;
      return errModel;
    } finally {
      isScanningPass.value = false;
    }
  }

  void clearScanResult() {
    scanResultModel.value = null;
    scanPassErrorMessage.value = '';
  }

  void toggleMyScansOnly(bool value) {
    myScansOnly.value = value;
    fetchTodayScans();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  List<EventScanItem> get filteredScans {
    final query = searchQuery.value;
    final status = selectedStatusFilter.value.toLowerCase();

    return scansList.where((item) {
      // Status Filter
      if (status != 'all') {
        if (status == 'valid_entry' && item.scanStatus.toLowerCase() != 'valid_entry') {
          return false;
        }
        if (status == 'already_entered' && item.scanStatus.toLowerCase() != 'already_entered') {
          return false;
        }
      }

      // Search Query Filter
      if (query.isNotEmpty) {
        final passNo = item.passNumber.toLowerCase();
        final event = item.eventTitle.toLowerCase();
        final student = item.studentName.toLowerCase();
        final admission = item.admissionNo.toLowerCase();
        final cls = item.classSection.toLowerCase();
        final gate = item.gateName.toLowerCase();
        final scanner = item.scannedBy.toLowerCase();

        return passNo.contains(query) ||
            event.contains(query) ||
            student.contains(query) ||
            admission.contains(query) ||
            cls.contains(query) ||
            gate.contains(query) ||
            scanner.contains(query);
      }

      return true;
    }).toList();
  }
}

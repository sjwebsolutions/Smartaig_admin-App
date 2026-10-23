import 'dart:async';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/transport_alerts_model.dart';
import 'package:smart_aig_admins_app/models/transport_halts_model.dart';
import 'package:smart_aig_admins_app/models/transport_live_overview_model.dart';
import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';
import 'package:smart_aig_admins_app/services/transport_service.dart';
import 'package:smart_aig_admins_app/utils/custom_snackbar.dart';

class TransportController extends GetxController {
  final TransportService _transportService = TransportService();

  Timer? _refreshTimer;

  // Live Overview State
  var isLiveOverviewLoading = false.obs;
  var liveOverviewData = Rxn<TransportLiveOverviewData>();
  var liveOverviewHasError = false.obs;
  var liveOverviewErrorMessage = ''.obs;

  // Location Requests State
  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var selectedStatus = 'all'.obs;
  var locationRequestsData = Rxn<TransportLocationData>();
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Transport Halts State
  var isHaltsLoading = false.obs;
  var selectedHaltStatus = 'all'.obs; // 'all', 'active', 'resolved'
  var haltsData = Rxn<TransportHaltsData>();
  var haltsHasError = false.obs;
  var haltsErrorMessage = ''.obs;
  var selectedBusId = Rxn<int>();
  var selectedTripId = Rxn<int>();
  var selectedHaltDate = Rxn<String>();

  // Transport Alerts State
  var isAlertsLoading = false.obs;
  var isAlertActionLoading = false.obs;
  var selectedAlertStatus = 'unresolved'.obs; // 'unresolved', 'resolved', 'all'
  var selectedAlertSeverity = 'all'.obs; // 'critical', 'high', 'medium', 'low', 'all'
  var selectedAlertType = 'all'.obs; // 'emergency_sos', 'breakdown', 'traffic_delay', 'accident', 'weather_delay', 'other', 'all'
  var alertsData = Rxn<TransportAlertsData>();
  var alertsHasError = false.obs;
  var alertsErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLiveOverview();
    fetchLocationRequests();
    fetchTransportHalts();
    fetchTransportAlerts();
    _startAutoRefreshTimer();
  }

  void _startAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchLiveOverview(showLoading: false);
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchLiveOverview({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLiveOverviewLoading.value = true;
      }
      liveOverviewHasError.value = false;
      liveOverviewErrorMessage.value = '';

      final response = await _transportService.getLiveOverview();

      if (response.success && response.data != null) {
        liveOverviewData.value = response.data;
      } else {
        liveOverviewHasError.value = true;
        liveOverviewErrorMessage.value = response.message ?? "Failed to fetch live overview";
      }
    } catch (e) {
      liveOverviewHasError.value = true;
      liveOverviewErrorMessage.value = e.toString();
    } finally {
      isLiveOverviewLoading.value = false;
    }
  }

  Future<void> fetchLocationRequests({String? status, bool showLoading = true}) async {
    if (status != null) {
      selectedStatus.value = status;
    }

    try {
      if (showLoading) {
        isLoading.value = true;
      }
      hasError.value = false;
      errorMessage.value = '';

      final response = await _transportService.getLocationRequests(
        status: selectedStatus.value,
      );

      if (response.success && response.data != null) {
        locationRequestsData.value = response.data;
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? "Failed to fetch transport requests";
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransportHalts({
    String? status,
    int? busId,
    int? tripId,
    String? date,
    bool showLoading = true,
  }) async {
    if (status != null) {
      selectedHaltStatus.value = status;
    }
    if (busId != null) {
      selectedBusId.value = busId;
    }
    if (tripId != null) {
      selectedTripId.value = tripId;
    }
    if (date != null) {
      selectedHaltDate.value = date;
    }

    try {
      if (showLoading) {
        isHaltsLoading.value = true;
      }
      haltsHasError.value = false;
      haltsErrorMessage.value = '';

      final response = await _transportService.getTransportHalts(
        status: selectedHaltStatus.value,
        busId: selectedBusId.value,
        tripId: selectedTripId.value,
        date: selectedHaltDate.value,
      );

      if (response.success && response.data != null) {
        haltsData.value = response.data;
      } else {
        haltsHasError.value = true;
        haltsErrorMessage.value = response.message ?? "Failed to fetch transport halts";
      }
    } catch (e) {
      haltsHasError.value = true;
      haltsErrorMessage.value = e.toString();
    } finally {
      isHaltsLoading.value = false;
    }
  }

  Future<void> fetchTransportAlerts({
    String? status,
    String? severity,
    String? alertType,
    int? busId,
    bool showLoading = true,
  }) async {
    if (status != null) {
      selectedAlertStatus.value = status;
    }
    if (severity != null) {
      selectedAlertSeverity.value = severity;
    }
    if (alertType != null) {
      selectedAlertType.value = alertType;
    }

    try {
      if (showLoading) {
        isAlertsLoading.value = true;
      }
      alertsHasError.value = false;
      alertsErrorMessage.value = '';

      final response = await _transportService.getTransportAlerts(
        status: selectedAlertStatus.value,
        severity: selectedAlertSeverity.value,
        alertType: selectedAlertType.value,
        busId: busId ?? selectedBusId.value,
      );

      if (response.success && response.data != null) {
        alertsData.value = response.data;
      } else {
        alertsHasError.value = true;
        alertsErrorMessage.value = response.message ?? "Failed to fetch transport alerts";
      }
    } catch (e) {
      alertsHasError.value = true;
      alertsErrorMessage.value = e.toString();
    } finally {
      isAlertsLoading.value = false;
    }
  }

  Future<bool> resolveAlert(int id, {String? resolutionNotes}) async {
    try {
      isAlertActionLoading.value = true;
      final result = await _transportService.resolveTransportAlert(id, resolutionNotes: resolutionNotes);
      if (result['success'] == true) {
        CustomSnackBar.showSuccess("Success", result['message'] ?? "Alert resolved successfully.");
        await fetchTransportAlerts(showLoading: false);
        await fetchLiveOverview(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError("Error", result['message'] ?? "Failed to resolve alert.");
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError("Error", e.toString());
      return false;
    } finally {
      isAlertActionLoading.value = false;
    }
  }

  Future<bool> approveRequest(int id, {String? remarks}) async {
    try {
      isActionLoading.value = true;
      final result = await _transportService.approveLocationRequest(id, remarks: remarks);
      if (result['success'] == true) {
        CustomSnackBar.showSuccess("Success", result['message'] ?? "Location request approved successfully.");
        await fetchLocationRequests(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError("Error", result['message'] ?? "Failed to approve request.");
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError("Error", e.toString());
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> rejectRequest(int id, String reason) async {
    try {
      isActionLoading.value = true;
      final result = await _transportService.rejectLocationRequest(id, rejectionReason: reason);
      if (result['success'] == true) {
        CustomSnackBar.showSuccess("Success", result['message'] ?? "Location request rejected successfully.");
        await fetchLocationRequests(showLoading: false);
        return true;
      } else {
        CustomSnackBar.showError("Error", result['message'] ?? "Failed to reject request.");
        return false;
      }
    } catch (e) {
      CustomSnackBar.showError("Error", e.toString());
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // Live Overview Getters
  TransportLiveSummary? get liveSummary => liveOverviewData.value?.summary;
  List<TransportFleetItem> get fleet => liveOverviewData.value?.fleet ?? [];

  // Location Requests Summary Getters
  int get totalCount => locationRequestsData.value?.summary?.total ?? 0;
  int get pendingCount => locationRequestsData.value?.summary?.pending ?? 0;
  int get approvedCount => locationRequestsData.value?.summary?.approved ?? 0;
  int get rejectedCount => locationRequestsData.value?.summary?.rejected ?? 0;

  List<TransportLocationRequest> get requests => locationRequestsData.value?.requests ?? [];

  // Transport Halts Getters
  List<TransportHalt> get halts => haltsData.value?.halts ?? [];
  int get totalHaltsCount => haltsData.value?.pagination?.total ?? halts.length;

  // Transport Alerts Getters
  List<TransportAlert> get alerts => alertsData.value?.alerts ?? [];
  int get totalAlertsCount => alertsData.value?.pagination?.total ?? alerts.length;
}

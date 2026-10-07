import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/callback_detail_model.dart';
import 'package:smart_aig_admins_app/models/callback_request_model.dart';
import 'package:smart_aig_admins_app/services/callback_service.dart';

class CallbackController extends GetxController {
  final CallbackService _service = CallbackService();

  var isLoading = true.obs;
  var summary = Rxn<CallbackSummary>();
  var callbackList = <CallbackData>[].obs;

  var isDetailLoading = false.obs;
  var selectedDetail = Rxn<CallbackDetailData>();

  var selectedStatus = 'pending'.obs;
  var selectedDate = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCallbackRequests();
  }

  Future<void> fetchCallbackRequests({
    String? status,
    String? date,
    String? from,
    String? to,
    int page = 1,
  }) async {
    try {
      isLoading.value = true;
      if (status != null) selectedStatus.value = status;
      if (date != null) selectedDate.value = date;
      if (from != null) fromDate.value = from;
      if (to != null) toDate.value = to;
      currentPage.value = page;

      final response = await _service.getCallbackRequests(
        status: selectedStatus.value,
        date: selectedDate.value,
        fromDate: fromDate.value,
        toDate: toDate.value,
        page: currentPage.value,
      );

      if (response.success) {
        summary.value = response.summary;
        callbackList.assignAll(response.data);
      } else {
        callbackList.clear();
      }

      if (summary.value == null) {
        await fetchCallbackSummary();
      }
    } catch (e) {
      print("Error fetching callback requests: $e");
      callbackList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCallbackSummary() async {
    try {
      final res = await _service.getCallbackSummary();
      if (res.success && res.data != null) {
        summary.value = res.data;
      }
    } catch (e) {
      print("Error fetching callback summary: $e");
    }
  }

  Future<CallbackDetailData?> fetchCallbackDetail(int id) async {
    try {
      isDetailLoading.value = true;
      selectedDetail.value = null;
      final response = await _service.getCallbackDetail(id);
      if (response.success && response.data != null) {
        selectedDetail.value = response.data;
        return response.data;
      }
    } catch (e) {
      print("Error fetching callback detail for $id: $e");
    } finally {
      isDetailLoading.value = false;
    }
    return null;
  }

  void setFilterStatus(String status) {
    selectedStatus.value = status;
    fetchCallbackRequests(status: status);
  }

  void setDateFilter(String? date) {
    selectedDate.value = date ?? '';
    fetchCallbackRequests();
  }

  void setDateRangeFilter(String? from, String? to) {
    fromDate.value = from ?? '';
    toDate.value = to ?? '';
    fetchCallbackRequests();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<CallbackData> get filteredCallbackList {
    if (searchQuery.value.trim().isEmpty) {
      return callbackList;
    }
    final q = searchQuery.value.toLowerCase().trim();
    return callbackList.where((item) {
      final parentName = item.parent?.name.toLowerCase() ?? '';
      final parentMobile = item.parent?.mobile.toLowerCase() ?? '';
      final studentName = item.student?.name.toLowerCase() ?? '';
      final reason = item.reason.toLowerCase();
      return parentName.contains(q) ||
          parentMobile.contains(q) ||
          studentName.contains(q) ||
          reason.contains(q);
    }).toList();
  }
}

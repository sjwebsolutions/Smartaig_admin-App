import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_upload_status_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksUploadStatusController extends GetxController {
  final int marksEntryId;
  final int classId;
  final int? sectionId;
  final int? streamId;

  final MarksEntryService _marksEntryService = MarksEntryService();

  MarksUploadStatusController({
    required this.marksEntryId,
    required this.classId,
    this.sectionId,
    this.streamId,
  });

  var isLoading = true.obs;
  var statusList = <MarksUploadStatusItem>[].obs;
  var filteredList = <MarksUploadStatusItem>[].obs;
  var success = false.obs;

  // Filter & Search states
  var selectedStatusFilter = 'All'.obs; // 'All', 'Completed', 'Pending'
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUploadStatus();
  }

  Future<void> fetchUploadStatus() async {
    try {
      isLoading.value = true;
      final response = await _marksEntryService.getUploadStatus(
        marksEntryId: marksEntryId,
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
      );
      success.value = response.success;
      if (response.success) {
        statusList.assignAll(response.data);
        applyFilters();
      } else {
        statusList.clear();
        filteredList.clear();
      }
    } catch (e) {
      print("MarksUploadStatusController Error: $e");
      success.value = false;
      statusList.clear();
      filteredList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<MarksUploadStatusItem> results = List.from(statusList);

    // Status filter
    if (selectedStatusFilter.value != 'All') {
      results = results.where((item) {
        return item.status.toLowerCase() ==
            selectedStatusFilter.value.toLowerCase();
      }).toList();
    }

    // Search query (subject or teacher)
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      results = results.where((item) {
        return item.subject.toLowerCase().contains(query) ||
            item.teacher.toLowerCase().contains(query) ||
            item.section.toLowerCase().contains(query);
      }).toList();
    }

    filteredList.assignAll(results);
  }

  void setStatusFilter(String filter) {
    selectedStatusFilter.value = filter;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // Summary Metrics
  int get totalSubjects => statusList.length;

  int get totalUploadedCount =>
      statusList.fold(0, (sum, item) => sum + item.uploaded);

  int get totalPendingCount =>
      statusList.fold(0, (sum, item) => sum + item.pending);

  int get totalStudentsCount =>
      statusList.fold(0, (sum, item) => sum + item.total);

  int get completedSubjectsCount => statusList
      .where((item) => item.status.toLowerCase() == 'completed')
      .length;

  int get pendingSubjectsCount => statusList
      .where((item) => item.status.toLowerCase() == 'pending')
      .length;

  double get completionRatio {
    if (totalStudentsCount == 0) return 0.0;
    return (totalUploadedCount / totalStudentsCount).clamp(0.0, 1.0);
  }
}

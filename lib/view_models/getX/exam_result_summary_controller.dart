import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/exam_result_summary_model.dart';
import 'package:smart_aig_admins_app/services/exam_result_service.dart';

class ExamResultSummaryController extends GetxController {
  final int marksEntryId;
  final int classId;
  final int? sectionId;
  final int? streamId;

  final ExamResultService _examResultService = ExamResultService();

  ExamResultSummaryController({
    required this.marksEntryId,
    required this.classId,
    this.sectionId,
    this.streamId,
  });

  var isLoading = true.obs;
  var summaryList = <ExamResultSummaryItem>[].obs;
  var filteredList = <ExamResultSummaryItem>[].obs;
  var success = false.obs;

  // Filter & Search states
  var selectedStatusFilter = 'All'.obs; // 'All', 'Pass', 'Fail'
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      isLoading.value = true;
      final response = await _examResultService.getSummary(
        marksEntryId: marksEntryId,
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
      );
      success.value = response.success;
      if (response.success) {
        summaryList.assignAll(response.data);
        applyFilters();
      } else {
        summaryList.clear();
        filteredList.clear();
      }
    } catch (e) {
      print("ExamResultSummaryController Error: $e");
      success.value = false;
      summaryList.clear();
      filteredList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<ExamResultSummaryItem> results = List.from(summaryList);

    // Status filter
    if (selectedStatusFilter.value != 'All') {
      results = results.where((item) {
        return item.resultStatus.trim().toLowerCase() ==
            selectedStatusFilter.value.trim().toLowerCase();
      }).toList();
    }

    // Search query (Student Name, Admission No, Grade)
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      results = results.where((item) {
        return item.studentName.toLowerCase().contains(query) ||
            item.admissionNo.toLowerCase().contains(query) ||
            item.grade.toLowerCase().contains(query);
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
  int get totalStudents => summaryList.length;

  int get passedCount => summaryList
      .where((item) => item.resultStatus.trim().toLowerCase() == 'pass')
      .length;

  int get failedCount => summaryList
      .where((item) => item.resultStatus.trim().toLowerCase() == 'fail')
      .length;

  double get passRatio {
    if (totalStudents == 0) return 0.0;
    return (passedCount / totalStudents).clamp(0.0, 1.0);
  }

  double get averagePercentage {
    if (totalStudents == 0) return 0.0;
    double sum = 0.0;
    int count = 0;
    for (var item in summaryList) {
      final cleaned = item.percentage.replaceAll('%', '').trim();
      final parsed = double.tryParse(cleaned);
      if (parsed != null) {
        sum += parsed;
        count++;
      }
    }
    return count > 0 ? (sum / count) : 0.0;
  }
}

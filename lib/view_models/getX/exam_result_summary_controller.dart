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
  var success = false.obs;

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
      }
    } catch (e) {
      print("ExamResultSummaryController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/exam_result_model.dart';
import 'package:smart_aig_admins_app/services/exam_result_service.dart';

class ExamResultController extends GetxController {
  final ExamResultService _examResultService = ExamResultService();

  var isLoading = true.obs;
  var examList = <ExamResultData>[].obs;
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final response = await _examResultService.getExams();
      success.value = response.success;
      if (response.success) {
        examList.assignAll(response.data);
        print("Exam Results: ${response.data.length} exams found");
      }
    } catch (e) {
      print("ExamResultController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

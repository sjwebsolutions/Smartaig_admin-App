import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/exam_result_classes_model.dart';
import 'package:smart_aig_admins_app/services/exam_result_service.dart';

class ExamResultClassesController extends GetxController {
  final int examId;
  final ExamResultService _examResultService = ExamResultService();

  ExamResultClassesController({required this.examId});

  var isLoading = true.obs;
  var classList = <ClassData>[].obs;
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      final response = await _examResultService.getClasses(examId);
      success.value = response.success;
      if (response.success) {
        classList.assignAll(response.data);
        print("Exam Result Classes: ${response.data.length} classes found");
      }
    } catch (e) {
      print("ExamResultClassesController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/exam_result_class_details_model.dart';
import 'package:smart_aig_admins_app/services/exam_result_service.dart';

class ExamResultClassDetailsController extends GetxController {
  final int examId;
  final int classId;
  final ExamResultService _examResultService = ExamResultService();

  ExamResultClassDetailsController({required this.examId, required this.classId});

  var isLoading = true.obs;
  var classDetails = Rxn<ClassDetailsData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClassDetails();
  }

  Future<void> fetchClassDetails() async {
    try {
      isLoading.value = true;
      final response = await _examResultService.getClassDetails(examId, classId);
      success.value = response.success;
      if (response.success && response.data != null) {
        classDetails.value = response.data;
      }
    } catch (e) {
      print("ExamResultClassDetailsController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

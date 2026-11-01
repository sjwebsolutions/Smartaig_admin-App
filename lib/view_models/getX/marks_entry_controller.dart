import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_entry_model.dart';
import 'package:smart_aig_admins_app/models/marks_entry_classes_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksEntryController extends GetxController {
  final MarksEntryService _marksEntryService = MarksEntryService();

  var isLoading = true.obs;
  var examList = <ExamData>[].obs;
  var success = false.obs;

  var examClassesMap = <int, List<ClassData>>{}.obs;
  var loadingClassesMap = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final response = await _marksEntryService.getExams();
      success.value = response.success;
      if (response.success) {
        examList.assignAll(response.data);
        print("Marks Entry: ${response.data.length} exams found");

        await Future.wait(
          response.data.map((exam) => fetchClassesForExam(exam.id)),
        );
      }
    } catch (e) {
      print("MarksEntryController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchClassesForExam(int examId) async {
    try {
      loadingClassesMap[examId] = true;
      final response = await _marksEntryService.getClasses(examId);
      if (response.success) {
        examClassesMap[examId] = response.data;
      } else {
        examClassesMap[examId] = [];
      }
    } catch (e) {
      print("Error fetching classes for exam $examId: $e");
      examClassesMap[examId] = [];
    } finally {
      loadingClassesMap[examId] = false;
    }
  }
}

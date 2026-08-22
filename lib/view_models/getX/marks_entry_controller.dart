import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_entry_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksEntryController extends GetxController {
  final MarksEntryService _marksEntryService = MarksEntryService();

  var isLoading = true.obs;
  var examList = <ExamData>[].obs;
  var success = false.obs;

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
      }
    } catch (e) {
      print("MarksEntryController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

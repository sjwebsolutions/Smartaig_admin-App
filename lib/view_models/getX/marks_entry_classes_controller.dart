import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_entry_classes_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksEntryClassesController extends GetxController {
  final int examId;
  final MarksEntryService _marksEntryService = MarksEntryService();

  MarksEntryClassesController({required this.examId});

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
      final response = await _marksEntryService.getClasses(examId);
      success.value = response.success;
      if (response.success) {
        classList.assignAll(response.data);
        print("Marks Entry Classes: ${response.data.length} classes found");
      }
    } catch (e) {
      print("MarksEntryClassesController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

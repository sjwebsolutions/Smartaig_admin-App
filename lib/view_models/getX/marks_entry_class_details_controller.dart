import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_entry_class_details_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksEntryClassDetailsController extends GetxController {
  final int examId;
  final int classId;
  final MarksEntryService _marksEntryService = MarksEntryService();

  MarksEntryClassDetailsController({required this.examId, required this.classId});

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
      final response = await _marksEntryService.getClassDetails(examId, classId);
      success.value = response.success;
      if (response.success && response.data != null) {
        classDetails.value = response.data;
        print("Marks Entry Details: ${response.data!.sections.length} sections found");
      }
    } catch (e) {
      print("MarksEntryClassDetailsController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

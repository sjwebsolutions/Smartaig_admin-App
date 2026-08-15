import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/student_count_model.dart';
import 'package:smart_aig_admins_app/services/student_count_service.dart';

class StudentCountController extends GetxController {
  final StudentCountService _studentCountService = StudentCountService();

  var isLoading = true.obs;
  var countData = Rxn<StudentCountData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentCount();
  }

  Future<void> fetchStudentCount() async {
    try {
      isLoading.value = true;
      final response = await _studentCountService.getStudentCount();
      success.value = response.success;
      if (response.success && response.data != null) {
        countData.value = response.data;
        print("Student Count: ${response.data!.overallStats.overallTotal} students found");
      }
    } catch (e) {
      print("StudentCountController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

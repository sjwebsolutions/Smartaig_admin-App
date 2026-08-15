import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/homework_status_model.dart';
import 'package:smart_aig_admins_app/services/homework_service.dart';

class HomeworkController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();

  var isLoading = true.obs;
  var homeworkData = Rxn<HomeworkData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeworkStatus();
  }

  Future<void> fetchHomeworkStatus() async {
    try {
      isLoading.value = true;
      final response = await _homeworkService.getHomeworkUploadStatus();
      success.value = response.success;
      if (response.success && response.data != null) {
        homeworkData.value = response.data;
        print("Homework Status: ${response.data!.statusData.length} classes found");
      }
    } catch (e) {
      print("HomeworkController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

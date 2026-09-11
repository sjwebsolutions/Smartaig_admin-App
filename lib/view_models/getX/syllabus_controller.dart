import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/syllabus_model.dart';
import 'package:smart_aig_admins_app/services/syllabus_service.dart';

class SyllabusController extends GetxController {
  final SyllabusService _service = SyllabusService();

  var isLoading = true.obs;
  var syllabusList = <Syllabus>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSyllabus();
  }

  Future<void> fetchSyllabus({
    int? termId,
    int? classId,
    int? subjectId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _service.getSyllabus(
        termId: termId,
        classId: classId,
        subjectId: subjectId,
      );
      if (response.success && response.data != null) {
        syllabusList.value = response.data!;
      } else {
        syllabusList.clear();
      }
    } catch (e) {
      debugPrint("Error in fetchSyllabus: $e");
      Get.snackbar(
        "Error",
        "An error occurred while fetching syllabus",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

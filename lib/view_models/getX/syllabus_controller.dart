import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/syllabus_model.dart';
import 'package:smart_aig_admins_app/services/syllabus_service.dart';
import '../../utils/custom_snackbar.dart';

class SyllabusController extends GetxController {
  final SyllabusService _service = SyllabusService();

  var isLoading = true.obs;
  var syllabusList = <Syllabus>[].obs;
  var termsList = <SyllabusTerm>[].obs;
  var selectedTermId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    fetchSyllabusTerms();
    fetchSyllabus();
  }

  Future<void> fetchSyllabusTerms() async {
    try {
      final response = await _service.getSyllabusTerms();
      if (response.success && response.data != null) {
        termsList.value = response.data!;
      }
    } catch (e) {
      debugPrint("Error in fetchSyllabusTerms: $e");
    }
  }

  Future<void> fetchSyllabus({
    int? termId,
    int? classId,
    int? subjectId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _service.getSyllabus(
        termId: termId ?? selectedTermId.value,
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
    } finally {
      isLoading.value = false;
    }
  }

  void selectTerm(int? termId) {
    selectedTermId.value = termId;
    fetchSyllabus();
  }
}

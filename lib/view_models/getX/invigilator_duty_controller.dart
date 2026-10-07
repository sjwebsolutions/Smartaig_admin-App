import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_model.dart';
import 'package:smart_aig_admins_app/services/invigilator_duty_service.dart';
import '../../utils/custom_snackbar.dart';

class InvigilatorDutyController extends GetxController {
  final InvigilatorDutyService _dutyService = InvigilatorDutyService();

  var isLoading = true.obs;
  var duties = <InvigilatorDuty>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDuties();
  }

  Future<void> fetchDuties() async {
    try {
      isLoading.value = true;
      final response = await _dutyService.getInvigilatorDuties();
      if (response.success) {
        duties.assignAll(response.data);
      } else {
        debugPrint("Failed to fetch invigilator duties");
      }
    } catch (e) {
      debugPrint("Error in fetchDuties: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/seating_plan_model.dart';
import 'package:smart_aig_admins_app/services/seating_plan_service.dart';

class SeatingPlanController extends GetxController {
  final SeatingPlanService _service = SeatingPlanService();

  var isLoading = true.obs;
  var plans = <SeatingPlan>[].obs;
  var searchPlanQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  /// Fetch all seating plans from API
  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      final response = await _service.getSeatingPlans();
      if (response.success) {
        plans.assignAll(response.data);
      } else {
        debugPrint("Failed to fetch seating plans: ${response.message}");
      }
    } catch (e) {
      debugPrint("Error in fetchPlans: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered Seating Plans for search
  List<SeatingPlan> get filteredPlans {
    if (searchPlanQuery.value.trim().isEmpty) {
      return plans;
    }
    final query = searchPlanQuery.value.toLowerCase();
    return plans.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.session.toLowerCase().contains(query) ||
          p.datesheet.name.toLowerCase().contains(query);
    }).toList();
  }
}

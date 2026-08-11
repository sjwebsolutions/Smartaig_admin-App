import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/finance_statistics_model.dart';
import 'package:smart_aig_admins_app/services/finance_service.dart';

class FinanceController extends GetxController {
  final FinanceService _financeService = FinanceService();

  var isLoading = true.obs;
  var financeData = Rxn<FinanceData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFinanceStatistics();
  }

  Future<void> fetchFinanceStatistics() async {
    try {
      isLoading.value = true;
      final response = await _financeService.getFinanceStatistics();
      success.value = response.success;
      if (response.success && response.data != null) {
        financeData.value = response.data;
      }
    } catch (e) {
      print("FinanceController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

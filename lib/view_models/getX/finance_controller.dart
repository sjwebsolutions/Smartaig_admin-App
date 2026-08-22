import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/finance_statistics_model.dart';
import 'package:smart_aig_admins_app/services/finance_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinanceController extends GetxController {
  final FinanceService _financeService = FinanceService();

  var isLoading = true.obs;
  var financeData = Rxn<FinanceData>();
  var success = false.obs;
  
  // Badge logic
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFinanceStatistics();
  }

  Future<void> markAsRead() async {
    unreadCount.value = 0;
    if (financeData.value != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        String currentKey = _generateDataKey(financeData.value!);
        await prefs.setString('last_seen_finance_data', currentKey);
      } catch (e) {
        print("Error saving finance read status: $e");
      }
    }
  }

  String _generateDataKey(FinanceData data) {
    return "${data.fees.totalReceived}_${data.fees.todayCollection}_${data.fees.balanceTillToday}_"
        "${data.books.totalReceived}_${data.books.todayCollection}_${data.books.balanceTillToday}_"
        "${data.uniforms.totalReceived}_${data.uniforms.todayCollection}_${data.uniforms.balanceTillToday}_"
        "${data.stationary.totalReceived}_${data.stationary.todayCollection}_${data.stationary.balanceTillToday}";
  }

  Future<void> fetchFinanceStatistics() async {
    try {
      isLoading.value = true;
      final response = await _financeService.getFinanceStatistics();
      success.value = response.success;
      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();
        String currentKey = _generateDataKey(response.data!);
        String lastSeenKey = prefs.getString('last_seen_finance_data') ?? '';

        if (currentKey.isNotEmpty && currentKey != lastSeenKey) {
          unreadCount.value = 1;
          
          if (lastSeenKey.isNotEmpty) {
            NotificationService.to.showLocalNotification(
              "Assets Report",
              "Finance and assets report has been updated.",
            );
          }
        }
        financeData.value = response.data;
      }
    } catch (e) {
      print("FinanceController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

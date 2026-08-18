import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/support_settings_model.dart';
import 'package:smart_aig_admins_app/services/support_service.dart';

class SupportController extends GetxController {
  final SupportService _service = SupportService();

  var isLoading = true.obs;
  var supportData = Rxn<SupportData>();

  @override
  void onInit() {
    super.onInit();
    fetchSupportSettings();
  }

  Future<void> fetchSupportSettings() async {
    try {
      isLoading.value = true;
      final response = await _service.getSupportSettings();
      if (response.success && response.data != null) {
        supportData.value = response.data;
      }
    } catch (e) {
      print("Error fetching support settings: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

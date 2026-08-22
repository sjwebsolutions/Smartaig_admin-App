import 'package:get/get.dart';
import '../../models/policy_model.dart';
import '../../services/policy_service.dart';

class PolicyController extends GetxController {
  final PolicyService _policyService = PolicyService();

  final RxBool isLoading = false.obs;
  final Rx<PolicyModel?> policyModel = Rx<PolicyModel?>(null);

  @override
  void onInit() {
    super.onInit();
    getPolicy();
  }

  Future<void> getPolicy() async {
    try {
      isLoading.value = true;

      final result = await _policyService.getPolicy();

      if (result != null) {
        policyModel.value = result;
      }
    } catch (e) {
      print("Policy Controller Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String get termsOfUse =>
      policyModel.value?.data.termsOfUse ?? '';

  String get privacyPolicy =>
      policyModel.value?.data.privacyPolicy ?? '';
}
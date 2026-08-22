import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/admission_detail_model.dart';
import 'package:smart_aig_admins_app/services/admission_service.dart';

class AdmissionDetailController extends GetxController {
  final int id;
  final AdmissionService _admissionService = AdmissionService();

  AdmissionDetailController({required this.id});

  var isLoading = true.obs;
  var enquiryDetail = Rxn<EnquiryDetailData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEnquiryDetails();
  }

  Future<void> fetchEnquiryDetails() async {
    try {
      isLoading.value = true;
      final response = await _admissionService.getEnquiryDetails(id);
      success.value = response.success;
      if (response.success && response.data != null) {
        enquiryDetail.value = response.data;
      }
    } catch (e) {
      print("AdmissionDetailController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

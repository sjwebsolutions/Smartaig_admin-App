import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/admission_enquiry_model.dart';
import 'package:smart_aig_admins_app/services/admission_service.dart';

class AdmissionController extends GetxController {
  final AdmissionService _admissionService = AdmissionService();

  var isLoading = true.obs;
  var enquiries = <EnquiryData>[].obs;
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEnquiries();
  }

  Future<void> fetchEnquiries() async {
    try {
      isLoading.value = true;
      final response = await _admissionService.getEnquiries();
      success.value = response.success;
      if (response.success) {
        enquiries.assignAll(response.data);
        print("Admission Enquiries: ${response.data.length} found");
      }
    } catch (e) {
      print("AdmissionController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_aig_admins_app/models/seating_plan_detail_model.dart';
import 'package:smart_aig_admins_app/services/seating_plan_service.dart';
import 'package:smart_aig_admins_app/view/screens/invoice_view_screen.dart';
import '../../utils/custom_snackbar.dart';

class SeatingPlanDetailController extends GetxController {
  final int planId;
  final SeatingPlanService _service = SeatingPlanService();

  SeatingPlanDetailController({required this.planId});

  var isLoading = true.obs;
  var isPdfLoading = false.obs;
  var detailData = Rxn<SeatingPlanDetailData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlanDetails();
  }

  Future<void> fetchPlanDetails() async {
    try {
      isLoading.value = true;
      final response = await _service.getSeatingPlanDetail(planId);
      success.value = response.success;
      if (response.success && response.data != null) {
        detailData.value = response.data;
      } else {
        debugPrint("Failed to load seating plan details");
      }
    } catch (e) {
      debugPrint("SeatingPlanDetailController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewMasterPdf(String pdfUrl, String dateLabel) async {
    try {
      isPdfLoading.value = true;
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        barrierDismissible: false,
      );

      final response = await _service.getMasterPdf(pdfUrl);

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final sanitizedDate = dateLabel.replaceAll(RegExp(r'[^\w\s-]'), '_');
        final file = File('${tempDir.path}/seating_plan_${planId}_$sanitizedDate.pdf');

        await file.writeAsBytes(bytes);

        if (Get.isDialogOpen ?? false) Get.back();

        Get.to(() => InvoiceViewScreen(
              filePath: file.path,
              title: "Seating PDF ($dateLabel)",
            ));
      } else {
        if (Get.isDialogOpen ?? false) Get.back();
        CustomSnackBar.showError("Error", "Failed to download PDF (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint("Error opening master PDF: $e");
      CustomSnackBar.showError("Error", "Unable to load PDF. Please check your internet connection.");
    } finally {
      isPdfLoading.value = false;
    }
  }
}

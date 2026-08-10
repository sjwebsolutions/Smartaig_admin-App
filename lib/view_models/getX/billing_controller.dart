import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_aig_admins_app/models/billing_model.dart';
import 'package:smart_aig_admins_app/services/billing_service.dart';
import 'package:smart_aig_admins_app/view/screens/invoice_view_screen.dart';

class BillingController extends GetxController {
  final BillingService _apiService = BillingService();
  
  var isLoading = true.obs;
  var billingList = <BillingData>[].obs;
  var isInvoiceLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBillings();
  }

  Future<void> fetchBillings() async {
    try {
      isLoading.value = true;
      final response = await _apiService.getBillings();
      if (response.success) {
        billingList.assignAll(response.data);
      }
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewInvoice(int id, String orderId) async {
    try {
      isInvoiceLoading.value = true;
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        barrierDismissible: false,
      );
      
      final response = await _apiService.getInvoice(id);
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/invoice_$id.pdf');
        
        await file.writeAsBytes(bytes);
        
        if (Get.isDialogOpen ?? false) Get.back(); // Close loading dialog
        
        // Navigate to internal PDF viewer screen
        Get.to(() => InvoiceViewScreen(
          filePath: file.path, 
          title: "Invoice $orderId"
        ));

      } else {
        if (Get.isDialogOpen ?? false) Get.back();
        Get.snackbar("Error", "Failed to download invoice (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isInvoiceLoading.value = false;
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/auth_response_model.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';
import 'package:smart_aig_admins_app/view/screens/auth/login_screen.dart';
import 'package:smart_aig_admins_app/view/screens/auth/otp_verification_screen.dart';
import 'package:smart_aig_admins_app/view/screens/main_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  var isLoading = false.obs;
  var phoneNumber = "".obs;

  Future<void> logout() async {
    isLoading.value = true;
    try {
      final response = await _authService.logout();
      
      // Clear local storage regardless of API success to ensure user can "leave"
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      Get.offAll(() => const LoginScreen());
      
      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          "Logged out successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      print("DEBUG: Logout Error: $e");
      Get.snackbar(
        "Error",
        "Logout failed: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String phone) async {
    print("DEBUG: sendOtp called with phone: $phone");
    if (phone.isEmpty || phone.length != 10) {
      print("DEBUG: Validation failed for phone: $phone");
      Get.snackbar(
        "Error",
        "Please enter a valid 10-digit mobile number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    isLoading.value = true;
    try {
      print("DEBUG: Calling _authService.sendOtp...");
      final response = await _authService.sendOtp(phone);
      print("DEBUG: Response received: $response");
      
      if (response['success'] == true) {
        phoneNumber.value = phone;
        print("DEBUG: Success! Navigating to OtpVerificationScreen");
        Get.to(() => OtpVerificationScreen(phoneNumber: "+91 $phone"));
      } else {
        print("DEBUG: API Error: ${response['message']}");
        Get.snackbar(
          "Error",
          response['message'] ?? "Something went wrong",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      print("DEBUG: Exception caught: $e");
      Get.snackbar(
        "Error",
        "Failed to send OTP: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
      print("DEBUG: sendOtp finished");
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    if (otpCode.length != 6) {
      Get.snackbar(
        "Error",
        "Please enter the 6-digit OTP",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    isLoading.value = true;
    try {
      final AuthResponseModel response = await _authService.verifyOtp(
        phoneNumber: phoneNumber.value,
        otpCode: otpCode,
      );

      if (response.success && response.data != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data!.token);
        await prefs.setString('user_data', jsonEncode(response.data!.teacher.toJson()));
        await prefs.setString('active_session', response.data!.activeSession);

        Get.offAll(() => const MainScreen());
      } else {
        Get.snackbar(
          "Error",
          response.message.isEmpty ? "Verification failed" : response.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyManualOtp(String phone, String otpCode) async {
    print("DEBUG: verifyManualOtp called with phone: $phone, otp: $otpCode");
    if (phone.length != 10) {
      print("DEBUG: Manual OTP Validation failed: Phone length is ${phone.length}");
      Get.snackbar(
        "Error",
        "Please enter valid 10-digit mobile number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }
    if (otpCode.length != 6) {
      print("DEBUG: Manual OTP Validation failed: OTP length is ${otpCode.length}");
      Get.snackbar(
        "Error",
        "Please enter the 6-digit OTP",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    isLoading.value = true;
    try {
      print("DEBUG: Calling _authService.verifyOtp for Manual Login...");
      final AuthResponseModel response = await _authService.verifyOtp(
        phoneNumber: phone,
        otpCode: otpCode,
      );
      print("DEBUG: Manual OTP Response - Success: ${response.success}, Message: ${response.message}");

      if (response.success && response.data != null) {
        print("DEBUG: Manual OTP Login Success! Saving data...");
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data!.token);
        await prefs.setString('user_data', jsonEncode(response.data!.teacher.toJson()));
        await prefs.setString('active_session', response.data!.activeSession);

        Get.offAll(() => const MainScreen());
        Get.snackbar(
          "Success",
          "Login Successful",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      } else {
        String errorMsg = response.message.isEmpty ? "Verification failed" : response.message;
        print("DEBUG: Manual OTP Login Failed: $errorMsg");
        Get.snackbar(
          "Error",
          errorMsg,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 5,
        );
      }
    } catch (e) {
      print("DEBUG: Manual OTP Exception: $e");
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
      print("DEBUG: verifyManualOtp finished");
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/auth_response_model.dart';
import 'package:smart_aig_admins_app/services/auth_service.dart';
import 'package:smart_aig_admins_app/view/screens/auth/login_screen.dart';
import 'package:smart_aig_admins_app/view/screens/auth/otp_verification_screen.dart';
import 'package:smart_aig_admins_app/view/screens/main_screen.dart';
import '../../utils/custom_snackbar.dart';

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
        CustomSnackBar.showSuccess(
          "Success",
          "Logged out successfully",
        );
      }
    } catch (e) {
      print("DEBUG: Logout Error: $e");
      CustomSnackBar.showError(
        "Logout Failed",
        "Unable to complete logout. Please check your connection and try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendOtp(String phone) async {
    print("DEBUG: sendOtp called with phone: $phone");
    if (phone.isEmpty || phone.length != 10) {
      print("DEBUG: Validation failed for phone: $phone");
      CustomSnackBar.showError(
        "Invalid Number",
        "Please enter a valid 10-digit mobile number",
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
        CustomSnackBar.showSuccess(
          "Success",
          response['message'] ?? "OTP sent successfully to your WhatsApp number",
        );
      } else {
        print("DEBUG: API Error: ${response['message']}");
        CustomSnackBar.showError(
          "Error",
          response['message'] ?? "Something went wrong. Please try again.",
        );
      }
    } catch (e) {
      print("DEBUG: Exception caught: $e");
      CustomSnackBar.showError(
        "Error",
        "Failed to send OTP. Please check your internet connection and try again.",
      );
    } finally {
      isLoading.value = false;
      print("DEBUG: sendOtp finished");
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    if (otpCode.length != 6) {
      CustomSnackBar.showError(
        "Invalid OTP",
        "Please enter the 6-digit OTP",
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
        CustomSnackBar.showSuccess(
          "Success",
          "Login Successful",
        );
      } else {
        CustomSnackBar.showError(
          "Verification Failed",
          response.message.isEmpty ? "Invalid OTP. Please try again." : response.message,
        );
      }
    } catch (e) {
      print("DEBUG: verifyOtp Exception: $e");
      CustomSnackBar.showError(
        "Error",
        "Verification failed. Please check your internet connection and try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyManualOtp(String phone, String otpCode) async {
    print("DEBUG: verifyManualOtp called with phone: $phone, otp: $otpCode");
    if (phone.length != 10) {
      print("DEBUG: Manual OTP Validation failed: Phone length is ${phone.length}");
      CustomSnackBar.showError(
        "Invalid Number",
        "Please enter valid 10-digit mobile number",
      );
      return;
    }
    if (otpCode.length != 6) {
      print("DEBUG: Manual OTP Validation failed: OTP length is ${otpCode.length}");
      CustomSnackBar.showError(
        "Invalid OTP",
        "Please enter the 6-digit OTP",
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
        CustomSnackBar.showSuccess(
          "Success",
          "Login Successful",
        );
      } else {
        String errorMsg = response.message.isEmpty ? "Verification failed" : response.message;
        print("DEBUG: Manual OTP Login Failed: $errorMsg");
        CustomSnackBar.showError(
          "Verification Failed",
          errorMsg,
        );
      }
    } catch (e) {
      print("DEBUG: Manual OTP Exception: $e");
      CustomSnackBar.showError(
        "Error",
        "Verification failed. Please check your internet connection and try again.",
      );
    } finally {
      isLoading.value = false;
      print("DEBUG: verifyManualOtp finished");
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/auth_response_model.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';
import 'package:smart_aig_admins_app/models/billing_model.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';

import '../view/screens/auth/login_screen.dart';
import '../utils/custom_snackbar.dart';

class AuthService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  String _formatError(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('failed host lookup') ||
        str.contains('no address associated') ||
        str.contains('connection refused') ||
        str.contains('timeoutexception') ||
        str.contains('network is unreachable')) {
      return "Network error: Please check your internet connection and try again.";
    }
    return "Something went wrong. Please try again.";
  }

  Future<void> updateFcmTokenOnServer(String fcmToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    final endpoints = [
      '$baseUrl/admin-teacher/fcm-token',
      '$baseUrl/admin-teacher/device-token',
      '$baseUrl/admin-teacher/auth/fcm-token',
      '$baseUrl/admin-teacher/update-fcm-token',
    ];

    for (String endpoint in endpoints) {
      try {
        await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "fcm_token": fcmToken,
            "device_token": fcmToken,
            "token": fcmToken,
            "platform": Platform.operatingSystem,
          }),
        ).timeout(const Duration(seconds: 4));
      } catch (e) {
        // Silently continue
      }
    }
  }

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/admin-teacher/auth/otp/request');
    
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceUuid = "unknown";
    String deviceName = "unknown";
    String deviceOs = Platform.operatingSystem;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceUuid = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceUuid = iosInfo.identifierForVendor ?? "unknown";
        deviceName = iosInfo.name;
      }

      final body = {
        "whatsapp_number": phoneNumber,
        "device_uuid": deviceUuid,
        "device_name": deviceName,
        "device_os": deviceOs,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SmartAIGAdminApp/1.0 (Mobile)',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        // Body is not JSON
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else if (response.statusCode == 429) {
        return {
          "success": false,
          "message": responseData['message'] ?? "Too many requests. Please wait a few minutes and try again."
        };
      } else {
        return {
          "success": false,
          "message": responseData['message'] ?? "Server error: ${response.statusCode}. Please try again later."
        };
      }
    } on SocketException {
      return {
        "success": false,
        "message": "Network error: Please check your internet connection."
      };
    } on FormatException {
      return {
        "success": false,
        "message": "Invalid response from server. Please contact support."
      };
    } catch (e) {
      return {
        "success": false,
        "message": _formatError(e)
      };
    }
  }

  Future<AuthResponseModel> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final url = Uri.parse('$baseUrl/admin-teacher/auth/otp/verify');

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceUuid = "unknown";
    String deviceName = "unknown";
    String deviceOs = Platform.operatingSystem;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceUuid = androidInfo.id;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceUuid = iosInfo.identifierForVendor ?? "unknown";
        deviceName = iosInfo.name;
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'SmartAIGAdminApp/1.0 (Mobile)',
        },
        body: jsonEncode({
          "whatsapp_number": phoneNumber,
          "otp_code": otpCode,
          "device_uuid": deviceUuid,
          "device_name": deviceName,
          "device_os": deviceOs,
        }),
      ).timeout(const Duration(seconds: 15));

      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AuthResponseModel.fromJson(responseData);
      } else if (response.statusCode == 429) {
        return AuthResponseModel(
          success: false,
          message: responseData['message'] ?? "Too many attempts. Please try again later.",
        );
      } else {
        return AuthResponseModel(
          success: false,
          message: responseData['message'] ?? "Server error: ${response.statusCode}. Please try again later.",
        );
      }
    } on SocketException {
      return AuthResponseModel(
        success: false,
        message: "Network error: Please check your internet connection.",
      );
    } on FormatException {
      return AuthResponseModel(
        success: false,
        message: "Invalid response from server. Please contact support.",
      );
    } catch (e) {
      return AuthResponseModel(
        success: false,
        message: _formatError(e),
      );
    }
  }

  Future<DashboardModel> getDashboardData() async {
    final url = Uri.parse('$baseUrl/admin-teacher/dashboard');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // Sync FCM token with server in background safely
    try {
      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.syncFcmTokenAndSubscriptions();
      } else {
        FirebaseMessaging.instance.getToken().then((fcmToken) {
          if (fcmToken != null && fcmToken.isNotEmpty) {
            updateFcmTokenOnServer(fcmToken);
          }
        }).catchError((e) {
          if (kDebugMode) {
            debugPrint("FCM token sync error in getDashboardData: $e");
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("FCM instance error in getDashboardData: $e");
      }
    }

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 25));

        if (kDebugMode) {
          debugPrint("getDashboardData response code: ${response.statusCode}");
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return DashboardModel.fromJson(decoded);
          }
        } else if (response.statusCode == 401) {
          _forceLogout();
          return DashboardModel(success: false);
        } else {
          if (attempt == 1) return DashboardModel(success: false);
        }
      } catch (e, stack) {
        if (kDebugMode) {
          debugPrint("getDashboardData exception (attempt $attempt): $e\n$stack");
        }
        if (attempt == 1) return DashboardModel(success: false);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return DashboardModel(success: false);
  }

  void _forceLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const LoginScreen());
    CustomSnackBar.showError(
      "Session Expired",
      "Please login again",
    );
  }

  Future<BillingModel> getBillings() async {
    final url = Uri.parse('$baseUrl/admin-teacher/billings');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return BillingModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        _forceLogout();
        return BillingModel(success: false, data: []);
      } else {
        return BillingModel(success: false, data: []);
      }
    } catch (e) {
      return BillingModel(success: false, data: []);
    }
  }

  Future<http.Response> getInvoice(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/billings/$id/invoice');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    return await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));
  }

  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$baseUrl/admin-teacher/auth/logout');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Logout server error: ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": false, "message": _formatError(e)};
    }
  }
}

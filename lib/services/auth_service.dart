import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/auth_response_model.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';
import 'package:smart_aig_admins_app/models/billing_model.dart';

class AuthService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {
        "success": false,
        "message": "Error occurred: $e"
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "whatsapp_number": phoneNumber,
          "otp_code": otpCode,
          "device_uuid": deviceUuid,
          "device_name": deviceName,
          "device_os": deviceOs,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return AuthResponseModel.fromJson(responseData);
    } catch (e) {
      return AuthResponseModel(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<DashboardModel> getDashboardData() async {
    final url = Uri.parse('$baseUrl/admin-teacher/dashboard');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(jsonDecode(response.body));
      } else {
        return DashboardModel(success: false);
      }
    } catch (e) {
      return DashboardModel(success: false);
    }
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
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return BillingModel.fromJson(jsonDecode(response.body));
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
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Error occurred: $e"};
    }
  }
}

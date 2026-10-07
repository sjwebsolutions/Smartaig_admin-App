import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/qr_scan_response_model.dart';
import 'package:smart_aig_admins_app/models/qr_settings_model.dart';

class QrAttendanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Fetch QR Attendance Settings
  Future<QrSettingsModel> getQrSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/student-attendance/qr-settings');

    if (kDebugMode) {
      debugPrint("📡 [QrAttendanceService] Requesting: $url");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("📥 [QrAttendanceService] Status Code: ${response.statusCode}");
        debugPrint("📥 [QrAttendanceService] Response Body: ${response.body}");
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return QrSettingsModel.fromJson(decoded);
      } else {
        final String message = decoded is Map<String, dynamic>
            ? (decoded['message']?.toString() ?? 'Failed to fetch QR settings.')
            : 'Server error ${response.statusCode}';
        return QrSettingsModel(
          success: false,
          message: message,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ [QrAttendanceService] Exception: $e");
      }
      return QrSettingsModel(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Submit Scanned QR Code
  Future<QrScanResponseModel> scanQrCode({
    required String qrPayload,
    String sourceApp = 'android',
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/student-attendance/qr-scan');

    final Map<String, dynamic> body = {
      'qr_payload': qrPayload.trim(),
      'source_app': sourceApp,
    };

    if (kDebugMode) {
      debugPrint("📡 [QrAttendanceService] POST: $url");
      debugPrint("📦 [QrAttendanceService] Body: ${jsonEncode(body)}");
    }

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("📥 [QrAttendanceService] Status Code: ${response.statusCode}");
        debugPrint("📥 [QrAttendanceService] Response Body: ${response.body}");
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return QrScanResponseModel.fromJson(decoded);
      } else {
        final String message = decoded is Map<String, dynamic>
            ? (decoded['message']?.toString() ?? 'QR scan failed.')
            : 'Server error with status code ${response.statusCode}';
        return QrScanResponseModel(
          success: false,
          message: message,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("❌ [QrAttendanceService] Scan Exception: $e");
      }
      return QrScanResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }
}

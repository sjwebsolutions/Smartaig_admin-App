import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/admit_card_scan_model.dart';

class AdmitCardScanService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Verify admit card via QR Code URL/payload or Student ID / Roll No
  Future<AdmitCardScanResponseModel> verifyAdmitCard({
    String? qrCode,
    dynamic studentId,
  }) async {
    final uri = Uri.parse('$baseUrl/admin-teacher/admit-card/scan-verify');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> body = {};
    if (qrCode != null && qrCode.trim().isNotEmpty) {
      body['qr_code'] = qrCode.trim();
    }
    if (studentId != null) {
      if (studentId is int) {
        body['student_id'] = studentId;
      } else {
        final parsed = int.tryParse(studentId.toString().trim());
        body['student_id'] = parsed ?? studentId.toString().trim();
      }
    }

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📡 [AdmitCardScanService] Request URL: $uri");
    print("📦 [AdmitCardScanService] Request Body: ${jsonEncode(body)}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      print("📥 [AdmitCardScanService] Status Code: ${response.statusCode}");
      print("📥 [AdmitCardScanService] Response Body: ${response.body}");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AdmitCardScanResponseModel.fromJson(decoded);
      } else {
        final String message = decoded is Map<String, dynamic>
            ? (decoded['message']?.toString() ?? 'Admit card verification failed.')
            : 'Admit card verification failed with status ${response.statusCode}';
        return AdmitCardScanResponseModel(
          success: false,
          message: message,
        );
      }
    } catch (e) {
      print("❌ [AdmitCardScanService] Error: $e");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      return AdmitCardScanResponseModel(
        success: false,
        message: e.toString(),
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/support_settings_model.dart';

class SupportService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [SupportService]: $message");
    }
  }

  Future<SupportSettingsModel> getSupportSettings() async {
    final url = Uri.parse('$baseUrl/admin-teacher/support-settings');
    _log("GET Request to: $url");
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

      _log("Response Code: ${response.statusCode}");
      _log("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return SupportSettingsModel.fromJson(jsonDecode(response.body));
      } else {
        return SupportSettingsModel(success: false);
      }
    } catch (e) {
      _log("Error in getSupportSettings: $e");
      return SupportSettingsModel(success: false);
    }
  }
}

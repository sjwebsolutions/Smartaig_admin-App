import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/notification_model.dart';

class ApiNotificationService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [ApiNotificationService]: $message");
    }
  }

  String _formatError(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('failed host lookup') ||
        str.contains('no address associated') ||
        str.contains('connection refused') ||
        str.contains('timeoutexception') ||
        str.contains('network is unreachable')) {
      return "Unable to connect. Please check your internet connection and try again.";
    }
    return "Something went wrong. Please try again.";
  }

  Future<NotificationResponseModel> getNotifications({int page = 1}) async {
    final Uri url = Uri.parse('$baseUrl/admin-teacher/notifications?page=$page');
    _log("GET Request to: $url");
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

      _log("Notifications Response Code: ${response.statusCode}");
      _log("Notifications Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return NotificationResponseModel.fromJson(jsonDecode(response.body));
      } else {
        String msg = "Failed to load notifications. Status: ${response.statusCode}";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            msg = errorData['message'];
          }
        } catch (_) {}
        return NotificationResponseModel(
          success: false,
          message: msg,
        );
      }
    } catch (e) {
      _log("Error in getNotifications: $e");
      return NotificationResponseModel(
        success: false,
        message: _formatError(e),
      );
    }
  }
}

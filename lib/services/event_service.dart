import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/event_pass_scan_model.dart';
import 'package:smart_aig_admins_app/models/event_today_scans_model.dart';

class EventService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [EventService]: $message");
    }
  }

  Future<EventTodayScansModel> getTodayScans({
    int? eventId,
    String? gateName,
    bool? myScansOnly,
    int? limit,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, String> queryParams = {};
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (gateName != null && gateName.trim().isNotEmpty) {
      queryParams['gate_name'] = gateName.trim();
    }
    if (myScansOnly != null) queryParams['my_scans_only'] = myScansOnly.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/today-scans')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    _log("GET Request to: $url");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Response status: ${response.statusCode}");

      // Fallback if endpoint is under root /events/passes/today-scans
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/today-scans')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
        _log("404 received, trying fallback URL: $url");
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        _log("Fallback response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return EventTodayScansModel.fromJson(decoded);
      } else {
        _log("Error Response: ${response.body}");
        return EventTodayScansModel(
          success: false,
          message: "Failed to load today scans (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      _log("Exception in getTodayScans: $e");
      return EventTodayScansModel(
        success: false,
        message: "Network error. Please try again later.",
      );
    }
  }

  Future<EventPassScanModel> scanPass({
    String? qrPayload,
    String? gateName,
    String? qrCode,
    String? passNumber,
    String? token,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');

    final Map<String, dynamic> body = {};
    if (qrPayload != null && qrPayload.isNotEmpty) body['qr_payload'] = qrPayload;
    if (gateName != null && gateName.isNotEmpty) body['gate_name'] = gateName;
    if (qrCode != null && qrCode.isNotEmpty) body['qr_code'] = qrCode;
    if (passNumber != null && passNumber.isNotEmpty) body['pass_number'] = passNumber;
    if (token != null && token.isNotEmpty) body['token'] = token;

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/scan');
    _log("POST Request to: $url with body: ${jsonEncode(body)}");

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      _log("Scan response status: ${response.statusCode}");

      // Fallback
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/scan');
        _log("404 received, trying fallback URL: $url");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
        _log("Fallback scan response status: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      _log("Decoded scan response: $decoded");
      return EventPassScanModel.fromJson(decoded);
    } catch (e) {
      _log("Exception in scanPass: $e");
      return EventPassScanModel(
        success: false,
        message: "Failed to process pass scan: $e",
      );
    }
  }
}

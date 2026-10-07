import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/callback_detail_model.dart';
import 'package:smart_aig_admins_app/models/callback_request_model.dart';

class CallbackService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<CallbackRequestResponse> getCallbackRequests({
    String? status,
    String? date,
    String? fromDate,
    String? toDate,
    int page = 1,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, String> queryParams = {};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }
    if (fromDate != null && fromDate.isNotEmpty) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null && toDate.isNotEmpty) {
      queryParams['to_date'] = toDate;
    }
    if (page > 1) {
      queryParams['page'] = page.toString();
    }

    final Uri url = Uri.parse('$baseUrl/admin-teacher/callback-requests')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return CallbackRequestResponse.fromJson(jsonDecode(response.body));
      } else {
        return CallbackRequestResponse(success: false, data: []);
      }
    } catch (e) {
      print("DEBUG: Callback Request API Exception: $e");
      return CallbackRequestResponse(success: false, data: []);
    }
  }

  Future<CallbackSummaryResponse> getCallbackSummary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/callback-requests/summary');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return CallbackSummaryResponse.fromJson(jsonDecode(response.body));
      } else {
        return CallbackSummaryResponse(success: false);
      }
    } catch (e) {
      print("DEBUG: Callback Summary API Exception: $e");
      return CallbackSummaryResponse(success: false);
    }
  }

  Future<CallbackDetailResponse> getCallbackDetail(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/callback-requests/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return CallbackDetailResponse.fromJson(jsonDecode(response.body));
      } else {
        return CallbackDetailResponse(success: false);
      }
    } catch (e) {
      print("DEBUG: Callback Detail API Exception: $e");
      return CallbackDetailResponse(success: false);
    }
  }
}

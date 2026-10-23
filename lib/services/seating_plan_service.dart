import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/seating_plan_model.dart';
import 'package:smart_aig_admins_app/models/seating_plan_detail_model.dart';

class SeatingPlanService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Get all Seating Plans for the school
  /// Endpoint: https://smartaig.com/api/v1/admin-teacher/seating-plans
  Future<SeatingPlanResponse> getSeatingPlans() async {
    final url = Uri.parse('$baseUrl/admin-teacher/seating-plans');
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
        final decoded = jsonDecode(response.body);
        return SeatingPlanResponse.fromJson(decoded);
      } else {
        debugPrint("Seating Plan API error status: ${response.statusCode}");
        return SeatingPlanResponse(success: false, data: []);
      }
    } catch (e) {
      debugPrint("Seating Plan API Exception: $e");
      return SeatingPlanResponse(success: false, data: []);
    }
  }

  /// Get Seating Plan Details
  /// Endpoint: https://smartaig.com/api/v1/admin-teacher/seating-plans/{id}
  Future<SeatingPlanDetailResponse> getSeatingPlanDetail(int planId) async {
    final url = Uri.parse('$baseUrl/admin-teacher/seating-plans/$planId');
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
        final decoded = jsonDecode(response.body);
        return SeatingPlanDetailResponse.fromJson(decoded);
      } else {
        debugPrint("Seating Plan Detail API error status: ${response.statusCode}");
        return SeatingPlanDetailResponse(success: false);
      }
    } catch (e) {
      debugPrint("Seating Plan Detail API exception: $e");
      return SeatingPlanDetailResponse(success: false);
    }
  }

  /// Download or fetch Master PDF bytes with auth headers
  /// Endpoint: https://smartaig.com/api/v1/admin-teacher/seating-plans/{id}/master-pdf?exam_date={date}
  Future<http.Response> getMasterPdf(String pdfUrlOrDate, {int? planId}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri uri;
    if (pdfUrlOrDate.startsWith('http://') || pdfUrlOrDate.startsWith('https://')) {
      uri = Uri.parse(pdfUrlOrDate);
    } else if (pdfUrlOrDate.startsWith('/')) {
      uri = Uri.parse('$baseUrl$pdfUrlOrDate');
    } else if (planId != null) {
      uri = Uri.parse('$baseUrl/admin-teacher/seating-plans/$planId/master-pdf?exam_date=$pdfUrlOrDate');
    } else {
      uri = Uri.parse(pdfUrlOrDate);
    }

    return await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));
  }
}

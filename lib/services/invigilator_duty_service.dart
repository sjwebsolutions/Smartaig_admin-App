import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_model.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_detail_model.dart';
import 'package:smart_aig_admins_app/models/free_staff_model.dart';
import 'package:smart_aig_admins_app/models/staff_duties_model.dart';

class InvigilatorDutyService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<InvigilatorDutyResponse> getInvigilatorDuties() async {
    final url = Uri.parse('$baseUrl/admin-teacher/invigilator-duties');
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
        return InvigilatorDutyResponse.fromJson(jsonDecode(response.body));
      } else {
        return InvigilatorDutyResponse(success: false, data: []);
      }
    } catch (e) {
      print("DEBUG: Invigilator Duty API Exception: $e");
      return InvigilatorDutyResponse(success: false, data: []);
    }
  }

  Future<InvigilatorDutyDetailResponse> getInvigilatorDutyDetails(int id, {String? date}) async {
    final queryParams = date != null ? '?exam_date=$date' : '';
    final url = Uri.parse('$baseUrl/admin-teacher/invigilator-duties/$id$queryParams');
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
        return InvigilatorDutyDetailResponse.fromJson(jsonDecode(response.body));
      } else {
        return InvigilatorDutyDetailResponse(success: false);
      }
    } catch (e) {
      print("DEBUG: Invigilator Duty Detail API Exception: $e");
      return InvigilatorDutyDetailResponse(success: false);
    }
  }

  Future<FreeStaffResponse> getFreeStaff(int id, {String? examDate}) async {
    final queryParams = examDate != null ? '?exam_date=$examDate' : '';
    final url = Uri.parse('$baseUrl/admin-teacher/invigilator-duties/$id/free-staff$queryParams');
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
        return FreeStaffResponse.fromJson(jsonDecode(response.body));
      } else {
        return FreeStaffResponse(success: false);
      }
    } catch (e) {
      print("DEBUG: Free Staff API Exception: $e");
      return FreeStaffResponse(success: false);
    }
  }

  Future<StaffDutiesResponse> getStaffDuties(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/invigilator-duties/$id/staff-duties');
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
        return StaffDutiesResponse.fromJson(jsonDecode(response.body));
      } else {
        return StaffDutiesResponse(success: false);
      }
    } catch (e) {
      print("DEBUG: Staff Duties API Exception: $e");
      return StaffDutiesResponse(success: false);
    }
  }
}

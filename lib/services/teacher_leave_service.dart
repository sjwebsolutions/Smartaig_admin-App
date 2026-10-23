import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/teacher_leave_model.dart';

class TeacherLeaveService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<TeacherLeaveResponseModel> getTeacherLeaves() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/teacher-leaves');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("Teacher Leaves API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return TeacherLeaveResponseModel.fromJson(jsonDecode(response.body));
      } else {
        return TeacherLeaveResponseModel(success: false, data: []);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Teacher Leaves API Exception: $e");
      }
      return TeacherLeaveResponseModel(success: false, data: []);
    }
  }

  Future<Map<String, dynamic>> rejectLeave({
    required int leaveId,
    required String rejectionReason,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/teacher-leaves/$leaveId/reject');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rejection_reason': rejectionReason,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("Reject Teacher Leave API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          return {'success': false, 'message': body['message'] ?? 'Failed to reject teacher leave application.'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to reject teacher leave application.'};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Reject Teacher Leave Exception: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> approveLeave({
    required int leaveId,
    String? remarks,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/teacher-leaves/$leaveId/approve');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (remarks != null && remarks.isNotEmpty) 'approver_remarks': remarks,
        }),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("Approve Teacher Leave API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          return {'success': false, 'message': body['message'] ?? 'Failed to approve teacher leave application.'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to approve teacher leave application.'};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Approve Teacher Leave Exception: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}

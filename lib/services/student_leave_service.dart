import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/student_leave_model.dart';

class StudentLeaveService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<StudentLeaveResponseModel> getStudentLeaves({
    String? classId,
    String? sectionId,
    String? streamId,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Map<String, String> queryParams = {
      'student_class_id': (classId != null && classId.isNotEmpty) ? classId : '',
      'student_section_id': (sectionId != null && sectionId.isNotEmpty) ? sectionId : '',
      'student_stream_id': (streamId != null && streamId.isNotEmpty) ? streamId : '',
    };

    final Uri url = Uri.parse('$baseUrl/admin-teacher/student-leaves')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint("Student Leaves API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return StudentLeaveResponseModel.fromJson(jsonDecode(response.body));
      } else {
        return StudentLeaveResponseModel(success: false, data: []);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Student Leaves API Exception: $e");
      }
      return StudentLeaveResponseModel(success: false, data: []);
    }
  }

  Future<Map<String, dynamic>> rejectLeave({
    required int leaveId,
    required String rejectionReason,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri url = Uri.parse('$baseUrl/admin-teacher/student-leaves/$leaveId/reject');

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
        debugPrint("Reject Leave API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          return {'success': false, 'message': body['message'] ?? 'Failed to reject leave application.'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to reject leave application.'};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Reject Leave Exception: $e");
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

    final Uri url = Uri.parse('$baseUrl/admin-teacher/student-leaves/$leaveId/approve');

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
        debugPrint("Approve Leave API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          return {'success': false, 'message': body['message'] ?? 'Failed to approve leave application.'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to approve leave application.'};
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("DEBUG: Approve Leave Exception: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}

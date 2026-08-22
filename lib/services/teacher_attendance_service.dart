import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/teacher_attendance_report_model.dart';

class TeacherAttendanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<TeacherAttendanceReportModel> getTodaySummary() async {
    // Note: I'm assuming this URL, please update if it's different
    final url = Uri.parse('$baseUrl/admin-teacher/teacher-attendance/today-summary');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print("Teacher Attendance API Response: ${response.body}");

      if (response.statusCode == 200) {
        return TeacherAttendanceReportModel.fromJson(jsonDecode(response.body));
      } else {
        return TeacherAttendanceReportModel(success: false);
      }
    } catch (e) {
      print("Error fetching teacher attendance summary: $e");
      return TeacherAttendanceReportModel(success: false);
    }
  }

  Future<Map<String, dynamic>> sendAttendanceReminder(String teacherUid) async {
    final url = Uri.parse('$baseUrl/admin-teacher/teacher-attendance/send-reminder');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teacher_uid': teacherUid,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Send Reminder Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("Error sending attendance reminder: $e");
      return {'success': false, 'message': e.toString()};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/student_attendance_report_model.dart';

class StudentAttendanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<StudentAttendanceReportModel> getTodaySummary() async {
    final url = Uri.parse('$baseUrl/admin-teacher/attendance/today-summary');
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

      print("Attendance API Response: ${response.body}");

      if (response.statusCode == 200) {
        return StudentAttendanceReportModel.fromJson(jsonDecode(response.body));
      } else {
        return StudentAttendanceReportModel(success: false);
      }
    } catch (e) {
      print("Error fetching attendance summary: $e");
      return StudentAttendanceReportModel(success: false);
    }
  }
}

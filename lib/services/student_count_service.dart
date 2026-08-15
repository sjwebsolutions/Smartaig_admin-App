import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/student_count_model.dart';

class StudentCountService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<StudentCountModel> getStudentCount() async {
    final url = Uri.parse('$baseUrl/admin-teacher/students/count');
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

      print("Student Count API Response: ${response.body}");

      if (response.statusCode == 200) {
        return StudentCountModel.fromJson(jsonDecode(response.body));
      } else {
        return StudentCountModel(success: false);
      }
    } catch (e) {
      print("Error fetching student count: $e");
      return StudentCountModel(success: false);
    }
  }
}

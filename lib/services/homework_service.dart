import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/homework_status_model.dart';

class HomeworkService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<HomeworkStatusModel> getHomeworkUploadStatus() async {
    final url = Uri.parse('$baseUrl/admin-teacher/homework/upload-status');
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

      print("Homework API Response: ${response.body}");

      if (response.statusCode == 200) {
        return HomeworkStatusModel.fromJson(jsonDecode(response.body));
      } else {
        return HomeworkStatusModel(success: false);
      }
    } catch (e) {
      print("Error fetching homework status: $e");
      return HomeworkStatusModel(success: false);
    }
  }
}

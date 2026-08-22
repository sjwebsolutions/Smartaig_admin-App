import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/homework_status_model.dart';

class HomeworkService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<HomeworkStatusModel> getHomeworkUploadStatus({
    String? date,
    int? classId,
    int? sectionId,
    int? streamId,
  }) async {
    Map<String, String> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (classId != null) queryParams['class_id'] = classId.toString();
    if (sectionId != null) queryParams['section_id'] = sectionId.toString();
    if (streamId != null) queryParams['stream_id'] = streamId.toString();

    final uri = Uri.parse('$baseUrl/admin-teacher/homework/upload-status')
        .replace(queryParameters: queryParams);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        uri,
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

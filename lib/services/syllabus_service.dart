import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/syllabus_model.dart';

class SyllabusService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [SyllabusService]: $message");
    }
  }

  Future<SyllabusResponseModel> getSyllabus({
    int? termId,
    int? classId,
    int? subjectId,
  }) async {
    final queryParams = <String, String>{};
    if (termId != null) queryParams['term_id'] = termId.toString();
    if (classId != null) queryParams['class_id'] = classId.toString();
    if (subjectId != null) queryParams['subject_id'] = subjectId.toString();

    final uri = Uri.parse('$baseUrl/admin-teacher/syllabus').replace(queryParameters: queryParams);
    _log("GET Request to: $uri");
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Syllabus Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return SyllabusResponseModel.fromJson(jsonDecode(response.body));
      } else {
        _log("Syllabus Error: ${response.body}");
        return SyllabusResponseModel(
          success: false,
        );
      }
    } catch (e) {
      _log("Error in getSyllabus: $e");
      return SyllabusResponseModel(
        success: false,
      );
    }
  }
}

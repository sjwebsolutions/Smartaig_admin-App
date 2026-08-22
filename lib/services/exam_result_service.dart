import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/exam_result_model.dart';
import 'package:smart_aig_admins_app/models/exam_result_classes_model.dart';
import 'package:smart_aig_admins_app/models/exam_result_class_details_model.dart';
import 'package:smart_aig_admins_app/models/exam_result_summary_model.dart';

class ExamResultService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<ExamResultModel> getExams() async {
    final url = Uri.parse('$baseUrl/admin-teacher/exam-results/exams');
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

      print("Exam Result API Response: ${response.body}");

      if (response.statusCode == 200) {
        return ExamResultModel.fromJson(jsonDecode(response.body));
      } else {
        return ExamResultModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching exam results: $e");
      return ExamResultModel(success: false, data: []);
    }
  }

  Future<ExamResultClassesModel> getClasses(int examId) async {
    final url = Uri.parse('$baseUrl/admin-teacher/exam-results/$examId/classes');
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

      print("Exam Result Classes API Response: ${response.body}");

      if (response.statusCode == 200) {
        return ExamResultClassesModel.fromJson(jsonDecode(response.body));
      } else {
        return ExamResultClassesModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching exam result classes: $e");
      return ExamResultClassesModel(success: false, data: []);
    }
  }

  Future<ExamResultClassDetailsModel> getClassDetails(int examId, int classId) async {
    final url = Uri.parse('$baseUrl/admin-teacher/exam-results/$examId/class-details?class_id=$classId');
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

      print("Exam Result Class Details API Response: ${response.body}");

      if (response.statusCode == 200) {
        return ExamResultClassDetailsModel.fromJson(jsonDecode(response.body));
      } else {
        return ExamResultClassDetailsModel(success: false);
      }
    } catch (e) {
      print("Error fetching exam result class details: $e");
      return ExamResultClassDetailsModel(success: false);
    }
  }

  Future<ExamResultSummaryModel> getSummary({
    required int marksEntryId,
    required int classId,
    int? sectionId,
    int? streamId,
  }) async {
    String queryParams = 'marks_entry_id=$marksEntryId&class_id=$classId';
    if (sectionId != null) queryParams += '&section_id=$sectionId';
    if (streamId != null) queryParams += '&stream_id=$streamId';

    final url = Uri.parse('$baseUrl/admin-teacher/exam-results/summary?$queryParams');
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

      print("Exam Result Summary API Response: ${response.body}");

      if (response.statusCode == 200) {
        return ExamResultSummaryModel.fromJson(jsonDecode(response.body));
      } else {
        return ExamResultSummaryModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching exam result summary: $e");
      return ExamResultSummaryModel(success: false, data: []);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/marks_entry_model.dart';
import 'package:smart_aig_admins_app/models/marks_entry_classes_model.dart';
import 'package:smart_aig_admins_app/models/marks_entry_class_details_model.dart';
import 'package:smart_aig_admins_app/models/marks_upload_status_model.dart';

class MarksEntryService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<MarksEntryModel> getExams() async {
    final url = Uri.parse('$baseUrl/admin-teacher/marks-entry');
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

      print("Marks Entry API Response: ${response.body}");

      if (response.statusCode == 200) {
        return MarksEntryModel.fromJson(jsonDecode(response.body));
      } else {
        return MarksEntryModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching marks entry exams: $e");
      return MarksEntryModel(success: false, data: []);
    }
  }

  Future<MarksEntryClassesModel> getClasses(int examId) async {
    final url = Uri.parse('$baseUrl/admin-teacher/marks-entry/$examId/classes');
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

      print("Marks Entry Classes API Response: ${response.body}");

      if (response.statusCode == 200) {
        return MarksEntryClassesModel.fromJson(jsonDecode(response.body));
      } else {
        return MarksEntryClassesModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching marks entry classes: $e");
      return MarksEntryClassesModel(success: false, data: []);
    }
  }

  Future<MarksEntryClassDetailsModel> getClassDetails(int examId, int classId) async {
    final url = Uri.parse('$baseUrl/admin-teacher/marks-entry/$examId/class-details?class_id=$classId');
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

      print("Marks Entry Class Details API Response: ${response.body}");

      if (response.statusCode == 200) {
        return MarksEntryClassDetailsModel.fromJson(jsonDecode(response.body));
      } else {
        return MarksEntryClassDetailsModel(success: false);
      }
    } catch (e) {
      print("Error fetching marks entry class details: $e");
      return MarksEntryClassDetailsModel(success: false);
    }
  }

  Future<MarksUploadStatusModel> getUploadStatus({
    required int marksEntryId,
    required int classId,
    int? sectionId,
    int? streamId,
  }) async {
    String queryParams = 'marks_entry_id=$marksEntryId&class_id=$classId';
    if (sectionId != null) queryParams += '&section_id=$sectionId';
    if (streamId != null) queryParams += '&stream_id=$streamId';

    final url = Uri.parse('$baseUrl/admin-teacher/marks-entry/upload-status?$queryParams');
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

      print("Marks Upload Status API Response: ${response.body}");

      if (response.statusCode == 200) {
        return MarksUploadStatusModel.fromJson(jsonDecode(response.body));
      } else {
        return MarksUploadStatusModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching marks upload status: $e");
      return MarksUploadStatusModel(success: false, data: []);
    }
  }
}

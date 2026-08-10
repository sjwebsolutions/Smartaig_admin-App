import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/announcement_model.dart';
import 'package:smart_aig_admins_app/models/announcement_detail_model.dart';
import 'package:smart_aig_admins_app/models/announcement_type_model.dart';
import 'package:smart_aig_admins_app/models/targeting_data_model.dart';
import 'package:smart_aig_admins_app/models/create_announcement_response.dart';
import 'dart:io';

class AnnouncementService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [AnnouncementService]: $message");
    }
  }

  Future<CreateAnnouncementResponse> storeAnnouncement({
    required String title,
    required String description,
    required int typeId,
    File? image,
    required String fromDate,
    String? fromTime,
    required String toDate,
    String? toTime,
    required String targetType,
    List<Map<String, dynamic>>? targets,
  }) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/store');
    _log("POST Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['type_id'] = typeId.toString();
      request.fields['from_date'] = fromDate;
      if (fromTime != null) request.fields['from_time'] = fromTime;
      request.fields['to_date'] = toDate;
      if (toTime != null) request.fields['to_time'] = toTime;
      request.fields['target_type'] = targetType;

      _log("Fields: ${request.fields}");

      if (image != null) {
        _log("Adding image: ${image.path}");
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      if (targetType == 'specific' && targets != null) {
        _log("Adding specific targets: $targets");
        for (int i = 0; i < targets.length; i++) {
          final target = targets[i];
          request.fields['targets[$i][class_id]'] = target['class_id'].toString();
          request.fields['targets[$i][stream_id]'] = target['stream_id'].toString();
          
          List<int> sectionIds = target['section_ids'] ?? [];
          for (int j = 0; j < sectionIds.length; j++) {
            request.fields['targets[$i][section_ids][$j]'] = sectionIds[j].toString();
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _log("Response Code: ${response.statusCode}");
      _log("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateAnnouncementResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        return CreateAnnouncementResponse(
          success: false,
          message: errorData['message'] ?? "Failed to create announcement. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in storeAnnouncement: $e");
      return CreateAnnouncementResponse(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<CreateAnnouncementResponse> updateAnnouncement({
    required int id,
    required String title,
    required String description,
    required int typeId,
    File? image,
    required String fromDate,
    String? fromTime,
    required String toDate,
    String? toTime,
    required String targetType,
    List<Map<String, dynamic>>? targets,
  }) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/update/$id');
    _log("POST (Update) Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['type_id'] = typeId.toString();
      request.fields['from_date'] = fromDate;
      if (fromTime != null) request.fields['from_time'] = fromTime;
      request.fields['to_date'] = toDate;
      if (toTime != null) request.fields['to_time'] = toTime;
      request.fields['target_type'] = targetType;

      _log("Update Fields: ${request.fields}");

      if (image != null) {
        _log("Adding new image: ${image.path}");
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      if (targetType == 'specific' && targets != null) {
        _log("Update specific targets: $targets");
        for (int i = 0; i < targets.length; i++) {
          final target = targets[i];
          request.fields['targets[$i][class_id]'] = target['class_id'].toString();
          request.fields['targets[$i][stream_id]'] = target['stream_id'].toString();

          List<int> sectionIds = target['section_ids'] ?? [];
          for (int j = 0; j < sectionIds.length; j++) {
            request.fields['targets[$i][section_ids][$j]'] = sectionIds[j].toString();
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _log("Update Response Code: ${response.statusCode}");
      _log("Update Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateAnnouncementResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        return CreateAnnouncementResponse(
          success: false,
          message: errorData['message'] ?? "Failed to update announcement. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in updateAnnouncement: $e");
      return CreateAnnouncementResponse(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<TargetingDataResponse> getTargetingData() async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/targeting-data');
    _log("GET Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Targeting Data Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return TargetingDataResponse.fromJson(jsonDecode(response.body));
      } else {
        _log("Targeting Data Error: ${response.body}");
        return TargetingDataResponse(
          success: false,
          message: "Failed to load targeting data. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in getTargetingData: $e");
      return TargetingDataResponse(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<AnnouncementTypeResponse> getAnnouncementTypes() async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/types');
    _log("GET Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Types Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return AnnouncementTypeResponse.fromJson(jsonDecode(response.body));
      } else {
        _log("Types Error: ${response.body}");
        return AnnouncementTypeResponse(
          success: false,
          message: "Failed to load announcement types. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in getAnnouncementTypes: $e");
      return AnnouncementTypeResponse(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<AnnouncementResponseModel> getAnnouncements() async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements');
    _log("GET Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("List Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return AnnouncementResponseModel.fromJson(jsonDecode(response.body));
      } else {
        _log("List Error: ${response.body}");
        return AnnouncementResponseModel(
          success: false,
          message: "Failed to load announcements. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in getAnnouncements: $e");
      return AnnouncementResponseModel(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<AnnouncementDetailResponse> getAnnouncementDetails(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/show/$id');
    _log("GET Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Detail Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return AnnouncementDetailResponse.fromJson(jsonDecode(response.body));
      } else {
        _log("Detail Error: ${response.body}");
        return AnnouncementDetailResponse(
          success: false,
          message: "Failed to load announcement details. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      _log("Error in getAnnouncementDetails: $id - $e");
      return AnnouncementDetailResponse(
        success: false,
        message: "Error occurred: $e",
      );
    }
  }

  Future<Map<String, dynamic>> toggleAnnouncementStatus(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/toggle-status/$id');
    _log("POST Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Toggle Status Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      _log("Error in toggleAnnouncementStatus: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> lockAnnouncement(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/lock/$id');
    _log("POST Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Lock Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      _log("Error in lockAnnouncement: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> unlockAnnouncement(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/unlock/$id');
    _log("POST Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Unlock Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      _log("Error in unlockAnnouncement: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> publishAnnouncement(int id, {required int sendToParents, required int sendToTeachers}) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/publish/$id');
    _log("POST Request to: $url");
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
          'send_to_parents': sendToParents,
          'send_to_teachers': sendToTeachers,
        }),
      ).timeout(const Duration(seconds: 15));

      _log("Publish Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      _log("Error in publishAnnouncement: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> unpublishAnnouncement(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/announcements/unpublish/$id');
    _log("POST Request to: $url");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Unpublish Response: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      _log("Error in unpublishAnnouncement: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }
}

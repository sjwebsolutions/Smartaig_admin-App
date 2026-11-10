import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/models/event_pass_application_model.dart';
import 'package:smart_aig_admins_app/models/event_pass_scan_model.dart';
import 'package:smart_aig_admins_app/models/event_search_student_model.dart';
import 'package:smart_aig_admins_app/models/event_today_scans_model.dart';
import 'package:smart_aig_admins_app/models/issue_walk_in_pass_model.dart';
import 'package:smart_aig_admins_app/models/update_pass_status_model.dart';

class EventService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  void _log(String message) {
    if (kDebugMode) {
      print("🚀 [EventService]: $message");
    }
  }

  Future<EventTodayScansModel> getTodayScans({
    int? eventId,
    String? gateName,
    bool? myScansOnly,
    int? limit,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, String> queryParams = {};
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (gateName != null && gateName.trim().isNotEmpty) {
      queryParams['gate_name'] = gateName.trim();
    }
    if (myScansOnly != null) queryParams['my_scans_only'] = myScansOnly.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/today-scans')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    _log("GET Request to: $url");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Response status: ${response.statusCode}");

      // Fallback if endpoint is under root /events/passes/today-scans
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/today-scans')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
        _log("404 received, trying fallback URL: $url");
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        _log("Fallback response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return EventTodayScansModel.fromJson(decoded);
      } else {
        _log("Error Response: ${response.body}");
        return EventTodayScansModel(
          success: false,
          message: "Failed to load today scans (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      _log("Exception in getTodayScans: $e");
      return EventTodayScansModel(
        success: false,
        message: "Network error. Please try again later.",
      );
    }
  }

  Future<EventPassScanModel> scanPass({
    String? qrPayload,
    String? gateName,
    String? qrCode,
    String? passNumber,
    String? token,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('token');

    final Map<String, dynamic> body = {};
    if (qrPayload != null && qrPayload.isNotEmpty) body['qr_payload'] = qrPayload;
    if (gateName != null && gateName.isNotEmpty) body['gate_name'] = gateName;
    if (qrCode != null && qrCode.isNotEmpty) body['qr_code'] = qrCode;
    if (passNumber != null && passNumber.isNotEmpty) body['pass_number'] = passNumber;
    if (token != null && token.isNotEmpty) body['token'] = token;

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/scan');
    _log("POST Request to: $url with body: ${jsonEncode(body)}");

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      _log("Scan response status: ${response.statusCode}");

      // Fallback
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/scan');
        _log("404 received, trying fallback URL: $url");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
        _log("Fallback scan response status: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      _log("Decoded scan response: $decoded");
      return EventPassScanModel.fromJson(decoded);
    } catch (e) {
      _log("Exception in scanPass: $e");
      return EventPassScanModel(
        success: false,
        message: "Failed to process pass scan: $e",
      );
    }
  }

  Future<ActiveEventsResponseModel> getActiveEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/active');
    _log("GET Request to: $url");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Active events response status: ${response.statusCode}");

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/active');
        _log("404 received, trying fallback URL: $url");
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        _log("Fallback active events response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return ActiveEventsResponseModel.fromJson(decoded);
      } else {
        _log("Error Response: ${response.body}");
        return ActiveEventsResponseModel(
          success: false,
          message: "Failed to load active events (Code: ${response.statusCode})",
          data: [],
        );
      }
    } catch (e) {
      _log("Exception in getActiveEvents: $e");
      return ActiveEventsResponseModel(
        success: false,
        message: "Network error. Please try again later.",
        data: [],
      );
    }
  }

  Future<EventSearchStudentsResponseModel> searchStudents({
    required int eventId,
    String? searchQuery,
    String? className,
    String? sectionName,
    String? passStatus,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, String> queryParams = {
      'event_id': eventId.toString(),
    };
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams['search'] = searchQuery.trim();
    }
    if (className != null && className.trim().isNotEmpty) {
      queryParams['class_name'] = className.trim();
    }
    if (sectionName != null && sectionName.trim().isNotEmpty) {
      queryParams['section_name'] = sectionName.trim();
    }
    if (passStatus != null && passStatus.trim().isNotEmpty) {
      queryParams['pass_status'] = passStatus.trim();
    }

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/search-students')
        .replace(queryParameters: queryParams);
    _log("GET Request to: $url");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Search students response status: ${response.statusCode}");

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/search-students')
            .replace(queryParameters: queryParams);
        _log("404 received, trying fallback URL: $url");
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        _log("Fallback search students response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return EventSearchStudentsResponseModel.fromJson(decoded);
      } else {
        _log("Error Response: ${response.body}");
        return EventSearchStudentsResponseModel(
          success: false,
          message: "Failed to search students (Code: ${response.statusCode})",
          data: [],
        );
      }
    } catch (e) {
      _log("Exception in searchStudents: $e");
      return EventSearchStudentsResponseModel(
        success: false,
        message: "Network error. Please try again later.",
        data: [],
      );
    }
  }

  Future<EventPassApplicationsResponseModel> getPassApplications({
    int? eventId,
    String? search,
    String? approvalStatus,
    String? checkinStatus,
    int? page,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, String> queryParams = {};
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (approvalStatus != null && approvalStatus.trim().isNotEmpty) {
      queryParams['approval_status'] = approvalStatus.trim();
      queryParams['status'] = approvalStatus.trim();
    }
    if (checkinStatus != null && checkinStatus.trim().isNotEmpty) {
      queryParams['checkin_status'] = checkinStatus.trim();
    }
    if (page != null) queryParams['page'] = page.toString();

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/applications')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
    _log("GET Request to: $url");

    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      _log("Pass applications response status: ${response.statusCode}");

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/applications')
            .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
        _log("404 received, trying fallback URL: $url");
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        _log("Fallback pass applications response status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return EventPassApplicationsResponseModel.fromJson(decoded);
      } else {
        _log("Error Response: ${response.body}");
        return EventPassApplicationsResponseModel(
          success: false,
          message: "Failed to load pass applications (Code: ${response.statusCode})",
          data: [],
        );
      }
    } catch (e) {
      _log("Exception in getPassApplications: $e");
      return EventPassApplicationsResponseModel(
        success: false,
        message: "Network error. Please try again later.",
        data: [],
      );
    }
  }

  Future<IssueWalkInPassResponseModel> issueWalkInPass({
    required int eventId,
    required int studentId,
    bool autoApprove = true,
    bool autoCheckin = true,
    String? gateName,
    String? remarks,
    required List<WalkInAttendeeInput> attendees,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/issue-walk-in');
    _log("POST Request to: $url");

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['event_id'] = eventId.toString();
      request.fields['student_id'] = studentId.toString();
      request.fields['auto_approve'] = autoApprove.toString();
      request.fields['auto_checkin'] = autoCheckin.toString();
      if (gateName != null && gateName.isNotEmpty) {
        request.fields['gate_name'] = gateName;
      }
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }
      request.fields['attendees'] = attendees.length.toString();

      for (int i = 0; i < attendees.length; i++) {
        final att = attendees[i];
        request.fields['attendees[$i][person_type]'] = att.personType;
        request.fields['attendees[$i][name]'] = att.name;
        if (att.mobileNo != null && att.mobileNo!.isNotEmpty) {
          request.fields['attendees[$i][mobile_no]'] = att.mobileNo!;
        }
        if (att.whatsappNo != null && att.whatsappNo!.isNotEmpty) {
          request.fields['attendees[$i][whatsapp_no]'] = att.whatsappNo!;
        }
        if (att.aadhaarNumber != null && att.aadhaarNumber!.isNotEmpty) {
          request.fields['attendees[$i][aadhaar_number]'] = att.aadhaarNumber!;
        }
        if (att.existingPhotoPath != null && att.existingPhotoPath!.isNotEmpty) {
          request.fields['attendees[$i][existing_photo_path]'] = att.existingPhotoPath!;
        }
        if (att.photoFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'attendees[$i][photo]',
              att.photoFile!.path,
            ),
          );
        }
      }

      var streamedResponse = await request.send().timeout(const Duration(seconds: 25));
      var response = await http.Response.fromStream(streamedResponse);

      _log("Issue walk-in pass response status: ${response.statusCode}");

      // Fallback
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/issue-walk-in');
        _log("404 received, trying fallback URL: $url");
        request = http.MultipartRequest('POST', url);
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
        request.fields['event_id'] = eventId.toString();
        request.fields['student_id'] = studentId.toString();
        request.fields['auto_approve'] = autoApprove.toString();
        request.fields['auto_checkin'] = autoCheckin.toString();
        if (gateName != null && gateName.isNotEmpty) {
          request.fields['gate_name'] = gateName;
        }
        if (remarks != null && remarks.isNotEmpty) {
          request.fields['remarks'] = remarks;
        }
        request.fields['attendees'] = attendees.length.toString();

        for (int i = 0; i < attendees.length; i++) {
          final att = attendees[i];
          request.fields['attendees[$i][person_type]'] = att.personType;
          request.fields['attendees[$i][name]'] = att.name;
          if (att.mobileNo != null && att.mobileNo!.isNotEmpty) {
            request.fields['attendees[$i][mobile_no]'] = att.mobileNo!;
          }
          if (att.whatsappNo != null && att.whatsappNo!.isNotEmpty) {
            request.fields['attendees[$i][whatsapp_no]'] = att.whatsappNo!;
          }
          if (att.aadhaarNumber != null && att.aadhaarNumber!.isNotEmpty) {
            request.fields['attendees[$i][aadhaar_number]'] = att.aadhaarNumber!;
          }
          if (att.existingPhotoPath != null && att.existingPhotoPath!.isNotEmpty) {
            request.fields['attendees[$i][existing_photo_path]'] = att.existingPhotoPath!;
          }
          if (att.photoFile != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'attendees[$i][photo]',
                att.photoFile!.path,
              ),
            );
          }
        }

        streamedResponse = await request.send().timeout(const Duration(seconds: 25));
        response = await http.Response.fromStream(streamedResponse);
        _log("Fallback issue walk-in pass response status: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      _log("Decoded issue walk-in pass response: $decoded");
      return IssueWalkInPassResponseModel.fromJson(decoded);
    } catch (e) {
      _log("Exception in issueWalkInPass: $e");
      return IssueWalkInPassResponseModel(
        success: false,
        message: "Failed to issue walk-in pass: $e",
      );
    }
  }

  Future<UpdatePassStatusResponseModel> updatePassStatus({
    int? passId,
    List<int>? passIds,
    required String action,
    String? remarks,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Map<String, dynamic> body = {
      'action': action,
    };
    if (passId != null) body['pass_id'] = passId;
    if (passIds != null && passIds.isNotEmpty) body['pass_ids'] = passIds;
    if (remarks != null && remarks.trim().isNotEmpty) body['remarks'] = remarks.trim();

    Uri url = Uri.parse('$baseUrl/admin-teacher/events/passes/update-status');
    _log("POST Request to: $url with body: ${jsonEncode(body)}");

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      _log("Update pass status response status: ${response.statusCode}");

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/events/passes/update-status');
        _log("404 received, trying fallback URL: $url");
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
        _log("Fallback update pass status response status: ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      _log("Decoded update pass status response: $decoded");
      return UpdatePassStatusResponseModel.fromJson(decoded);
    } catch (e) {
      _log("Exception in updatePassStatus: $e");
      return UpdatePassStatusResponseModel(
        success: false,
        message: "Failed to update pass status: $e",
        updatedIds: [],
      );
    }
  }
}

class WalkInAttendeeInput {
  final String personType;
  final String name;
  final String? mobileNo;
  final String? whatsappNo;
  final String? aadhaarNumber;
  final File? photoFile;
  final String? existingPhotoPath;

  WalkInAttendeeInput({
    required this.personType,
    required this.name,
    this.mobileNo,
    this.whatsappNo,
    this.aadhaarNumber,
    this.photoFile,
    this.existingPhotoPath,
  });
}

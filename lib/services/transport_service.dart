import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/transport_alerts_model.dart';
import 'package:smart_aig_admins_app/models/transport_halts_model.dart';
import 'package:smart_aig_admins_app/models/transport_live_overview_model.dart';
import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';

class TransportService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<TransportLocationRequestsResponse> getLocationRequests({String status = 'all'}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    // Try admin-teacher route first
    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/location-requests?status=$status');

    try {
      if (kDebugMode) {
        print("Fetching Transport Location Requests from: $url");
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Transport Location Requests Status Code: ${response.statusCode}");
        print("Transport Location Requests Response: ${response.body}");
      }

      // Fallback to direct path if 404
      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/location-requests?status=$status');
        if (kDebugMode) {
          print("Retrying with fallback url: $url");
        }
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return TransportLocationRequestsResponse(
            success: true,
            data: TransportLocationData.fromJson(decoded),
          );
        } else if (decoded is Map<String, dynamic>) {
          return TransportLocationRequestsResponse.fromJson(decoded);
        } else {
          return TransportLocationRequestsResponse(
            success: false,
            message: "Invalid response format",
          );
        }
      } else {
        if (kDebugMode) {
          print("Transport API Failed: ${response.statusCode}");
        }
        return TransportLocationRequestsResponse(
          success: false,
          message: "Server returned status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transport location requests: $e");
      }
      return TransportLocationRequestsResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> getLocationRequestDetails(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/location-requests/$id');

    try {
      if (kDebugMode) {
        print("Fetching Location Request $id Details from: $url");
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/location-requests/$id');
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return {'success': false, 'message': 'Failed to load details'};
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching location request details: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> approveLocationRequest(int id, {String? remarks}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/location-requests/$id/approve');

    try {
      if (kDebugMode) {
        print("Approving Transport Location Request $id at: $url");
      }

      final Map<String, dynamic> body = {};
      if (remarks != null && remarks.trim().isNotEmpty) {
        body['remarks'] = remarks.trim();
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Approve Location Request Status Code: ${response.statusCode}");
        print("Approve Location Request Response: ${response.body}");
      }

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/location-requests/$id/approve');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': resData['success'] ?? true,
          'message': resData['message'] ?? 'Location request approved successfully.',
        };
      } else {
        return {
          'success': false,
          'message': resData['message'] ?? 'Failed to approve request (${response.statusCode})',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error approving location request: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rejectLocationRequest(int id, {required String rejectionReason}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/location-requests/$id/reject');

    try {
      if (kDebugMode) {
        print("Rejecting Transport Location Request $id at: $url");
      }

      final Map<String, dynamic> body = {
        'rejection_reason': rejectionReason.trim(),
        'reason': rejectionReason.trim(),
      };

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Reject Location Request Status Code: ${response.statusCode}");
        print("Reject Location Request Response: ${response.body}");
      }

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/location-requests/$id/reject');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': resData['success'] ?? true,
          'message': resData['message'] ?? 'Location request rejected successfully.',
        };
      } else {
        return {
          'success': false,
          'message': resData['message'] ?? 'Failed to reject request (${response.statusCode})',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error rejecting location request: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<TransportHaltsResponse> getTransportHalts({
    String status = 'all',
    int? busId,
    int? tripId,
    String? date,
    int page = 1,
    int perPage = 20,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final queryParams = <String, String>{
      'status': status,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (busId != null) queryParams['bus_id'] = busId.toString();
    if (tripId != null) queryParams['trip_id'] = tripId.toString();
    if (date != null && date.trim().isNotEmpty) queryParams['date'] = date.trim();

    final queryString = Uri(queryParameters: queryParams).query;
    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/halts?$queryString');

    try {
      if (kDebugMode) {
        print("Fetching Transport Halts from: $url");
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Transport Halts Status Code: ${response.statusCode}");
        print("Transport Halts Response: ${response.body}");
      }

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/halts?$queryString');
        if (kDebugMode) {
          print("Retrying with fallback url: $url");
        }
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return TransportHaltsResponse.fromJson(decoded);
        } else {
          return TransportHaltsResponse(
            success: false,
            message: "Invalid response format",
          );
        }
      } else {
        if (kDebugMode) {
          print("Transport Halts API Failed: ${response.statusCode}");
        }
        return TransportHaltsResponse(
          success: false,
          message: "Server returned status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transport halts: $e");
      }
      return TransportHaltsResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<TransportAlertsResponse> getTransportAlerts({
    String status = 'unresolved',
    String severity = 'all',
    String alertType = 'all',
    int? busId,
    int page = 1,
    int perPage = 20,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final queryParams = <String, String>{
      'status': status,
      'severity': severity,
      'alert_type': alertType,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (busId != null) queryParams['bus_id'] = busId.toString();

    final queryString = Uri(queryParameters: queryParams).query;
    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/alerts?$queryString');

    try {
      if (kDebugMode) {
        print("Fetching Transport Alerts from: $url");
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Transport Alerts Status Code: ${response.statusCode}");
        print("Transport Alerts Response: ${response.body}");
      }

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/alerts?$queryString');
        if (kDebugMode) {
          print("Retrying with fallback url: $url");
        }
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return TransportAlertsResponse.fromJson(decoded);
        } else {
          return TransportAlertsResponse(
            success: false,
            message: "Invalid response format",
          );
        }
      } else {
        if (kDebugMode) {
          print("Transport Alerts API Failed: ${response.statusCode}");
        }
        return TransportAlertsResponse(
          success: false,
          message: "Server returned status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transport alerts: $e");
      }
      return TransportAlertsResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> resolveTransportAlert(int alertId, {String? resolutionNotes}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/alerts/$alertId/resolve');

    try {
      if (kDebugMode) {
        print("Resolving Transport Alert $alertId at: $url");
      }

      final Map<String, dynamic> body = {};
      if (resolutionNotes != null && resolutionNotes.trim().isNotEmpty) {
        body['resolution_notes'] = resolutionNotes.trim();
        body['notes'] = resolutionNotes.trim();
      }

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/alerts/$alertId/resolve');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }

      final resData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': resData['success'] ?? true,
          'message': resData['message'] ?? 'Alert resolved successfully.',
        };
      } else {
        return {
          'success': false,
          'message': resData['message'] ?? 'Failed to resolve alert (${response.statusCode})',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error resolving transport alert: $e");
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<TransportLiveOverviewResponse> getLiveOverview() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    Uri url = Uri.parse('$baseUrl/admin-teacher/transport/live-overview');

    try {
      if (kDebugMode) {
        print("Fetching Transport Live Overview from: $url");
      }

      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("Transport Live Overview Status Code: ${response.statusCode}");
        print("Transport Live Overview Response: ${response.body}");
      }

      if (response.statusCode == 404) {
        url = Uri.parse('$baseUrl/transport/live-overview');
        if (kDebugMode) {
          print("Retrying with fallback url: $url");
        }
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return TransportLiveOverviewResponse.fromJson(decoded);
        } else {
          return TransportLiveOverviewResponse(
            success: false,
            message: "Invalid response format",
          );
        }
      } else {
        if (kDebugMode) {
          print("Transport Live Overview API Failed: ${response.statusCode}");
        }
        return TransportLiveOverviewResponse(
          success: false,
          message: "Server returned status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching transport live overview: $e");
      }
      return TransportLiveOverviewResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/meeting_model.dart';

class MeetingService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<MeetingResponse> getMeetings() async {
    final url = Uri.parse('$baseUrl/admin-teacher/meetings');
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

      if (response.statusCode == 200) {
        return MeetingResponse.fromJson(jsonDecode(response.body));
      } else {
        return MeetingResponse(success: false, data: []);
      }
    } catch (e) {
      print("DEBUG: Meeting API Exception: $e");
      return MeetingResponse(success: false, data: []);
    }
  }
}

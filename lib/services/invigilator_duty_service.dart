import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_model.dart';

class InvigilatorDutyService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<InvigilatorDutyResponse> getInvigilatorDuties() async {
    final url = Uri.parse('$baseUrl/admin-teacher/invigilator-duties');
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
        return InvigilatorDutyResponse.fromJson(jsonDecode(response.body));
      } else {
        return InvigilatorDutyResponse(success: false, data: []);
      }
    } catch (e) {
      print("DEBUG: Invigilator Duty API Exception: $e");
      return InvigilatorDutyResponse(success: false, data: []);
    }
  }
}

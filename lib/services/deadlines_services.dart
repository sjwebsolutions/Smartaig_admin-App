import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/deadlines_model.dart';

class DeadlinesService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<DeadlinesModel> getDeadlines() async {
    final url = Uri.parse('$baseUrl/admin-teacher/deadlines');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    print("DEBUG: Fetching Deadlines from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print("DEBUG: Deadlines API Status Code: ${response.statusCode}");
      print("DEBUG: Deadlines API Response: ${response.body}");

      if (response.statusCode == 200) {
        return DeadlinesModel.fromJson(jsonDecode(response.body));
      } else {
        print("DEBUG: Deadlines API Failed with status: ${response.statusCode}");
        return DeadlinesModel(success: false);
      }
    } catch (e) {
      print("DEBUG: Deadlines API Exception: $e");
      return DeadlinesModel(success: false);
    }
  }
}

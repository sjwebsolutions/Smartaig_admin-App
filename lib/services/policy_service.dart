import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/policy_model.dart';

class PolicyService {
  static const String baseUrl = "https://smartaig.com/api/v1/admin-teacher";

  Future<PolicyModel?> getPolicy() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse("$baseUrl/policies"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        return PolicyModel.fromJson(jsonData);
      } else {
        print("Policy API Error: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("Policy Service Error: $e");
      return null;
    }
  }
}
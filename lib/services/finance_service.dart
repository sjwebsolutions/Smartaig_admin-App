import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/finance_statistics_model.dart';

class FinanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<FinanceStatisticsModel> getFinanceStatistics() async {
    final url = Uri.parse('$baseUrl/admin-teacher/finance/statistics');
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
        return FinanceStatisticsModel.fromJson(jsonDecode(response.body));
      } else {
        return FinanceStatisticsModel(success: false);
      }
    } catch (e) {
      print("Error fetching finance stats: $e");
      return FinanceStatisticsModel(success: false);
    }
  }
}

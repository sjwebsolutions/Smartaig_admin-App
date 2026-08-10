import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/billing_model.dart';

class BillingService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<BillingModel> getBillings() async {
    final url = Uri.parse('$baseUrl/admin-teacher/billings');
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
        return BillingModel.fromJson(jsonDecode(response.body));
      } else {
        return BillingModel(success: false, data: []);
      }
    } catch (e) {
      return BillingModel(success: false, data: []);
    }
  }

  Future<http.Response> getInvoice(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/billings/$id/invoice');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 15));
  }
}

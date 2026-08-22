import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/admission_enquiry_model.dart';
import 'package:smart_aig_admins_app/models/admission_detail_model.dart';

class AdmissionService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<AdmissionEnquiryModel> getEnquiries() async {
    final url = Uri.parse('$baseUrl/admin-teacher/admission-enquiries');
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

      print("Admission Enquiries API Response: ${response.body}");

      if (response.statusCode == 200) {
        return AdmissionEnquiryModel.fromJson(jsonDecode(response.body));
      } else {
        return AdmissionEnquiryModel(success: false, data: []);
      }
    } catch (e) {
      print("Error fetching admission enquiries: $e");
      return AdmissionEnquiryModel(success: false, data: []);
    }
  }

  Future<AdmissionDetailModel> getEnquiryDetails(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/admission-enquiries/$id');
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

      print("Admission Enquiry Detail API Response: ${response.body}");

      if (response.statusCode == 200) {
        return AdmissionDetailModel.fromJson(jsonDecode(response.body));
      } else {
        return AdmissionDetailModel(success: false);
      }
    } catch (e) {
      print("Error fetching admission enquiry detail: $e");
      return AdmissionDetailModel(success: false);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/banner_model.dart';
import 'package:smart_aig_admins_app/models/banner_classes_model.dart';

class BannerService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<BannerClassesResponse> getBannerClasses() async {
    final url = Uri.parse('$baseUrl/admin-teacher/banners/classes');
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
        return BannerClassesResponse.fromJson(jsonDecode(response.body));
      } else {
        return BannerClassesResponse(success: false);
      }
    } catch (e) {
      return BannerClassesResponse(success: false);
    }
  }

  Future<BannerResponseModel> getBanners() async {
    final url = Uri.parse('$baseUrl/admin-teacher/banners/published');
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
        return BannerResponseModel.fromJson(jsonDecode(response.body));
      } else {
        return BannerResponseModel(
          success: false,
        );
      }
    } catch (e) {
      return BannerResponseModel(
        success: false,
      );
    }
  }

  Future<Map<String, dynamic>> publishBanner({
    required int id,
    required int audienceParents,
    required int audienceTeachers,
    required String targetType,
    List<int>? classIds,
    required int displayDays,
  }) async {
    final url = Uri.parse('$baseUrl/admin-teacher/banners/publish');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final body = {
      "id": id,
      "audience_parents": audienceParents,
      "audience_teachers": audienceTeachers,
      "target_type": targetType,
      if (classIds != null) "class_ids": classIds,
      "display_days": displayDays,
    };

    print("🚀 [Banner Publish Request Body]: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print("✅ [Banner Publish Response]: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("❌ [Banner Publish Error]: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> toggleBannerStatus(int id) async {
    final url = Uri.parse('$baseUrl/admin-teacher/banners/published/$id/toggle-status');
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

      print("🔄 [Banner Toggle Status Response]: ${response.body}");
      return jsonDecode(response.body);
    } catch (e) {
      print("❌ [Banner Toggle Status Error]: $e");
      return {
        'success': false,
        'message': "Error occurred: $e",
      };
    }
  }
}

import 'package:smart_aig_admins_app/models/dashboard_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

class AuthData {
  final String token;
  final String activeSession;
  final UserModel teacher;

  AuthData({
    required this.token,
    required this.activeSession,
    required this.teacher,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      activeSession: json['active_session'] ?? '',
      teacher: UserModel.fromJson(json['teacher']),
    );
  }
}

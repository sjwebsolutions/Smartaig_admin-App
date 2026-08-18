class SupportSettingsModel {
  final bool success;
  final SupportData? data;

  SupportSettingsModel({
    required this.success,
    this.data,
  });

  factory SupportSettingsModel.fromJson(Map<String, dynamic> json) {
    return SupportSettingsModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? SupportData.fromJson(json['data']) : null,
    );
  }
}

class SupportData {
  final String name;
  final String whatsapp;
  final String mobile;
  final String email;

  SupportData({
    required this.name,
    required this.whatsapp,
    required this.mobile,
    required this.email,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      name: json['name'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

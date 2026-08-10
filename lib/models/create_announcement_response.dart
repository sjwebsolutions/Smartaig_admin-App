class CreateAnnouncementResponse {
  final bool success;
  final String message;
  final CreateAnnouncementData? data;

  CreateAnnouncementResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateAnnouncementResponse.fromJson(Map<String, dynamic> json) {
    return CreateAnnouncementResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CreateAnnouncementData.fromJson(json['data']) : null,
    );
  }
}

class CreateAnnouncementData {
  final int id;

  CreateAnnouncementData({required this.id});

  factory CreateAnnouncementData.fromJson(Map<String, dynamic> json) {
    return CreateAnnouncementData(
      id: json['id'] ?? 0,
    );
  }
}

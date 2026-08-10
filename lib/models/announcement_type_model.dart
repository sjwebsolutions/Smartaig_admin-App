class AnnouncementTypeResponse {
  final bool success;
  final List<AnnouncementType>? data;
  final String? message;

  AnnouncementTypeResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory AnnouncementTypeResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementTypeResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => AnnouncementType.fromJson(i)).toList()
          : null,
    );
  }
}

class AnnouncementType {
  final int id;
  final String name;

  AnnouncementType({
    required this.id,
    required this.name,
  });

  factory AnnouncementType.fromJson(Map<String, dynamic> json) {
    return AnnouncementType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

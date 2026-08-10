class AnnouncementDetailResponse {
  final bool success;
  final AnnouncementDetail? data;
  final String? message;

  AnnouncementDetailResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory AnnouncementDetailResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetailResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? AnnouncementDetail.fromJson(json['data']) : null,
    );
  }
}

class AnnouncementDetail {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final int typeId;
  final String fromDate;
  final String? fromTime;
  final String toDate;
  final String? toTime;
  final String targetType;
  final List<dynamic> targets;
  final String submitStatus;
  final String publishStatus;
  final int sendToParents;
  final int sendToTeachers;

  AnnouncementDetail({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.typeId,
    required this.fromDate,
    this.fromTime,
    required this.toDate,
    this.toTime,
    required this.targetType,
    required this.targets,
    required this.submitStatus,
    required this.publishStatus,
    required this.sendToParents,
    required this.sendToTeachers,
  });

  factory AnnouncementDetail.fromJson(Map<String, dynamic> json) {
    return AnnouncementDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      typeId: json['type_id'] ?? 0,
      fromDate: json['from_date'] ?? '',
      fromTime: json['from_time'],
      toDate: json['to_date'] ?? '',
      toTime: json['to_time'],
      targetType: json['target_type'] ?? '',
      targets: List<dynamic>.from(json['targets'] ?? []),
      submitStatus: json['submit_status'] ?? '',
      publishStatus: json['publish_status'] ?? '',
      sendToParents: json['send_to_parents'] ?? 0,
      sendToTeachers: json['send_to_teachers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'type_id': typeId,
      'from_date': fromDate,
      'from_time': fromTime,
      'to_date': toDate,
      'to_time': toTime,
      'target_type': targetType,
      'targets': targets,
      'submit_status': submitStatus,
      'publish_status': publishStatus,
      'send_to_parents': sendToParents,
      'send_to_teachers': sendToTeachers,
    };
  }
}

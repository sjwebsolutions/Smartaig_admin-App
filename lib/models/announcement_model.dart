class AnnouncementResponseModel {
  final bool success;
  final List<Announcement>? data;
  final String? message;

  AnnouncementResponseModel({
    required this.success,
    this.data,
    this.message,
  });

  factory AnnouncementResponseModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Announcement.fromJson(i)).toList()
          : null,
    );
  }
}

class Announcement {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String type;
  final String fromDate;
  final String? fromTime;
  final String toDate;
  final String? toTime;
  final int status;
  final String submitStatus;
  final String publishStatus;
  final int sendToParents;
  final int sendToTeachers;
  final String targetsSummary;
  final String createdBy;
  final bool isEditable;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.fromDate,
    this.fromTime,
    required this.toDate,
    this.toTime,
    required this.status,
    required this.submitStatus,
    required this.publishStatus,
    required this.sendToParents,
    required this.sendToTeachers,
    required this.targetsSummary,
    required this.createdBy,
    required this.isEditable,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      type: json['type'] ?? '',
      fromDate: json['from_date'] ?? '',
      fromTime: json['from_time'],
      toDate: json['to_date'] ?? '',
      toTime: json['to_time'],
      status: json['status'] ?? 0,
      submitStatus: json['submit_status'] ?? '',
      publishStatus: json['publish_status'] ?? '',
      sendToParents: json['send_to_parents'] ?? 0,
      sendToTeachers: json['send_to_teachers'] ?? 0,
      targetsSummary: json['targets_summary'] ?? '',
      createdBy: json['created_by'] ?? '',
      isEditable: json['is_editable'] ?? false,
    );
  }
}

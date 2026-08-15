class HomeworkStatusModel {
  final bool success;
  final HomeworkData? data;

  HomeworkStatusModel({
    required this.success,
    this.data,
  });

  factory HomeworkStatusModel.fromJson(Map<String, dynamic> json) {
    return HomeworkStatusModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? HomeworkData.fromJson(json['data']) : null,
    );
  }
}

class HomeworkData {
  final String uploadMode;
  final String date;
  final List<HomeworkStatusItem> statusData;

  HomeworkData({
    required this.uploadMode,
    required this.date,
    required this.statusData,
  });

  factory HomeworkData.fromJson(Map<String, dynamic> json) {
    return HomeworkData(
      uploadMode: json['upload_mode'] ?? '',
      date: json['date'] ?? '',
      statusData: (json['status_data'] as List? ?? [])
          .map((i) => HomeworkStatusItem.fromJson(i))
          .toList(),
    );
  }
}

class HomeworkStatusItem {
  final String className;
  final String teacher;
  final String subject;
  final String status;
  final String uploadedAt;
  final String uploadedBy;
  final String updatedBy;
  final bool isDiary;

  HomeworkStatusItem({
    required this.className,
    required this.teacher,
    required this.subject,
    required this.status,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.updatedBy,
    required this.isDiary,
  });

  factory HomeworkStatusItem.fromJson(Map<String, dynamic> json) {
    return HomeworkStatusItem(
      className: json['class_name'] ?? '',
      teacher: json['teacher'] ?? '',
      subject: json['subject'] ?? '',
      status: json['status'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      isDiary: json['is_diary'] ?? false,
    );
  }
}

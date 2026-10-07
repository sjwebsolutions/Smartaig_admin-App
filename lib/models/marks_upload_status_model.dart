class MarksUploadStatusModel {
  final bool success;
  final List<MarksUploadStatusItem> data;

  MarksUploadStatusModel({
    required this.success,
    required this.data,
  });

  factory MarksUploadStatusModel.fromJson(Map<String, dynamic> json) {
    return MarksUploadStatusModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => MarksUploadStatusItem.fromJson(i))
          .toList(),
    );
  }
}

class MarksUploadStatusItem {
  final String teacher;
  final String subject;
  final String section;
  final int total;
  final int uploaded;
  final int pending;
  final String status;
  final bool isMisc;

  MarksUploadStatusItem({
    required this.teacher,
    required this.subject,
    required this.section,
    required this.total,
    required this.uploaded,
    required this.pending,
    required this.status,
    required this.isMisc,
  });

  // Compatibility getters
  String get subjectName => subject;
  String get teacherName => teacher;
  String get date => '';

  factory MarksUploadStatusItem.fromJson(Map<String, dynamic> json) {
    return MarksUploadStatusItem(
      teacher: json['teacher']?.toString() ?? json['teacher_name']?.toString() ?? 'N/A',
      subject: json['subject']?.toString() ?? json['subject_name']?.toString() ?? 'N/A',
      section: json['section']?.toString() ?? '',
      total: _parseInt(json['total']),
      uploaded: _parseInt(json['uploaded']),
      pending: _parseInt(json['pending']),
      status: json['status']?.toString() ?? 'Pending',
      isMisc: json['is_misc'] is bool
          ? json['is_misc']
          : (json['is_misc']?.toString().toLowerCase() == 'true' || json['is_misc']?.toString() == '1'),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

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
  final String subjectName;
  final String status;
  final String teacherName;
  final String date;

  MarksUploadStatusItem({
    required this.subjectName,
    required this.status,
    required this.teacherName,
    required this.date,
  });

  factory MarksUploadStatusItem.fromJson(Map<String, dynamic> json) {
    return MarksUploadStatusItem(
      subjectName: json['subject_name'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      teacherName: json['teacher_name'] ?? 'N/A',
      date: json['date'] ?? '',
    );
  }
}

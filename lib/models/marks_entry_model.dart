class MarksEntryModel {
  final bool success;
  final List<ExamData> data;

  MarksEntryModel({
    required this.success,
    required this.data,
  });

  factory MarksEntryModel.fromJson(Map<String, dynamic> json) {
    return MarksEntryModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => ExamData.fromJson(i))
          .toList(),
    );
  }
}

class ExamData {
  final int id;
  final String title;
  final String session;

  ExamData({
    required this.id,
    required this.title,
    required this.session,
  });

  factory ExamData.fromJson(Map<String, dynamic> json) {
    return ExamData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      session: json['session'] ?? '',
    );
  }
}

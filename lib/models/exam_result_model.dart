class ExamResultModel {
  final bool success;
  final List<ExamResultData> data;

  ExamResultModel({
    required this.success,
    required this.data,
  });

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    return ExamResultModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => ExamResultData.fromJson(i))
          .toList(),
    );
  }
}

class ExamResultData {
  final int id;
  final String title;
  final String session;

  ExamResultData({
    required this.id,
    required this.title,
    required this.session,
  });

  factory ExamResultData.fromJson(Map<String, dynamic> json) {
    return ExamResultData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      session: json['session'] ?? '',
    );
  }
}

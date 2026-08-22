class ExamResultSummaryModel {
  final bool success;
  final List<ExamResultSummaryItem> data;

  ExamResultSummaryModel({
    required this.success,
    required this.data,
  });

  factory ExamResultSummaryModel.fromJson(Map<String, dynamic> json) {
    return ExamResultSummaryModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => ExamResultSummaryItem.fromJson(i))
          .toList(),
    );
  }
}

class ExamResultSummaryItem {
  final String studentName;
  final String admissionNo;
  final String totalMarks;
  final String obtainedMarks;
  final String percentage;
  final String grade;
  final String resultStatus;

  ExamResultSummaryItem({
    required this.studentName,
    required this.admissionNo,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.percentage,
    required this.grade,
    required this.resultStatus,
  });

  factory ExamResultSummaryItem.fromJson(Map<String, dynamic> json) {
    return ExamResultSummaryItem(
      studentName: json['student_name'] ?? 'N/A',
      admissionNo: json['admission_no'] ?? 'N/A',
      totalMarks: json['total_marks']?.toString() ?? '0',
      obtainedMarks: json['obtained_marks']?.toString() ?? '0',
      percentage: json['percentage']?.toString() ?? '0%',
      grade: json['grade'] ?? 'N/A',
      resultStatus: json['result_status'] ?? 'N/A',
    );
  }
}

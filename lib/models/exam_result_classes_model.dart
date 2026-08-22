class ExamResultClassesModel {
  final bool success;
  final List<ClassData> data;

  ExamResultClassesModel({
    required this.success,
    required this.data,
  });

  factory ExamResultClassesModel.fromJson(Map<String, dynamic> json) {
    return ExamResultClassesModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => ClassData.fromJson(i))
          .toList(),
    );
  }
}

class ClassData {
  final int id;
  final String name;

  ClassData({
    required this.id,
    required this.name,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

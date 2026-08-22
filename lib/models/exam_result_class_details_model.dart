class ExamResultClassDetailsModel {
  final bool success;
  final ClassDetailsData? data;

  ExamResultClassDetailsModel({
    required this.success,
    this.data,
  });

  factory ExamResultClassDetailsModel.fromJson(Map<String, dynamic> json) {
    return ExamResultClassDetailsModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? ClassDetailsData.fromJson(json['data']) : null,
    );
  }
}

class ClassDetailsData {
  final List<SectionData> sections;
  final List<StreamData> streams;

  ClassDetailsData({
    required this.sections,
    required this.streams,
  });

  factory ClassDetailsData.fromJson(Map<String, dynamic> json) {
    return ClassDetailsData(
      sections: (json['sections'] as List? ?? [])
          .map((i) => SectionData.fromJson(i))
          .toList(),
      streams: (json['streams'] as List? ?? [])
          .map((i) => StreamData.fromJson(i))
          .toList(),
    );
  }
}

class SectionData {
  final int id;
  final String name;

  SectionData({
    required this.id,
    required this.name,
  });

  factory SectionData.fromJson(Map<String, dynamic> json) {
    return SectionData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StreamData {
  final int id;
  final String name;

  StreamData({
    required this.id,
    required this.name,
  });

  factory StreamData.fromJson(Map<String, dynamic> json) {
    return StreamData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

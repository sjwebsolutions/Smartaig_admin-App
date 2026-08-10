class TargetingDataResponse {
  final bool success;
  final TargetingData? data;
  final String? message;

  TargetingDataResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory TargetingDataResponse.fromJson(Map<String, dynamic> json) {
    return TargetingDataResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? TargetingData.fromJson(json['data']) : null,
    );
  }
}

class TargetingData {
  final List<ClassModel> classes;
  final List<StreamModel> streams;
  final List<SectionModel> sections;

  TargetingData({
    required this.classes,
    required this.streams,
    required this.sections,
  });

  factory TargetingData.fromJson(Map<String, dynamic> json) {
    return TargetingData(
      classes: json['classes'] != null
          ? (json['classes'] as List).map((i) => ClassModel.fromJson(i)).toList()
          : [],
      streams: json['streams'] != null
          ? (json['streams'] as List).map((i) => StreamModel.fromJson(i)).toList()
          : [],
      sections: json['sections'] != null
          ? (json['sections'] as List).map((i) => SectionModel.fromJson(i)).toList()
          : [],
    );
  }
}

class ClassModel {
  final int id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class StreamModel {
  final int id;
  final String name;

  StreamModel({required this.id, required this.name});

  factory StreamModel.fromJson(Map<String, dynamic> json) {
    return StreamModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SectionModel {
  final int id;
  final String name;

  SectionModel({required this.id, required this.name});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

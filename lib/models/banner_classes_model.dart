class BannerClassesResponse {
  final bool success;
  final List<BannerClass>? classes;

  BannerClassesResponse({
    required this.success,
    this.classes,
  });

  factory BannerClassesResponse.fromJson(Map<String, dynamic> json) {
    return BannerClassesResponse(
      success: json['success'] ?? false,
      classes: json['classes'] != null
          ? (json['classes'] as List).map((i) => BannerClass.fromJson(i)).toList()
          : null,
    );
  }
}

class BannerClass {
  final int id;
  final String name;

  BannerClass({
    required this.id,
    required this.name,
  });

  factory BannerClass.fromJson(Map<String, dynamic> json) {
    return BannerClass(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

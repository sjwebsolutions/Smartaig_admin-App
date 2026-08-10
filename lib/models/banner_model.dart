class BannerResponseModel {
  final bool success;
  final List<BannerModel>? publishedBanners;

  BannerResponseModel({
    required this.success,
    this.publishedBanners,
  });

  factory BannerResponseModel.fromJson(Map<String, dynamic> json) {
    return BannerResponseModel(
      success: json['success'] ?? false,
      publishedBanners: json['published_banners'] != null
          ? (json['published_banners'] as List).map((i) => BannerModel.fromJson(i)).toList()
          : null,
    );
  }
}

class BannerModel {
  final int id;
  final String bannerName;
  final String category;
  final String type;
  final String imageUrl;
  final List<String> targetedAudiences;
  final String targetType;
  final List<dynamic> targetedClassIds;
  final String targetScope;
  final int displayDays;
  final String publishedAt;
  final int status;

  BannerModel({
    required this.id,
    required this.bannerName,
    required this.category,
    required this.type,
    required this.imageUrl,
    required this.targetedAudiences,
    required this.targetType,
    required this.targetedClassIds,
    required this.targetScope,
    required this.displayDays,
    required this.publishedAt,
    required this.status,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      bannerName: json['banner_name'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      targetedAudiences: json['targeted_audiences'] != null 
          ? List<String>.from(json['targeted_audiences']) 
          : [],
      targetType: json['target_type'] ?? '',
      targetedClassIds: json['targeted_class_ids'] != null 
          ? List<dynamic>.from(json['targeted_class_ids']) 
          : [],
      targetScope: json['target_scope'] ?? '',
      displayDays: json['display_days'] ?? 0,
      publishedAt: json['published_at'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

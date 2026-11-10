class ActiveEventsResponseModel {
  final bool success;
  final String? message;
  final List<ActiveEventModel> data;

  ActiveEventsResponseModel({
    required this.success,
    this.message,
    required this.data,
  });

  factory ActiveEventsResponseModel.fromJson(Map<String, dynamic> json) {
    return ActiveEventsResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ActiveEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ActiveEventModel {
  final int id;
  final String eventCode;
  final String title;
  final String? subTitle;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? registrationDeadline;
  final int maxGuestsPerStudent;
  final bool requiresApproval;
  final bool requireAadhaar;
  final bool requirePhoto;
  final bool allowMultipleCheckins;
  final String? bannerUrl;
  final LiveTelecastModel? liveTelecast;

  ActiveEventModel({
    required this.id,
    required this.eventCode,
    required this.title,
    this.subTitle,
    this.venue,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.registrationDeadline,
    this.maxGuestsPerStudent = 0,
    this.requiresApproval = false,
    this.requireAadhaar = false,
    this.requirePhoto = false,
    this.allowMultipleCheckins = false,
    this.bannerUrl,
    this.liveTelecast,
  });

  factory ActiveEventModel.fromJson(Map<String, dynamic> json) {
    return ActiveEventModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      eventCode: json['event_code'] ?? '',
      title: json['title'] ?? '',
      subTitle: json['sub_title'],
      venue: json['venue'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      registrationDeadline: json['registration_deadline'],
      maxGuestsPerStudent: json['max_guests_per_student'] is int
          ? json['max_guests_per_student']
          : int.tryParse(json['max_guests_per_student']?.toString() ?? '0') ?? 0,
      requiresApproval: json['requires_approval'] ?? false,
      requireAadhaar: json['require_aadhaar'] ?? false,
      requirePhoto: json['require_photo'] ?? false,
      allowMultipleCheckins: json['allow_multiple_checkins'] ?? false,
      bannerUrl: json['banner_url'],
      liveTelecast: json['live_telecast'] != null
          ? LiveTelecastModel.fromJson(
              json['live_telecast'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_code': eventCode,
      'title': title,
      'sub_title': subTitle,
      'venue': venue,
      'start_date': startDate,
      'end_date': endDate,
      'start_time': startTime,
      'end_time': endTime,
      'registration_deadline': registrationDeadline,
      'max_guests_per_student': maxGuestsPerStudent,
      'requires_approval': requiresApproval,
      'require_aadhaar': requireAadhaar,
      'require_photo': requirePhoto,
      'allow_multiple_checkins': allowMultipleCheckins,
      'banner_url': bannerUrl,
      'live_telecast': liveTelecast?.toJson(),
    };
  }
}

class LiveTelecastModel {
  final bool isLive;
  final String? youtubeUrl;
  final String? youtubeVideoId;
  final String? embedUrl;
  final String? title;
  final String? startedAt;
  final String? endedAt;

  LiveTelecastModel({
    this.isLive = false,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.embedUrl,
    this.title,
    this.startedAt,
    this.endedAt,
  });

  factory LiveTelecastModel.fromJson(Map<String, dynamic> json) {
    return LiveTelecastModel(
      isLive: json['is_live'] ?? false,
      youtubeUrl: json['youtube_url'],
      youtubeVideoId: json['youtube_video_id'],
      embedUrl: json['embed_url'],
      title: json['title'],
      startedAt: json['started_at'],
      endedAt: json['ended_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_live': isLive,
      'youtube_url': youtubeUrl,
      'youtube_video_id': youtubeVideoId,
      'embed_url': embedUrl,
      'title': title,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }
}

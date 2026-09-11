class SyllabusResponseModel {
  final bool success;
  final List<Syllabus>? data;

  SyllabusResponseModel({
    required this.success,
    this.data,
  });

  factory SyllabusResponseModel.fromJson(Map<String, dynamic> json) {
    return SyllabusResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Syllabus.fromJson(i)).toList()
          : null,
    );
  }
}

class Syllabus {
  final int id;
  final String title;
  final String description;
  final String session;
  final String? term;
  final String? subject;
  final String? content;
  final String? fileUrl;
  final List<Attachment>? attachments;
  final String targetAudience;
  final String uploadedBy;
  final String uploadedAt;

  Syllabus({
    required this.id,
    required this.title,
    required this.description,
    required this.session,
    this.term,
    this.subject,
    this.content,
    this.fileUrl,
    this.attachments,
    required this.targetAudience,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) {
    return Syllabus(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      session: json['session'] ?? '',
      term: json['term'],
      subject: json['subject'],
      content: json['content'],
      fileUrl: json['file_url'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((i) => Attachment.fromJson(i))
              .toList()
          : null,
      targetAudience: json['target_audience'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

class Attachment {
  final String title;
  final String url;
  final String ext;
  final bool isImage;

  Attachment({
    required this.title,
    required this.url,
    required this.ext,
    required this.isImage,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      ext: json['ext'] ?? '',
      isImage: json['is_image'] ?? false,
    );
  }
}

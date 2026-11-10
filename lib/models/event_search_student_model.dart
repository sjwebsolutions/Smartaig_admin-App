class EventSearchStudentsResponseModel {
  final bool success;
  final String? message;
  final List<EventSearchStudentModel> data;
  final int totalCount;

  EventSearchStudentsResponseModel({
    required this.success,
    this.message,
    required this.data,
    this.totalCount = 0,
  });

  factory EventSearchStudentsResponseModel.fromJson(Map<String, dynamic> json) {
    return EventSearchStudentsResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => EventSearchStudentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class EventSearchStudentModel {
  final int id;
  final String studentName;
  final String admissionNumber;
  final String? rollNo;
  final String? studentUniqueId;
  final String? className;
  final String? sectionName;
  final String? streamName;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherName;
  final String? motherMobile;
  final String? whatsappNo;
  final String? studentAadhaar;
  final String? fatherAadhaar;
  final String? motherAadhaar;
  final String? studentPhotoUrl;
  final String? studentPhotoPath;
  final String? fatherPhotoUrl;
  final String? fatherPhotoPath;
  final String? motherPhotoUrl;
  final String? motherPhotoPath;
  final bool passExists;
  final int? passId;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;

  EventSearchStudentModel({
    required this.id,
    required this.studentName,
    required this.admissionNumber,
    this.rollNo,
    this.studentUniqueId,
    this.className,
    this.sectionName,
    this.streamName,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.whatsappNo,
    this.studentAadhaar,
    this.fatherAadhaar,
    this.motherAadhaar,
    this.studentPhotoUrl,
    this.studentPhotoPath,
    this.fatherPhotoUrl,
    this.fatherPhotoPath,
    this.motherPhotoUrl,
    this.motherPhotoPath,
    this.passExists = false,
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
  });

  factory EventSearchStudentModel.fromJson(Map<String, dynamic> json) {
    return EventSearchStudentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      studentName: json['student_name'] ?? '',
      admissionNumber: json['admission_number']?.toString() ?? '',
      rollNo: json['roll_no']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      className: json['class_name']?.toString(),
      sectionName: json['section_name']?.toString(),
      streamName: json['stream_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      whatsappNo: json['whatsapp_no']?.toString(),
      studentAadhaar: json['student_aadhaar']?.toString(),
      fatherAadhaar: json['father_aadhaar']?.toString(),
      motherAadhaar: json['mother_aadhaar']?.toString(),
      studentPhotoUrl: json['student_photo_url']?.toString(),
      studentPhotoPath: json['student_photo_path']?.toString(),
      fatherPhotoUrl: json['father_photo_url']?.toString(),
      fatherPhotoPath: json['father_photo_path']?.toString(),
      motherPhotoUrl: json['mother_photo_url']?.toString(),
      motherPhotoPath: json['mother_photo_path']?.toString(),
      passExists: json['pass_exists'] ?? false,
      passId: json['pass_id'] is int
          ? json['pass_id']
          : int.tryParse(json['pass_id']?.toString() ?? ''),
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'student_unique_id': studentUniqueId,
      'class_name': className,
      'section_name': sectionName,
      'stream_name': streamName,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'mother_name': motherName,
      'mother_mobile': motherMobile,
      'whatsapp_no': whatsappNo,
      'student_aadhaar': studentAadhaar,
      'father_aadhaar': fatherAadhaar,
      'mother_aadhaar': motherAadhaar,
      'student_photo_url': studentPhotoUrl,
      'student_photo_path': studentPhotoPath,
      'father_photo_url': fatherPhotoUrl,
      'father_photo_path': fatherPhotoPath,
      'mother_photo_url': motherPhotoUrl,
      'mother_photo_path': motherPhotoPath,
      'pass_exists': passExists,
      'pass_id': passId,
      'pass_number': passNumber,
      'approval_status': approvalStatus,
      'checkin_status': checkinStatus,
    };
  }
}

class AdmissionEnquiryModel {
  final bool success;
  final List<EnquiryData> data;

  AdmissionEnquiryModel({
    required this.success,
    required this.data,
  });

  factory AdmissionEnquiryModel.fromJson(Map<String, dynamic> json) {
    return AdmissionEnquiryModel(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => EnquiryData.fromJson(i))
          .toList(),
    );
  }
}

class EnquiryData {
  final int id;
  final String inquiryNumber;
  final String fullName;
  final String gender;
  final String dob;
  final String sessionYear;
  final int studentClassId;
  final String className;
  final String status;
  final String statusLabel;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherMobile;
  final String? studentImageUrl;
  final String createdAt;

  EnquiryData({
    required this.id,
    required this.inquiryNumber,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.sessionYear,
    required this.studentClassId,
    required this.className,
    required this.status,
    required this.statusLabel,
    this.fatherName,
    this.fatherMobile,
    this.motherMobile,
    this.studentImageUrl,
    required this.createdAt,
  });

  factory EnquiryData.fromJson(Map<String, dynamic> json) {
    return EnquiryData(
      id: json['id'] ?? 0,
      inquiryNumber: json['inquiry_number'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      sessionYear: json['session_year'] ?? '',
      studentClassId: json['student_class_id'] ?? 0,
      className: json['class_name'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      fatherName: json['father_name'],
      fatherMobile: json['father_mobile'],
      motherMobile: json['mother_mobile'],
      studentImageUrl: json['student_image_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

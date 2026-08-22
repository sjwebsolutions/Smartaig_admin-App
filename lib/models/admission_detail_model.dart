class AdmissionDetailModel {
  final bool success;
  final EnquiryDetailData? data;

  AdmissionDetailModel({
    required this.success,
    this.data,
  });

  factory AdmissionDetailModel.fromJson(Map<String, dynamic> json) {
    return AdmissionDetailModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? EnquiryDetailData.fromJson(json['data']) : null,
    );
  }
}

class EnquiryDetailData {
  final int id;
  final String inquiryNumber;
  final String fullName;
  final String gender;
  final String dob;
  final String? aadhaarNo;
  final String? category;
  final String? religion;
  final String? caste;
  final int studentClassId;
  final String className;
  final String? previousSchool;
  final String? lastClassAttended;
  final String? reasonForLeaving;
  final String? fatherName;
  final String? motherName;
  final String? fatherMobile;
  final String? motherMobile;
  final String? fatherOccupation;
  final String? motherOccupation;
  final String? fatherQualification;
  final String? motherQualification;
  final String? familyIncome;
  final String? medicalHistory;
  final String? alternateContact;
  final String address;
  final String? locality;
  final String? city;
  final String? state;
  final String? pincode;
  final String sessionYear;
  final String status;
  final String statusLabel;
  final String? followUpStatus;
  final String? interestLevel;
  final String? remarks;
  final String? siblingsDetails;
  final String? studentImageUrl;
  final String createdAt;

  EnquiryDetailData({
    required this.id,
    required this.inquiryNumber,
    required this.fullName,
    required this.gender,
    required this.dob,
    this.aadhaarNo,
    this.category,
    this.religion,
    this.caste,
    required this.studentClassId,
    required this.className,
    this.previousSchool,
    this.lastClassAttended,
    this.reasonForLeaving,
    this.fatherName,
    this.motherName,
    this.fatherMobile,
    this.motherMobile,
    this.fatherOccupation,
    this.motherOccupation,
    this.fatherQualification,
    this.motherQualification,
    this.familyIncome,
    this.medicalHistory,
    this.alternateContact,
    required this.address,
    this.locality,
    this.city,
    this.state,
    this.pincode,
    required this.sessionYear,
    required this.status,
    required this.statusLabel,
    this.followUpStatus,
    this.interestLevel,
    this.remarks,
    this.siblingsDetails,
    this.studentImageUrl,
    required this.createdAt,
  });

  factory EnquiryDetailData.fromJson(Map<String, dynamic> json) {
    return EnquiryDetailData(
      id: json['id'] ?? 0,
      inquiryNumber: json['inquiry_number'] ?? '',
      fullName: json['full_name'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      aadhaarNo: json['aadhaar_no'],
      category: json['category'],
      religion: json['religion'],
      caste: json['caste'],
      studentClassId: json['student_class_id'] ?? 0,
      className: json['class_name'] ?? '',
      previousSchool: json['previous_school'],
      lastClassAttended: json['last_class_attended'],
      reasonForLeaving: json['reason_for_leaving'],
      fatherName: json['father_name'],
      motherName: json['mother_name'],
      fatherMobile: json['father_mobile'],
      motherMobile: json['mother_mobile'],
      fatherOccupation: json['father_occupation'],
      motherOccupation: json['mother_occupation'],
      fatherQualification: json['father_qualification'],
      motherQualification: json['mother_qualification'],
      familyIncome: json['family_income'],
      medicalHistory: json['medical_history'],
      alternateContact: json['alternate_contact'],
      address: json['address'] ?? '',
      locality: json['locality'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      sessionYear: json['session_year'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      followUpStatus: json['follow_up_status'],
      interestLevel: json['interest_level'],
      remarks: json['remarks'],
      siblingsDetails: json['siblings_details'],
      studentImageUrl: json['student_image_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

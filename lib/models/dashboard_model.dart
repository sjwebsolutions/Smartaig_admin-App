class UserModel {
  final int id;
  final String name;
  final String staffType;
  final String whatsappNumber;
  final String phone;
  final String? email;
  final int schoolId;
  final String teacherUniqueId;
  final String gender;
  final String status;
  final String? dob;
  final String image;
  final String thumbnail;
  final String? address;
  final String? district;
  final String? state;
  final String? pincode;
  final dynamic experience;

  UserModel({
    required this.id,
    required this.name,
    required this.staffType,
    required this.whatsappNumber,
    required this.phone,
    this.email,
    required this.schoolId,
    required this.teacherUniqueId,
    required this.gender,
    required this.status,
    this.dob,
    required this.image,
    required this.thumbnail,
    this.address,
    this.district,
    this.state,
    this.pincode,
    this.experience,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      staffType: json['staff_type'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      schoolId: json['school_id'] ?? 0,
      teacherUniqueId: json['teacher_unique_id'] ?? '',
      gender: json['gender'] ?? '',
      status: json['status'] ?? '',
      dob: json['dob'],
      image: json['image'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      address: json['address'],
      district: json['district'],
      state: json['state'],
      pincode: json['pincode'],
      experience: json['experience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'staff_type': staffType,
      'whatsapp_number': whatsappNumber,
      'phone': phone,
      'email': email,
      'school_id': schoolId,
      'teacher_unique_id': teacherUniqueId,
      'gender': gender,
      'status': status,
      'dob': dob,
      'image': image,
      'thumbnail': thumbnail,
      'address': address,
      'district': district,
      'state': state,
      'pincode': pincode,
      'experience': experience,
    };
  }
}

class SchoolModel {
  final int id;
  final String schoolName;
  final String schoolCode;
  final String aigMembershipId;
  final String validityTill;
  final String? logo;

  SchoolModel({
    required this.id,
    required this.schoolName,
    required this.schoolCode,
    required this.aigMembershipId,
    required this.validityTill,
    this.logo,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] ?? 0,
      schoolName: json['school_name'] ?? '',
      schoolCode: json['school_code'] ?? '',
      aigMembershipId: json['aig_membership_id'] ?? '',
      validityTill: json['validity_till'] ?? '',
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_name': schoolName,
      'school_code': schoolCode,
      'aig_membership_id': aigMembershipId,
      'validity_till': validityTill,
      'logo': logo,
    };
  }
}

class DashboardModel {
  final bool success;
  final DashboardData? data;
  final UserModel? user;
  final SchoolModel? school;

  DashboardModel({
    required this.success,
    this.data,
    this.user,
    this.school,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      school: json['school'] != null ? SchoolModel.fromJson(json['school']) : null,
    );
  }
}

class DashboardData {
  final UserModel teacher;
  final UserModel? user;
  final String activeSession;
  final SchoolModel school;
  final int totalActiveStudents;
  final int totalActiveTeachers;

  DashboardData({
    required this.teacher,
    this.user,
    required this.activeSession,
    required this.school,
    required this.totalActiveStudents,
    required this.totalActiveTeachers,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      teacher: UserModel.fromJson(json['teacher'] ?? json['user'] ?? {}),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      activeSession: json['active_session'] ?? '',
      school: SchoolModel.fromJson(json['school'] ?? {}),
      totalActiveStudents: json['total_active_students'] ?? 0,
      totalActiveTeachers: json['total_active_teachers'] ?? 0,
    );
  }
}

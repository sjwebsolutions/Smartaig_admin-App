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
    int parseToInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return UserModel(
      id: parseToInt(json['id']),
      name: json['name']?.toString() ?? '',
      staffType: json['staff_type']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      schoolId: parseToInt(json['school_id']),
      teacherUniqueId: json['teacher_unique_id']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dob: json['dob']?.toString(),
      image: json['image']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      address: json['address']?.toString(),
      district: json['district']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
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
    int parseToInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return SchoolModel(
      id: parseToInt(json['id']),
      schoolName: json['school_name']?.toString() ?? '',
      schoolCode: json['school_code']?.toString() ?? '',
      aigMembershipId: json['aig_membership_id']?.toString() ?? '',
      validityTill: json['validity_till']?.toString() ?? '',
      logo: json['logo']?.toString(),
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
    final bool isSuccess = json['success'] == true ||
        json['success']?.toString().toLowerCase() == 'true' ||
        json['success'] == 1 ||
        json['status'] == true ||
        json['status']?.toString().toLowerCase() == 'success' ||
        json['status']?.toString().toLowerCase() == 'true';

    final Map<String, dynamic>? dataMap = json['data'] is Map<String, dynamic>
        ? json['data']
        : (json['teacher'] != null || json['school'] != null || json['user'] != null ? json : null);

    return DashboardModel(
      success: isSuccess || dataMap != null,
      data: dataMap != null ? DashboardData.fromJson(dataMap) : null,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
      school: json['school'] != null && json['school'] is Map<String, dynamic>
          ? SchoolModel.fromJson(json['school'])
          : null,
    );
  }
}

class CallbackRequestsModel {
  final int pending;
  final int inProgress;
  final int completedToday;

  CallbackRequestsModel({
    required this.pending,
    required this.inProgress,
    required this.completedToday,
  });

  bool get hasPendingOrInProgress => pending > 0 || inProgress > 0;

  factory CallbackRequestsModel.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return CallbackRequestsModel(
      pending: parseToInt(json['pending']),
      inProgress: parseToInt(json['in_progress']),
      completedToday: parseToInt(json['completed_today']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'in_progress': inProgress,
      'completed_today': completedToday,
    };
  }
}

class LeaveSummaryModel {
  final int totalPendingCount;
  final int todayPendingCount;

  LeaveSummaryModel({
    required this.totalPendingCount,
    required this.todayPendingCount,
  });

  factory LeaveSummaryModel.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return LeaveSummaryModel(
      totalPendingCount: parseToInt(json['total_pending_count']),
      todayPendingCount: parseToInt(json['today_pending_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_pending_count': totalPendingCount,
      'today_pending_count': todayPendingCount,
    };
  }
}

class DashboardData {
  final UserModel teacher;
  final UserModel? user;
  final String activeSession;
  final SchoolModel school;
  final int totalActiveStudents;
  final int totalActiveTeachers;
  final LeaveSummaryModel? studentLeaves;
  final LeaveSummaryModel? teacherLeaves;
  final CallbackRequestsModel? callbackRequests;

  DashboardData({
    required this.teacher,
    this.user,
    required this.activeSession,
    required this.school,
    required this.totalActiveStudents,
    required this.totalActiveTeachers,
    this.studentLeaves,
    this.teacherLeaves,
    this.callbackRequests,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    int parseToInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    final Map<String, dynamic> teacherMap = json['teacher'] is Map<String, dynamic>
        ? json['teacher']
        : (json['user'] is Map<String, dynamic> ? json['user'] : {});
    final Map<String, dynamic> schoolMap = json['school'] is Map<String, dynamic> ? json['school'] : {};

    return DashboardData(
      teacher: UserModel.fromJson(teacherMap),
      user: json['user'] is Map<String, dynamic> ? UserModel.fromJson(json['user']) : null,
      activeSession: json['active_session']?.toString() ?? '',
      school: SchoolModel.fromJson(schoolMap),
      totalActiveStudents: parseToInt(json['total_active_students']),
      totalActiveTeachers: parseToInt(json['total_active_teachers']),
      studentLeaves: json['student_leaves'] is Map<String, dynamic>
          ? LeaveSummaryModel.fromJson(json['student_leaves'])
          : null,
      teacherLeaves: json['teacher_leaves'] is Map<String, dynamic>
          ? LeaveSummaryModel.fromJson(json['teacher_leaves'])
          : null,
      callbackRequests: json['callback_requests'] is Map<String, dynamic>
          ? CallbackRequestsModel.fromJson(json['callback_requests'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher.toJson(),
      'user': user?.toJson(),
      'active_session': activeSession,
      'school': school.toJson(),
      'total_active_students': totalActiveStudents,
      'total_active_teachers': totalActiveTeachers,
      'student_leaves': studentLeaves?.toJson(),
      'teacher_leaves': teacherLeaves?.toJson(),
      'callback_requests': callbackRequests?.toJson(),
    };
  }
}

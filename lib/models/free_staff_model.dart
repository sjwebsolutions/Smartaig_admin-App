class FreeStaffResponse {
  final bool success;
  final FreeStaffData? data;

  FreeStaffResponse({
    required this.success,
    this.data,
  });

  factory FreeStaffResponse.fromJson(Map<String, dynamic> json) {
    return FreeStaffResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? FreeStaffData.fromJson(json['data']) : null,
    );
  }
}

class FreeStaffData {
  final FreeStaffPlan plan;
  final String examDate;
  final String dayName;
  final String formattedDate;
  final FreeStaffCounts counts;
  final List<StaffMember> freeStaff;

  FreeStaffData({
    required this.plan,
    required this.examDate,
    required this.dayName,
    required this.formattedDate,
    required this.counts,
    required this.freeStaff,
  });

  factory FreeStaffData.fromJson(Map<String, dynamic> json) {
    return FreeStaffData(
      plan: FreeStaffPlan.fromJson(json['plan'] ?? {}),
      examDate: json['exam_date'] ?? '',
      dayName: json['day_name'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      counts: FreeStaffCounts.fromJson(json['counts'] ?? {}),
      freeStaff: (json['free_staff'] as List? ?? [])
          .map((item) => StaffMember.fromJson(item))
          .toList(),
    );
  }
}

class FreeStaffPlan {
  final int id;
  final String name;
  final String session;

  FreeStaffPlan({
    required this.id,
    required this.name,
    required this.session,
  });

  factory FreeStaffPlan.fromJson(Map<String, dynamic> json) {
    return FreeStaffPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      session: json['session'] ?? '',
    );
  }
}

class FreeStaffCounts {
  final int totalStaff;
  final int assignedStaff;
  final int freeStaff;

  FreeStaffCounts({
    required this.totalStaff,
    required this.assignedStaff,
    required this.freeStaff,
  });

  factory FreeStaffCounts.fromJson(Map<String, dynamic> json) {
    return FreeStaffCounts(
      totalStaff: json['total_staff'] ?? 0,
      assignedStaff: json['assigned_staff'] ?? 0,
      freeStaff: json['free_staff'] ?? 0,
    );
  }
}

class StaffMember {
  final int id;
  final String name;
  final String staffType;
  final String? designation;
  final String? phone;
  final String? email;
  final List<String> teachingSubjects;

  StaffMember({
    required this.id,
    required this.name,
    required this.staffType,
    this.designation,
    this.phone,
    this.email,
    required this.teachingSubjects,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      staffType: json['staff_type'] ?? '',
      designation: json['designation'],
      phone: json['phone'],
      email: json['email'],
      teachingSubjects: List<String>.from(json['teaching_subjects'] ?? []),
    );
  }
}

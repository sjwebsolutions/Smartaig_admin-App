class StaffDutiesResponse {
  final bool success;
  final StaffDutiesData? data;

  StaffDutiesResponse({
    required this.success,
    this.data,
  });

  factory StaffDutiesResponse.fromJson(Map<String, dynamic> json) {
    return StaffDutiesResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? StaffDutiesData.fromJson(json['data']) : null,
    );
  }
}

class StaffDutiesData {
  final StaffDutiesPlan plan;
  final List<StaffDutyMember> staffDuties;

  StaffDutiesData({
    required this.plan,
    required this.staffDuties,
  });

  factory StaffDutiesData.fromJson(Map<String, dynamic> json) {
    return StaffDutiesData(
      plan: StaffDutiesPlan.fromJson(json['plan'] ?? {}),
      staffDuties: (json['staff_duties'] as List? ?? [])
          .map((item) => StaffDutyMember.fromJson(item))
          .toList(),
    );
  }
}

class StaffDutiesPlan {
  final int id;
  final String name;
  final String session;
  final String datesheetName;

  StaffDutiesPlan({
    required this.id,
    required this.name,
    required this.session,
    required this.datesheetName,
  });

  factory StaffDutiesPlan.fromJson(Map<String, dynamic> json) {
    return StaffDutiesPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      session: json['session'] ?? '',
      datesheetName: json['datesheet_name'] ?? '',
    );
  }
}

class StaffDutyMember {
  final int teacherId;
  final String name;
  final String staffType;
  final String? designation;
  final String? phone;
  final int totalDuties;
  final List<String> datesAssigned;

  StaffDutyMember({
    required this.teacherId,
    required this.name,
    required this.staffType,
    this.designation,
    this.phone,
    required this.totalDuties,
    required this.datesAssigned,
  });

  factory StaffDutyMember.fromJson(Map<String, dynamic> json) {
    return StaffDutyMember(
      teacherId: json['teacher_id'] ?? 0,
      name: json['name'] ?? '',
      staffType: json['staff_type'] ?? '',
      designation: json['designation'],
      phone: json['phone'],
      totalDuties: json['total_duties'] ?? 0,
      datesAssigned: List<String>.from(json['dates_assigned'] ?? []),
    );
  }
}

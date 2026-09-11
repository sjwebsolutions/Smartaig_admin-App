class InvigilatorDutyDetailResponse {
  final bool success;
  final InvigilatorDutyDetail? data;

  InvigilatorDutyDetailResponse({
    required this.success,
    this.data,
  });

  factory InvigilatorDutyDetailResponse.fromJson(Map<String, dynamic> json) {
    return InvigilatorDutyDetailResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? InvigilatorDutyDetail.fromJson(json['data']) : null,
    );
  }
}

class InvigilatorDutyDetail {
  final DutyPlan plan;
  final String selectedDate;
  final String dayName;
  final String formattedDate;
  final String? examTiming;
  final List<AvailableExamDate> availableExamDates;
  final DutySummary summary;
  final List<DutyRoom> rooms;

  InvigilatorDutyDetail({
    required this.plan,
    required this.selectedDate,
    required this.dayName,
    required this.formattedDate,
    this.examTiming,
    required this.availableExamDates,
    required this.summary,
    required this.rooms,
  });

  factory InvigilatorDutyDetail.fromJson(Map<String, dynamic> json) {
    return InvigilatorDutyDetail(
      plan: DutyPlan.fromJson(json['plan'] ?? {}),
      selectedDate: json['selected_date'] ?? '',
      dayName: json['day_name'] ?? '',
      formattedDate: json['formatted_date'] ?? '',
      examTiming: json['exam_timing'],
      availableExamDates: (json['available_exam_dates'] as List? ?? [])
          .map((item) => AvailableExamDate.fromJson(item))
          .toList(),
      summary: DutySummary.fromJson(json['summary'] ?? {}),
      rooms: (json['rooms'] as List? ?? [])
          .map((item) => DutyRoom.fromJson(item))
          .toList(),
    );
  }
}

class DutyPlan {
  final int id;
  final String name;
  final String session;
  final String datesheetName;

  DutyPlan({
    required this.id,
    required this.name,
    required this.session,
    required this.datesheetName,
  });

  factory DutyPlan.fromJson(Map<String, dynamic> json) {
    return DutyPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      session: json['session'] ?? '',
      datesheetName: json['datesheet_name'] ?? '',
    );
  }
}

class AvailableExamDate {
  final String date;
  final String dayName;
  final String formatted;

  AvailableExamDate({
    required this.date,
    required this.dayName,
    required this.formatted,
  });

  factory AvailableExamDate.fromJson(Map<String, dynamic> json) {
    return AvailableExamDate(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      formatted: json['formatted'] ?? '',
    );
  }
}

class DutySummary {
  final int totalRooms;
  final int fullyAssignedRooms;
  final int unassignedRooms;
  final int totalTeachersOnDuty;
  final int totalFreeTeachers;

  DutySummary({
    required this.totalRooms,
    required this.fullyAssignedRooms,
    required this.unassignedRooms,
    required this.totalTeachersOnDuty,
    required this.totalFreeTeachers,
  });

  factory DutySummary.fromJson(Map<String, dynamic> json) {
    return DutySummary(
      totalRooms: json['total_rooms'] ?? 0,
      fullyAssignedRooms: json['fully_assigned_rooms'] ?? 0,
      unassignedRooms: json['unassigned_rooms'] ?? 0,
      totalTeachersOnDuty: json['total_teachers_on_duty'] ?? 0,
      totalFreeTeachers: json['total_free_teachers'] ?? 0,
    );
  }
}

class DutyRoom {
  final int roomId;
  final String roomName;
  final int capacity;
  final int studentCount;
  final List<String> classes;
  final List<String> subjects;
  final String status;
  final List<AssignedTeacher> assignedTeachers;

  DutyRoom({
    required this.roomId,
    required this.roomName,
    required this.capacity,
    required this.studentCount,
    required this.classes,
    required this.subjects,
    required this.status,
    required this.assignedTeachers,
  });

  factory DutyRoom.fromJson(Map<String, dynamic> json) {
    return DutyRoom(
      roomId: json['room_id'] ?? 0,
      roomName: json['room_name'] ?? '',
      capacity: json['capacity'] ?? 0,
      studentCount: json['student_count'] ?? 0,
      classes: List<String>.from(json['classes'] ?? []),
      subjects: List<String>.from(json['subjects'] ?? []),
      status: json['status'] ?? '',
      assignedTeachers: (json['assigned_teachers'] as List? ?? [])
          .map((item) => AssignedTeacher.fromJson(item))
          .toList(),
    );
  }
}

class AssignedTeacher {
  final int id;
  final String name;
  final String staffType;
  final String? designation;
  final String? phone;

  AssignedTeacher({
    required this.id,
    required this.name,
    required this.staffType,
    this.designation,
    this.phone,
  });

  factory AssignedTeacher.fromJson(Map<String, dynamic> json) {
    return AssignedTeacher(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      staffType: json['staff_type'] ?? '',
      designation: json['designation'],
      phone: json['phone'],
    );
  }
}

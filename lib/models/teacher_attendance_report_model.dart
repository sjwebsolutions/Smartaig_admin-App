class TeacherAttendanceReportModel {
  final bool success;
  final TeacherAttendanceData? data;

  TeacherAttendanceReportModel({
    required this.success,
    this.data,
  });

  factory TeacherAttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceReportModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? TeacherAttendanceData.fromJson(json['data']) : null,
    );
  }
}

class TeacherAttendanceData {
  final TeacherAttendanceStats stats;
  final List<DepartmentWiseAttendance> departmentWiseData;

  TeacherAttendanceData({
    required this.stats,
    required this.departmentWiseData,
  });

  factory TeacherAttendanceData.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceData(
      stats: TeacherAttendanceStats.fromJson(json['stats'] ?? {}),
      departmentWiseData: (json['department_wise_data'] as List? ?? [])
          .map((i) => DepartmentWiseAttendance.fromJson(i))
          .toList(),
    );
  }
}

class TeacherAttendanceStats {
  final int totalTeachers;
  final int activeTeachers;
  final int presentToday;
  final int absentToday;
  final int leaveToday;

  TeacherAttendanceStats({
    required this.totalTeachers,
    required this.activeTeachers,
    required this.presentToday,
    required this.absentToday,
    required this.leaveToday,
  });

  factory TeacherAttendanceStats.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceStats(
      totalTeachers: json['total_teachers'] ?? 0,
      activeTeachers: json['active_teachers'] ?? 0,
      presentToday: json['present_today'] ?? 0,
      absentToday: json['absent_today'] ?? 0,
      leaveToday: json['leave_today'] ?? 0,
    );
  }
}

class DepartmentWiseAttendance {
  final int? departmentId;
  final String departmentName;
  final int totalTeachers;
  final int present;
  final int absent;
  final int leave;

  DepartmentWiseAttendance({
    this.departmentId,
    required this.departmentName,
    required this.totalTeachers,
    required this.present,
    required this.absent,
    required this.leave,
  });

  factory DepartmentWiseAttendance.fromJson(Map<String, dynamic> json) {
    return DepartmentWiseAttendance(
      departmentId: json['department_id'],
      departmentName: json['department_name'] ?? '',
      totalTeachers: json['total_teachers'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      leave: json['leave'] ?? 0,
    );
  }
}

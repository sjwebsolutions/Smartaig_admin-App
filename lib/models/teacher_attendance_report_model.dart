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
  final List<StaffAttendanceData> staffAttendanceData;

  TeacherAttendanceData({
    required this.stats,
    required this.staffAttendanceData,
  });

  factory TeacherAttendanceData.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceData(
      stats: TeacherAttendanceStats.fromJson(json['stats'] ?? {}),
      staffAttendanceData: (json['staff_attendance_data'] as List? ?? [])
          .map((i) => StaffAttendanceData.fromJson(i))
          .toList(),
    );
  }
}

class TeacherAttendanceStats {
  final int totalStaff;
  final int present;
  final int late;
  final int halfDay;
  final int leave;
  final int holidayOff;
  final int absent;
  final int combinedPresent;

  TeacherAttendanceStats({
    required this.totalStaff,
    required this.present,
    required this.late,
    required this.halfDay,
    required this.leave,
    required this.holidayOff,
    required this.absent,
    required this.combinedPresent,
  });

  factory TeacherAttendanceStats.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceStats(
      totalStaff: json['total_staff'] ?? 0,
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      halfDay: json['half_day'] ?? 0,
      leave: json['leave'] ?? 0,
      holidayOff: json['holiday_off'] ?? 0,
      absent: json['absent'] ?? 0,
      combinedPresent: json['combined_present'] ?? 0,
    );
  }
}

class StaffAttendanceData {
  final String teacherName;
  final String teacherUid;
  final String wingName;
  final String attendanceStatus;
  final String checkIn;
  final String checkOut;
  final String deductionPolicy;
  final String dayStatus;
  final String remarks;

  StaffAttendanceData({
    required this.teacherName,
    required this.teacherUid,
    required this.wingName,
    required this.attendanceStatus,
    required this.checkIn,
    required this.checkOut,
    required this.deductionPolicy,
    required this.dayStatus,
    required this.remarks,
  });

  factory StaffAttendanceData.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceData(
      teacherName: json['teacher_name'] ?? '',
      teacherUid: json['teacher_uid'] ?? '',
      wingName: json['wing_name'] ?? '',
      attendanceStatus: json['attendance_status'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      deductionPolicy: json['deduction_policy'] ?? '',
      dayStatus: json['day_status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }
}

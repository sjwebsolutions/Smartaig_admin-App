class StudentAttendanceReportModel {
  final bool success;
  final AttendanceData? data;

  StudentAttendanceReportModel({
    required this.success,
    this.data,
  });

  factory StudentAttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceReportModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? AttendanceData.fromJson(json['data']) : null,
    );
  }
}

class AttendanceData {
  final AttendanceStats stats;
  final List<ClassWiseAttendance> classWiseData;

  AttendanceData({
    required this.stats,
    required this.classWiseData,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      stats: AttendanceStats.fromJson(json['stats'] ?? {}),
      classWiseData: (json['class_wise_data'] as List? ?? [])
          .map((i) => ClassWiseAttendance.fromJson(i))
          .toList(),
    );
  }
}

class AttendanceStats {
  final int totalStudents;
  final int activeStudents;
  final int presentToday;
  final int absentToday;
  final int leaveToday;

  AttendanceStats({
    required this.totalStudents,
    required this.activeStudents,
    required this.presentToday,
    required this.absentToday,
    required this.leaveToday,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalStudents: json['total_students'] ?? 0,
      activeStudents: json['active_students'] ?? 0,
      presentToday: json['present_today'] ?? 0,
      absentToday: json['absent_today'] ?? 0,
      leaveToday: json['leave_today'] ?? 0,
    );
  }
}

class ClassWiseAttendance {
  final int classId;
  final String className;
  final int? streamId;
  final String? streamName;
  final int totalStudents;
  final int present;
  final int absent;
  final int leave;

  ClassWiseAttendance({
    required this.classId,
    required this.className,
    this.streamId,
    this.streamName,
    required this.totalStudents,
    required this.present,
    required this.absent,
    required this.leave,
  });

  factory ClassWiseAttendance.fromJson(Map<String, dynamic> json) {
    return ClassWiseAttendance(
      classId: json['class_id'] ?? 0,
      className: json['class_name'] ?? '',
      streamId: json['stream_id'],
      streamName: json['stream_name'],
      totalStudents: json['total_students'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      leave: json['leave'] ?? 0,
    );
  }
}

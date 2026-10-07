class QrScanResponseModel {
  final bool success;
  final bool alreadyMarked;
  final String? message;
  final QrScanData? data;

  QrScanResponseModel({
    required this.success,
    this.alreadyMarked = false,
    this.message,
    this.data,
  });

  factory QrScanResponseModel.fromJson(Map<String, dynamic> json) {
    return QrScanResponseModel(
      success: json['success'] is bool
          ? json['success']
          : (json['success'] == 1 || json['success'] == 'true'),
      alreadyMarked: json['already_marked'] is bool
          ? json['already_marked']
          : (json['already_marked'] == 1 || json['already_marked'] == 'true'),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? QrScanData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'already_marked': alreadyMarked,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class QrScanData {
  final QrStudentInfo? student;
  final QrAttendanceInfo? attendance;

  QrScanData({
    this.student,
    this.attendance,
  });

  factory QrScanData.fromJson(Map<String, dynamic> json) {
    return QrScanData(
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? QrStudentInfo.fromJson(json['student'])
          : null,
      attendance: json['attendance'] != null && json['attendance'] is Map<String, dynamic>
          ? QrAttendanceInfo.fromJson(json['attendance'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student?.toJson(),
      'attendance': attendance?.toJson(),
    };
  }
}

class QrStudentInfo {
  final int? id;
  final String? studentUniqueId;
  final String studentName;
  final String? studentNamePunjabi;
  final String? rollNo;
  final String? admissionNumber;
  final int? classId;
  final String? className;
  final int? sectionId;
  final String? sectionName;
  final int? streamId;
  final String? streamName;
  final String? gender;
  final String? fatherName;
  final String? fatherMobile;
  final String? profileImage;

  QrStudentInfo({
    this.id,
    this.studentUniqueId,
    required this.studentName,
    this.studentNamePunjabi,
    this.rollNo,
    this.admissionNumber,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.streamId,
    this.streamName,
    this.gender,
    this.fatherName,
    this.fatherMobile,
    this.profileImage,
  });

  factory QrStudentInfo.fromJson(Map<String, dynamic> json) {
    return QrStudentInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      studentUniqueId: json['student_unique_id']?.toString(),
      studentName: json['student_name']?.toString() ?? 'Student',
      studentNamePunjabi: json['student_name_punjabi']?.toString(),
      rollNo: json['roll_no']?.toString(),
      admissionNumber: json['admission_number']?.toString(),
      classId: json['class_id'] is int
          ? json['class_id']
          : int.tryParse(json['class_id']?.toString() ?? ''),
      className: json['class_name']?.toString(),
      sectionId: json['section_id'] is int
          ? json['section_id']
          : int.tryParse(json['section_id']?.toString() ?? ''),
      sectionName: json['section_name']?.toString(),
      streamId: json['stream_id'] is int
          ? json['stream_id']
          : int.tryParse(json['stream_id']?.toString() ?? ''),
      streamName: json['stream_name']?.toString(),
      gender: json['gender']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_unique_id': studentUniqueId,
      'student_name': studentName,
      'student_name_punjabi': studentNamePunjabi,
      'roll_no': rollNo,
      'admission_number': admissionNumber,
      'class_id': classId,
      'class_name': className,
      'section_id': sectionId,
      'section_name': sectionName,
      'stream_id': streamId,
      'stream_name': streamName,
      'gender': gender,
      'father_name': fatherName,
      'father_mobile': fatherMobile,
      'profile_image': profileImage,
    };
  }
}

class QrAttendanceInfo {
  final int? id;
  final String? status;
  final String? date;
  final String? punchTime;
  final String? attendanceMode;
  final String? markedVia;
  final String? takenByName;
  final String? takenByRole;
  final String? remarks;

  QrAttendanceInfo({
    this.id,
    this.status,
    this.date,
    this.punchTime,
    this.attendanceMode,
    this.markedVia,
    this.takenByName,
    this.takenByRole,
    this.remarks,
  });

  factory QrAttendanceInfo.fromJson(Map<String, dynamic> json) {
    return QrAttendanceInfo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      status: json['status']?.toString(),
      date: json['date']?.toString(),
      punchTime: json['punch_time']?.toString(),
      attendanceMode: json['attendance_mode']?.toString(),
      markedVia: json['marked_via']?.toString(),
      takenByName: json['taken_by_name']?.toString(),
      takenByRole: json['taken_by_role']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'date': date,
      'punch_time': punchTime,
      'attendance_mode': attendanceMode,
      'marked_via': markedVia,
      'taken_by_name': takenByName,
      'taken_by_role': takenByRole,
      'remarks': remarks,
    };
  }
}

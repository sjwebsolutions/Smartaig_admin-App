class StudentLeaveResponseModel {
  final bool success;
  final bool canApprove;
  final List<StudentLeaveItem> data;

  StudentLeaveResponseModel({
    required this.success,
    this.canApprove = false,
    this.data = const [],
  });

  factory StudentLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    return StudentLeaveResponseModel(
      success: json['success'] ?? false,
      canApprove: json['can_approve'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => StudentLeaveItem.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'can_approve': canApprove,
      'data': data.map((i) => i.toJson()).toList(),
    };
  }
}

class StudentLeaveItem {
  final int id;
  final int studentId;
  final int? studentClassId;
  final int? studentSectionId;
  final int? studentStreamId;
  final String studentName;
  final String admissionNumber;
  final String rollNo;
  final String className;
  final String sectionName;
  final String? streamName;
  final String dayType;
  final String dayTypeLabel;
  final String? halfDayStartTime;
  final String? halfDayEndTime;
  final String fromDate;
  final String toDate;
  final String fromDateFormatted;
  final String toDateFormatted;
  final num totalDays;
  final String reason;
  final String? attachmentUrl;
  final String status;
  final String statusLabel;
  final String? actionByRole;
  final String? actionByName;
  final String? actionAt;
  final String? approverRemarks;
  final String? rejectionReason;
  final String createdAt;

  StudentLeaveItem({
    required this.id,
    required this.studentId,
    this.studentClassId,
    this.studentSectionId,
    this.studentStreamId,
    required this.studentName,
    required this.admissionNumber,
    required this.rollNo,
    required this.className,
    required this.sectionName,
    this.streamName,
    required this.dayType,
    required this.dayTypeLabel,
    this.halfDayStartTime,
    this.halfDayEndTime,
    required this.fromDate,
    required this.toDate,
    required this.fromDateFormatted,
    required this.toDateFormatted,
    required this.totalDays,
    required this.reason,
    this.attachmentUrl,
    required this.status,
    required this.statusLabel,
    this.actionByRole,
    this.actionByName,
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    required this.createdAt,
  });

  factory StudentLeaveItem.fromJson(Map<String, dynamic> json) {
    return StudentLeaveItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      studentId: json['student_id'] is int ? json['student_id'] : int.tryParse(json['student_id']?.toString() ?? '0') ?? 0,
      studentClassId: json['student_class_id'] is int
          ? json['student_class_id']
          : int.tryParse(json['student_class_id']?.toString() ?? ''),
      studentSectionId: json['student_section_id'] is int
          ? json['student_section_id']
          : int.tryParse(json['student_section_id']?.toString() ?? ''),
      studentStreamId: json['student_stream_id'] is int
          ? json['student_stream_id']
          : int.tryParse(json['student_stream_id']?.toString() ?? ''),
      studentName: json['student_name']?.toString() ?? '',
      admissionNumber: json['admission_number']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? '',
      streamName: json['stream_name']?.toString(),
      dayType: json['day_type']?.toString() ?? '',
      dayTypeLabel: json['day_type_label']?.toString() ?? '',
      halfDayStartTime: json['half_day_start_time']?.toString(),
      halfDayEndTime: json['half_day_end_time']?.toString(),
      fromDate: json['from_date']?.toString() ?? '',
      toDate: json['to_date']?.toString() ?? '',
      fromDateFormatted: json['from_date_formatted']?.toString() ?? '',
      toDateFormatted: json['to_date_formatted']?.toString() ?? '',
      totalDays: json['total_days'] is num
          ? json['total_days']
          : num.tryParse(json['total_days']?.toString() ?? '0') ?? 0,
      reason: json['reason']?.toString() ?? '',
      attachmentUrl: json['attachment_url']?.toString(),
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      actionByRole: json['action_by_role']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_class_id': studentClassId,
      'student_section_id': studentSectionId,
      'student_stream_id': studentStreamId,
      'student_name': studentName,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'class_name': className,
      'section_name': sectionName,
      'stream_name': streamName,
      'day_type': dayType,
      'day_type_label': dayTypeLabel,
      'half_day_start_time': halfDayStartTime,
      'half_day_end_time': halfDayEndTime,
      'from_date': fromDate,
      'to_date': toDate,
      'from_date_formatted': fromDateFormatted,
      'to_date_formatted': toDateFormatted,
      'total_days': totalDays,
      'reason': reason,
      'attachment_url': attachmentUrl,
      'status': status,
      'status_label': statusLabel,
      'action_by_role': actionByRole,
      'action_by_name': actionByName,
      'action_at': actionAt,
      'approver_remarks': approverRemarks,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
    };
  }
}

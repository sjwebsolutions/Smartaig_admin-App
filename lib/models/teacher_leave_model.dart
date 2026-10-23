class TeacherLeaveResponseModel {
  final bool success;
  final bool canApprove;
  final List<TeacherLeaveItem> data;

  TeacherLeaveResponseModel({
    required this.success,
    this.canApprove = false,
    this.data = const [],
  });

  factory TeacherLeaveResponseModel.fromJson(Map<String, dynamic> json) {
    return TeacherLeaveResponseModel(
      success: json['success'] ?? false,
      canApprove: json['can_approve'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((i) => TeacherLeaveItem.fromJson(i))
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

class TeacherLeaveItem {
  final int id;
  final int teacherId;
  final String teacherName;
  final String teacherCode;
  final String teacherPhone;
  final String teacherDesignation;
  final String? teacherAvatar;
  final String leaveType;
  final String leaveTypeLabel;
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
  final String? actionViaApp;
  final String? actionAt;
  final String? approverRemarks;
  final String? rejectionReason;
  final String createdAt;
  final List<TeacherLeaveLog> logs;

  TeacherLeaveItem({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.teacherCode,
    required this.teacherPhone,
    required this.teacherDesignation,
    this.teacherAvatar,
    required this.leaveType,
    required this.leaveTypeLabel,
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
    this.actionViaApp,
    this.actionAt,
    this.approverRemarks,
    this.rejectionReason,
    required this.createdAt,
    this.logs = const [],
  });

  factory TeacherLeaveItem.fromJson(Map<String, dynamic> json) {
    return TeacherLeaveItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      teacherId: json['teacher_id'] is int ? json['teacher_id'] : int.tryParse(json['teacher_id']?.toString() ?? '0') ?? 0,
      teacherName: json['teacher_name']?.toString() ?? '',
      teacherCode: json['teacher_code']?.toString() ?? '',
      teacherPhone: json['teacher_phone']?.toString() ?? '',
      teacherDesignation: json['teacher_designation']?.toString() ?? 'Teacher',
      teacherAvatar: json['teacher_avatar']?.toString(),
      leaveType: json['leave_type']?.toString() ?? '',
      leaveTypeLabel: json['leave_type_label']?.toString() ?? '',
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
      actionViaApp: json['action_via_app']?.toString(),
      actionAt: json['action_at']?.toString(),
      approverRemarks: json['approver_remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      logs: (json['logs'] as List? ?? [])
          .map((l) => TeacherLeaveLog.fromJson(l))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'teacher_code': teacherCode,
      'teacher_phone': teacherPhone,
      'teacher_designation': teacherDesignation,
      'teacher_avatar': teacherAvatar,
      'leave_type': leaveType,
      'leave_type_label': leaveTypeLabel,
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
      'action_via_app': actionViaApp,
      'action_at': actionAt,
      'approver_remarks': approverRemarks,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
      'logs': logs.map((l) => l.toJson()).toList(),
    };
  }
}

class TeacherLeaveLog {
  final int id;
  final String action;
  final String actionLabel;
  final String? actionByName;
  final String? actionByRole;
  final String? actionViaApp;
  final String? notes;
  final String createdAt;

  TeacherLeaveLog({
    required this.id,
    required this.action,
    required this.actionLabel,
    this.actionByName,
    this.actionByRole,
    this.actionViaApp,
    this.notes,
    required this.createdAt,
  });

  factory TeacherLeaveLog.fromJson(Map<String, dynamic> json) {
    return TeacherLeaveLog(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? '',
      actionLabel: json['action_label']?.toString() ?? '',
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      actionViaApp: json['action_via_app']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'action_label': actionLabel,
      'action_by_name': actionByName,
      'action_by_role': actionByRole,
      'action_via_app': actionViaApp,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}

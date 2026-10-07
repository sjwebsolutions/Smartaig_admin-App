import 'package:smart_aig_admins_app/models/callback_request_model.dart';

class CallbackDetailResponse {
  final bool success;
  final CallbackDetailData? data;

  CallbackDetailResponse({
    required this.success,
    this.data,
  });

  factory CallbackDetailResponse.fromJson(Map<String, dynamic> json) {
    return CallbackDetailResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? CallbackDetailData.fromJson(json['data']) : null,
    );
  }
}

class CallbackDetailData {
  final int id;
  final String status;
  final String reason;
  final String? requestedAt;
  final String? timeAgo;
  final String? completedAt;
  final String? completedVia;
  final int reminderCount;
  final CallbackParent? parent;
  final CallbackStudent? student;
  final List<CallbackLog> logs;

  CallbackDetailData({
    required this.id,
    required this.status,
    required this.reason,
    this.requestedAt,
    this.timeAgo,
    this.completedAt,
    this.completedVia,
    this.reminderCount = 0,
    this.parent,
    this.student,
    required this.logs,
  });

  factory CallbackDetailData.fromJson(Map<String, dynamic> json) {
    return CallbackDetailData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      requestedAt: json['requested_at'],
      timeAgo: json['time_ago'],
      completedAt: json['completed_at'],
      completedVia: json['completed_via'],
      reminderCount: json['reminder_count'] ?? 0,
      parent: json['parent'] != null ? CallbackParent.fromJson(json['parent']) : null,
      student: json['student'] != null ? CallbackStudent.fromJson(json['student']) : null,
      logs: json['logs'] != null
          ? List<CallbackLog>.from(json['logs'].map((x) => CallbackLog.fromJson(x)))
          : [],
    );
  }
}

class CallbackLog {
  final int id;
  final String action;
  final String? callStatus;
  final String notes;
  final String? previousStatus;
  final String? newStatus;
  final String? staffName;
  final String? staffRole;
  final String? createdAt;
  final String? timeAgo;

  CallbackLog({
    required this.id,
    required this.action,
    this.callStatus,
    required this.notes,
    this.previousStatus,
    this.newStatus,
    this.staffName,
    this.staffRole,
    this.createdAt,
    this.timeAgo,
  });

  factory CallbackLog.fromJson(Map<String, dynamic> json) {
    return CallbackLog(
      id: json['id'] ?? 0,
      action: json['action'] ?? '',
      callStatus: json['call_status'],
      notes: json['notes'] ?? '',
      previousStatus: json['previous_status'],
      newStatus: json['new_status'],
      staffName: json['staff_name'],
      staffRole: json['staff_role'],
      createdAt: json['created_at'],
      timeAgo: json['time_ago'],
    );
  }
}

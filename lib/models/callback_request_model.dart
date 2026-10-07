class CallbackRequestResponse {
  final bool success;
  final CallbackSummary? summary;
  final List<CallbackData> data;
  final CallbackMeta? meta;

  CallbackRequestResponse({
    required this.success,
    this.summary,
    required this.data,
    this.meta,
  });

  factory CallbackRequestResponse.fromJson(Map<String, dynamic> json) {
    return CallbackRequestResponse(
      success: json['success'] ?? false,
      summary: json['summary'] != null
          ? CallbackSummary.fromJson(json['summary'])
          : null,
      data: json['data'] != null
          ? List<CallbackData>.from(
              json['data'].map((x) => CallbackData.fromJson(x)))
          : [],
      meta: json['meta'] != null ? CallbackMeta.fromJson(json['meta']) : null,
    );
  }
}

class CallbackSummaryResponse {
  final bool success;
  final CallbackSummary? data;

  CallbackSummaryResponse({
    required this.success,
    this.data,
  });

  factory CallbackSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CallbackSummaryResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? CallbackSummary.fromJson(json['data']) : null,
    );
  }
}

class CallbackSummary {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int completedToday;

  CallbackSummary({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.completedToday,
  });

  factory CallbackSummary.fromJson(Map<String, dynamic> json) {
    return CallbackSummary(
      total: json['total'] ?? 0,
      pending: json['pending'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      completed: json['completed'] ?? 0,
      completedToday: json['completed_today'] ?? 0,
    );
  }
}

class CallbackData {
  final int id;
  final String status;
  final String reason;
  final String? requestedAt;
  final String? timeAgo;
  final String? completedAt;
  final int notesCount;
  final CallbackParent? parent;
  final CallbackStudent? student;
  final CallbackNote? latestNote;

  CallbackData({
    required this.id,
    required this.status,
    required this.reason,
    this.requestedAt,
    this.timeAgo,
    this.completedAt,
    this.notesCount = 0,
    this.parent,
    this.student,
    this.latestNote,
  });

  factory CallbackData.fromJson(Map<String, dynamic> json) {
    return CallbackData(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      requestedAt: json['requested_at'],
      timeAgo: json['time_ago'],
      completedAt: json['completed_at'],
      notesCount: json['notes_count'] ?? 0,
      parent: json['parent'] != null ? CallbackParent.fromJson(json['parent']) : null,
      student: json['student'] != null ? CallbackStudent.fromJson(json['student']) : null,
      latestNote: json['latest_note'] != null ? CallbackNote.fromJson(json['latest_note']) : null,
    );
  }
}

class CallbackParent {
  final String name;
  final String mobile;

  CallbackParent({
    required this.name,
    required this.mobile,
  });

  factory CallbackParent.fromJson(Map<String, dynamic> json) {
    return CallbackParent(
      name: json['name'] ?? 'N/A',
      mobile: json['mobile'] ?? '',
    );
  }
}

class CallbackStudent {
  final int id;
  final String name;
  final String className;
  final String sectionName;
  final String? streamName;
  final String rollNo;

  CallbackStudent({
    required this.id,
    required this.name,
    required this.className,
    required this.sectionName,
    this.streamName,
    required this.rollNo,
  });

  factory CallbackStudent.fromJson(Map<String, dynamic> json) {
    return CallbackStudent(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      className: json['class_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      streamName: json['stream_name'],
      rollNo: json['roll_no'] ?? 'N/A',
    );
  }

  String get classSectionDisplay {
    final streamStr = (streamName != null && streamName!.isNotEmpty) ? ' ($streamName)' : '';
    final secStr = sectionName.isNotEmpty ? '-${sectionName.toUpperCase()}' : '';
    return '$className$secStr$streamStr';
  }
}

class CallbackNote {
  final String? callStatus;
  final String notes;
  final String? staffName;
  final String? createdAt;

  CallbackNote({
    this.callStatus,
    required this.notes,
    this.staffName,
    this.createdAt,
  });

  factory CallbackNote.fromJson(Map<String, dynamic> json) {
    return CallbackNote(
      callStatus: json['call_status'],
      notes: json['notes'] ?? '',
      staffName: json['staff_name'],
      createdAt: json['created_at'],
    );
  }
}

class CallbackMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  CallbackMeta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory CallbackMeta.fromJson(Map<String, dynamic> json) {
    return CallbackMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

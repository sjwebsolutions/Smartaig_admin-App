class EventTodayScansModel {
  final bool success;
  final String? message;
  final EventTodayScansData? data;

  EventTodayScansModel({
    required this.success,
    this.message,
    this.data,
  });

  factory EventTodayScansModel.fromJson(Map<String, dynamic> json) {
    return EventTodayScansModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? EventTodayScansData.fromJson(json['data']) : null,
    );
  }
}

class EventTodayScansData {
  final int totalValidScansToday;
  final List<EventScanItem> scans;

  EventTodayScansData({
    required this.totalValidScansToday,
    required this.scans,
  });

  factory EventTodayScansData.fromJson(Map<String, dynamic> json) {
    return EventTodayScansData(
      totalValidScansToday: json['total_valid_scans_today'] ?? 0,
      scans: (json['scans'] as List<dynamic>?)
              ?.map((x) => EventScanItem.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class EventScanItem {
  final int id;
  final String passNumber;
  final String eventTitle;
  final String studentName;
  final String admissionNo;
  final String classSection;
  final String scanStatus;
  final String scanMessage;
  final String gateName;
  final String scannedBy;
  final String scannedAt;
  final String scannedAtFull;

  EventScanItem({
    required this.id,
    required this.passNumber,
    required this.eventTitle,
    required this.studentName,
    required this.admissionNo,
    required this.classSection,
    required this.scanStatus,
    required this.scanMessage,
    required this.gateName,
    required this.scannedBy,
    required this.scannedAt,
    required this.scannedAtFull,
  });

  factory EventScanItem.fromJson(Map<String, dynamic> json) {
    return EventScanItem(
      id: json['id'] ?? 0,
      passNumber: json['pass_number'] ?? '',
      eventTitle: json['event_title'] ?? '',
      studentName: json['student_name'] ?? '',
      admissionNo: json['admission_no']?.toString() ?? '',
      classSection: json['class_section'] ?? '',
      scanStatus: json['scan_status'] ?? '',
      scanMessage: json['scan_message'] ?? '',
      gateName: json['gate_name'] ?? '',
      scannedBy: json['scanned_by'] ?? '',
      scannedAt: json['scanned_at'] ?? '',
      scannedAtFull: json['scanned_at_full'] ?? '',
    );
  }
}

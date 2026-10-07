class QrSettingsModel {
  final bool success;
  final QrSettingsData? data;
  final String? message;

  QrSettingsModel({
    required this.success,
    this.data,
    this.message,
  });

  factory QrSettingsModel.fromJson(Map<String, dynamic> json) {
    return QrSettingsModel(
      success: json['success'] is bool
          ? json['success']
          : (json['success'] == 1 || json['success'] == 'true'),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? QrSettingsData.fromJson(json['data'])
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class QrSettingsData {
  final bool qrAttendanceEnabled;
  final bool canScan;
  final String? permissionMessage;
  final bool autoAbsentEnabled;
  final String? autoAbsentCutoffTime;
  final ScannerInfo? scannerInfo;
  final QrStats? stats;

  QrSettingsData({
    required this.qrAttendanceEnabled,
    required this.canScan,
    this.permissionMessage,
    required this.autoAbsentEnabled,
    this.autoAbsentCutoffTime,
    this.scannerInfo,
    this.stats,
  });

  factory QrSettingsData.fromJson(Map<String, dynamic> json) {
    return QrSettingsData(
      qrAttendanceEnabled: json['qr_attendance_enabled'] is bool
          ? json['qr_attendance_enabled']
          : (json['qr_attendance_enabled'] == 1 || json['qr_attendance_enabled'] == 'true'),
      canScan: json['can_scan'] is bool
          ? json['can_scan']
          : (json['can_scan'] == 1 || json['can_scan'] == 'true'),
      permissionMessage: json['permission_message']?.toString(),
      autoAbsentEnabled: json['auto_absent_enabled'] is bool
          ? json['auto_absent_enabled']
          : (json['auto_absent_enabled'] == 1 || json['auto_absent_enabled'] == 'true'),
      autoAbsentCutoffTime: json['auto_absent_cutoff_time']?.toString(),
      scannerInfo: json['scanner_info'] != null && json['scanner_info'] is Map<String, dynamic>
          ? ScannerInfo.fromJson(json['scanner_info'])
          : null,
      stats: json['stats'] != null && json['stats'] is Map<String, dynamic>
          ? QrStats.fromJson(json['stats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_attendance_enabled': qrAttendanceEnabled,
      'can_scan': canScan,
      'permission_message': permissionMessage,
      'auto_absent_enabled': autoAbsentEnabled,
      'auto_absent_cutoff_time': autoAbsentCutoffTime,
      'scanner_info': scannerInfo?.toJson(),
      'stats': stats?.toJson(),
    };
  }
}

class ScannerInfo {
  final String? appRole;
  final String? scannerRole;
  final int? userId;
  final String? userName;

  ScannerInfo({
    this.appRole,
    this.scannerRole,
    this.userId,
    this.userName,
  });

  factory ScannerInfo.fromJson(Map<String, dynamic> json) {
    return ScannerInfo(
      appRole: json['app_role']?.toString(),
      scannerRole: json['scanner_role']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      userName: json['user_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_role': appRole,
      'scanner_role': scannerRole,
      'user_id': userId,
      'user_name': userName,
    };
  }
}

class QrStats {
  final int scannedByMeToday;
  final int totalPresentToday;

  QrStats({
    this.scannedByMeToday = 0,
    this.totalPresentToday = 0,
  });

  factory QrStats.fromJson(Map<String, dynamic> json) {
    return QrStats(
      scannedByMeToday: json['scanned_by_me_today'] is int
          ? json['scanned_by_me_today']
          : int.tryParse(json['scanned_by_me_today']?.toString() ?? '') ?? 0,
      totalPresentToday: json['total_present_today'] is int
          ? json['total_present_today']
          : int.tryParse(json['total_present_today']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanned_by_me_today': scannedByMeToday,
      'total_present_today': totalPresentToday,
    };
  }
}

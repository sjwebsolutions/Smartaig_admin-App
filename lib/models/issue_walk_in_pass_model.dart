class IssueWalkInPassResponseModel {
  final bool success;
  final String? message;
  final WalkInPassDataModel? data;

  IssueWalkInPassResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory IssueWalkInPassResponseModel.fromJson(Map<String, dynamic> json) {
    return IssueWalkInPassResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WalkInPassDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class WalkInPassDataModel {
  final int passId;
  final String passNumber;
  final String? approvalStatus;
  final String? checkinStatus;
  final String? qrPayload;
  final WalkInStudentModel? student;
  final List<WalkInAttendeeModel> attendees;
  final WalkInGateEntryModel? gateEntry;

  WalkInPassDataModel({
    required this.passId,
    required this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.qrPayload,
    this.student,
    required this.attendees,
    this.gateEntry,
  });

  factory WalkInPassDataModel.fromJson(Map<String, dynamic> json) {
    return WalkInPassDataModel(
      passId: json['pass_id'] is int
          ? json['pass_id']
          : int.tryParse(json['pass_id']?.toString() ?? '0') ?? 0,
      passNumber: json['pass_number']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      qrPayload: json['qr_payload']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? WalkInStudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => WalkInAttendeeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gateEntry: json['gate_entry'] != null && json['gate_entry'] is Map<String, dynamic>
          ? WalkInGateEntryModel.fromJson(json['gate_entry'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pass_id': passId,
      'pass_number': passNumber,
      'approval_status': approvalStatus,
      'checkin_status': checkinStatus,
      'qr_payload': qrPayload,
      'student': student?.toJson(),
      'attendees': attendees.map((e) => e.toJson()).toList(),
      'gate_entry': gateEntry?.toJson(),
    };
  }
}

class WalkInStudentModel {
  final int id;
  final String name;
  final String? className;
  final String? section;

  WalkInStudentModel({
    required this.id,
    required this.name,
    this.className,
    this.section,
  });

  factory WalkInStudentModel.fromJson(Map<String, dynamic> json) {
    return WalkInStudentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      className: json['class']?.toString(),
      section: json['section']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'class': className,
      'section': section,
    };
  }
}

class WalkInAttendeeModel {
  final int id;
  final String name;
  final String? personType;
  final String? mobileNo;
  final bool isCheckedIn;
  final String? photoUrl;

  WalkInAttendeeModel({
    required this.id,
    required this.name,
    this.personType,
    this.mobileNo,
    this.isCheckedIn = false,
    this.photoUrl,
  });

  factory WalkInAttendeeModel.fromJson(Map<String, dynamic> json) {
    return WalkInAttendeeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      personType: json['person_type']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      isCheckedIn: json['is_checked_in'] ?? false,
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'person_type': personType,
      'mobile_no': mobileNo,
      'is_checked_in': isCheckedIn,
      'photo_url': photoUrl,
    };
  }
}

class WalkInGateEntryModel {
  final bool isCheckedIn;
  final String? gateName;
  final int checkedInCount;
  final String? checkedInAt;

  WalkInGateEntryModel({
    this.isCheckedIn = false,
    this.gateName,
    this.checkedInCount = 0,
    this.checkedInAt,
  });

  factory WalkInGateEntryModel.fromJson(Map<String, dynamic> json) {
    return WalkInGateEntryModel(
      isCheckedIn: json['is_checked_in'] ?? false,
      gateName: json['gate_name']?.toString(),
      checkedInCount: json['checked_in_count'] is int
          ? json['checked_in_count']
          : int.tryParse(json['checked_in_count']?.toString() ?? '0') ?? 0,
      checkedInAt: json['checked_in_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_checked_in': isCheckedIn,
      'gate_name': gateName,
      'checked_in_count': checkedInCount,
      'checked_in_at': checkedInAt,
    };
  }
}

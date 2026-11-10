class EventPassApplicationsResponseModel {
  final bool success;
  final String? message;
  final List<EventPassApplicationModel> data;
  final int currentPage;
  final int perPage;
  final int totalCount;
  final int totalPages;

  EventPassApplicationsResponseModel({
    required this.success,
    this.message,
    required this.data,
    this.currentPage = 1,
    this.perPage = 20,
    this.totalCount = 0,
    this.totalPages = 1,
  });

  factory EventPassApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    List<dynamic>? rawList;
    if (json['data'] is List) {
      rawList = json['data'] as List<dynamic>;
    } else if (json['data'] is Map && json['data']['data'] is List) {
      rawList = json['data']['data'] as List<dynamic>;
    }

    return EventPassApplicationsResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: rawList
              ?.map((e) => EventPassApplicationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '20') ?? 20,
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
      totalPages: json['total_pages'] is int
          ? json['total_pages']
          : int.tryParse(json['total_pages']?.toString() ?? '1') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'current_page': currentPage,
      'per_page': perPage,
      'total_count': totalCount,
      'total_pages': totalPages,
    };
  }
}

class EventPassApplicationModel {
  final int id;
  final String? uuid;
  final String passNumber;
  final String? approvalStatus;
  final String? checkinStatus;
  final int totalAttendeesRequested;
  final int totalAttendeesApproved;
  final String? createdAt;
  final String? actionAt;
  final String? actionByName;
  final String? actionByRole;
  final String? adminRemarks;
  final EventPassStudentModel? student;
  final List<EventPassAttendeeModel> attendees;

  EventPassApplicationModel({
    required this.id,
    this.uuid,
    required this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
    this.totalAttendeesRequested = 0,
    this.totalAttendeesApproved = 0,
    this.createdAt,
    this.actionAt,
    this.actionByName,
    this.actionByRole,
    this.adminRemarks,
    this.student,
    required this.attendees,
  });

  factory EventPassApplicationModel.fromJson(Map<String, dynamic> json) {
    return EventPassApplicationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      uuid: json['uuid']?.toString(),
      passNumber: json['pass_number']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
      totalAttendeesRequested: json['total_attendees_requested'] is int
          ? json['total_attendees_requested']
          : int.tryParse(json['total_attendees_requested']?.toString() ?? '0') ?? 0,
      totalAttendeesApproved: json['total_attendees_approved'] is int
          ? json['total_attendees_approved']
          : int.tryParse(json['total_attendees_approved']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString(),
      actionAt: json['action_at']?.toString(),
      actionByName: json['action_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      adminRemarks: json['admin_remarks']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? EventPassStudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => EventPassAttendeeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'pass_number': passNumber,
      'approval_status': approvalStatus,
      'checkin_status': checkinStatus,
      'total_attendees_requested': totalAttendeesRequested,
      'total_attendees_approved': totalAttendeesApproved,
      'created_at': createdAt,
      'action_at': actionAt,
      'action_by_name': actionByName,
      'action_by_role': actionByRole,
      'admin_remarks': adminRemarks,
      'student': student?.toJson(),
      'attendees': attendees.map((e) => e.toJson()).toList(),
    };
  }
}

class EventPassStudentModel {
  final int id;
  final String name;
  final String admissionNumber;
  final String? rollNo;
  final String? className;
  final String? section;
  final String? stream;
  final String? photoUrl;

  EventPassStudentModel({
    required this.id,
    required this.name,
    required this.admissionNumber,
    this.rollNo,
    this.className,
    this.section,
    this.stream,
    this.photoUrl,
  });

  factory EventPassStudentModel.fromJson(Map<String, dynamic> json) {
    return EventPassStudentModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      admissionNumber: json['admission_number']?.toString() ?? '',
      rollNo: json['roll_no']?.toString(),
      className: json['class']?.toString(),
      section: json['section']?.toString(),
      stream: json['stream']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'admission_number': admissionNumber,
      'roll_no': rollNo,
      'class': className,
      'section': section,
      'stream': stream,
      'photo_url': photoUrl,
    };
  }
}

class EventPassAttendeeModel {
  final int id;
  final String name;
  final String? personType;
  final String? mobileNo;
  final String? whatsappNo;
  final String? aadhaarMasked;
  final String? approvalStatus;
  final String? rejectionReason;
  final bool isCheckedIn;
  final String? checkedInAt;
  final String? photoUrl;

  EventPassAttendeeModel({
    required this.id,
    required this.name,
    this.personType,
    this.mobileNo,
    this.whatsappNo,
    this.aadhaarMasked,
    this.approvalStatus,
    this.rejectionReason,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.photoUrl,
  });

  factory EventPassAttendeeModel.fromJson(Map<String, dynamic> json) {
    return EventPassAttendeeModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      personType: json['person_type']?.toString(),
      mobileNo: json['mobile_no']?.toString(),
      whatsappNo: json['whatsapp_no']?.toString(),
      aadhaarMasked: json['aadhaar_masked']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      isCheckedIn: json['is_checked_in'] ?? false,
      checkedInAt: json['checked_in_at']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'person_type': personType,
      'mobile_no': mobileNo,
      'whatsapp_no': whatsappNo,
      'aadhaar_masked': aadhaarMasked,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'is_checked_in': isCheckedIn,
      'checked_in_at': checkedInAt,
      'photo_url': photoUrl,
    };
  }
}

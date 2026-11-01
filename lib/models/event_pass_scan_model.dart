class EventPassScanModel {
  final bool success;
  final String? message;
  final bool isAlreadyCheckedIn;
  final bool canCheckin;
  final String? warning;
  final EventPassScanData? data;

  EventPassScanModel({
    required this.success,
    this.message,
    this.isAlreadyCheckedIn = false,
    this.canCheckin = false,
    this.warning,
    this.data,
  });

  factory EventPassScanModel.fromJson(Map<String, dynamic> json) {
    return EventPassScanModel(
      success: json['success'] ?? false,
      message: json['message'],
      isAlreadyCheckedIn: json['is_already_checked_in'] ?? false,
      canCheckin: json['can_checkin'] ?? false,
      warning: json['warning'],
      data: json['data'] != null ? EventPassScanData.fromJson(json['data']) : null,
    );
  }
}

class EventPassScanData {
  final EventPassDetails? pass;
  final EventDetails? event;
  final EventStudentDetails? student;
  final List<EventAttendee> approvedAttendees;
  final List<EventAttendee> rejectedAttendees;

  EventPassScanData({
    this.pass,
    this.event,
    this.student,
    required this.approvedAttendees,
    required this.rejectedAttendees,
  });

  factory EventPassScanData.fromJson(Map<String, dynamic> json) {
    return EventPassScanData(
      pass: json['pass'] != null ? EventPassDetails.fromJson(json['pass']) : null,
      event: json['event'] != null ? EventDetails.fromJson(json['event']) : null,
      student: json['student'] != null ? EventStudentDetails.fromJson(json['student']) : null,
      approvedAttendees: (json['approved_attendees'] as List<dynamic>?)
              ?.map((x) => EventAttendee.fromJson(x))
              .toList() ??
          [],
      rejectedAttendees: (json['rejected_attendees'] as List<dynamic>?)
              ?.map((x) => EventAttendee.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class EventPassDetails {
  final int id;
  final String uuid;
  final String passNumber;
  final String approvalStatus;
  final String checkinStatus;
  final String firstCheckinAt;
  final int totalAttendeesRequested;
  final int totalAttendeesApproved;
  final int totalCheckedIn;
  final int totalRemaining;

  EventPassDetails({
    required this.id,
    required this.uuid,
    required this.passNumber,
    required this.approvalStatus,
    required this.checkinStatus,
    required this.firstCheckinAt,
    required this.totalAttendeesRequested,
    required this.totalAttendeesApproved,
    required this.totalCheckedIn,
    required this.totalRemaining,
  });

  factory EventPassDetails.fromJson(Map<String, dynamic> json) {
    return EventPassDetails(
      id: json['id'] ?? 0,
      uuid: json['uuid'] ?? '',
      passNumber: json['pass_number'] ?? '',
      approvalStatus: json['approval_status'] ?? '',
      checkinStatus: json['checkin_status'] ?? '',
      firstCheckinAt: json['first_checkin_at'] ?? '',
      totalAttendeesRequested: json['total_attendees_requested'] ?? 0,
      totalAttendeesApproved: json['total_attendees_approved'] ?? 0,
      totalCheckedIn: json['total_checked_in'] ?? 0,
      totalRemaining: json['total_remaining'] ?? 0,
    );
  }
}

class EventDetails {
  final int id;
  final String title;
  final String venue;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;

  EventDetails({
    required this.id,
    required this.title,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      venue: json['venue'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class EventStudentDetails {
  final int id;
  final String studentName;
  final String? studentNamePunjabi;
  final String admissionNumber;
  final String rollNo;
  final String studentUniqueId;
  final String className;
  final String section;
  final String classSection;
  final String fatherName;
  final String fatherMobile;
  final String motherName;
  final String motherMobile;
  final String photoUrl;

  EventStudentDetails({
    required this.id,
    required this.studentName,
    this.studentNamePunjabi,
    required this.admissionNumber,
    required this.rollNo,
    required this.studentUniqueId,
    required this.className,
    required this.section,
    required this.classSection,
    required this.fatherName,
    required this.fatherMobile,
    required this.motherName,
    required this.motherMobile,
    required this.photoUrl,
  });

  factory EventStudentDetails.fromJson(Map<String, dynamic> json) {
    return EventStudentDetails(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      studentNamePunjabi: json['student_name_punjabi'],
      admissionNumber: json['admission_number']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      studentUniqueId: json['student_unique_id']?.toString() ?? '',
      className: json['class'] ?? '',
      section: json['section'] ?? '',
      classSection: json['class_section'] ?? '',
      fatherName: json['father_name'] ?? '',
      fatherMobile: json['father_mobile'] ?? '',
      motherName: json['mother_name'] ?? '',
      motherMobile: json['mother_mobile'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }
}

class EventAttendee {
  final int id;
  final String name;
  final String personType;
  final String mobileNo;
  final String maskedAadhaar;
  final String photoUrl;
  final bool isCheckedIn;
  final String checkedInAt;

  EventAttendee({
    required this.id,
    required this.name,
    required this.personType,
    required this.mobileNo,
    required this.maskedAadhaar,
    required this.photoUrl,
    required this.isCheckedIn,
    required this.checkedInAt,
  });

  factory EventAttendee.fromJson(Map<String, dynamic> json) {
    return EventAttendee(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      personType: json['person_type'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      maskedAadhaar: json['masked_aadhaar'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      isCheckedIn: json['is_checked_in'] ?? false,
      checkedInAt: json['checked_in_at'] ?? '',
    );
  }
}

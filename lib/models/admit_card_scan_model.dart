class AdmitCardScanResponseModel {
  final bool success;
  final String? message;
  final AdmitCardScanData? data;

  AdmitCardScanResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory AdmitCardScanResponseModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardScanResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: json['data'] != null ? AdmitCardScanData.fromJson(json['data']) : null,
    );
  }
}

class AdmitCardScanData {
  final StudentInfo? student;
  final AdmitCardInfo? admitCard;
  final List<DatesheetScheduleItem> datesheetSchedule;
  final SeatingPlanInfo? seatingPlan;
  final FeeBalanceInfo? feeBalance;

  AdmitCardScanData({
    this.student,
    this.admitCard,
    this.datesheetSchedule = const [],
    this.seatingPlan,
    this.feeBalance,
  });

  factory AdmitCardScanData.fromJson(Map<String, dynamic> json) {
    return AdmitCardScanData(
      student: json['student'] != null ? StudentInfo.fromJson(json['student']) : null,
      admitCard: json['admit_card'] != null ? AdmitCardInfo.fromJson(json['admit_card']) : null,
      datesheetSchedule: (json['datesheet_schedule'] as List? ?? [])
          .map((item) => DatesheetScheduleItem.fromJson(item))
          .toList(),
      seatingPlan: json['seating_plan'] != null ? SeatingPlanInfo.fromJson(json['seating_plan']) : null,
      feeBalance: json['fee_balance'] != null ? FeeBalanceInfo.fromJson(json['fee_balance']) : null,
    );
  }
}

class StudentInfo {
  final int? id;
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final String? admissionNumber;
  final String? studentUniqueId;
  final String? rollNo;
  final String? examRollNo;
  final String? dob;
  final String? formattedDob;
  final String? gender;
  final String? studentClass;
  final String? section;
  final String? stream;
  final String? session;
  final String? classSection;
  final String? photoUrl;
  final String? fatherMobile;
  final String? motherMobile;
  final String? status;

  StudentInfo({
    this.id,
    this.studentName,
    this.fatherName,
    this.motherName,
    this.admissionNumber,
    this.studentUniqueId,
    this.rollNo,
    this.examRollNo,
    this.dob,
    this.formattedDob,
    this.gender,
    this.studentClass,
    this.section,
    this.stream,
    this.session,
    this.classSection,
    this.photoUrl,
    this.fatherMobile,
    this.motherMobile,
    this.status,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      studentName: json['student_name']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      admissionNumber: json['admission_number']?.toString(),
      studentUniqueId: json['student_unique_id']?.toString(),
      rollNo: json['roll_no']?.toString(),
      examRollNo: json['exam_roll_no']?.toString(),
      dob: json['dob']?.toString(),
      formattedDob: json['formatted_dob']?.toString(),
      gender: json['gender']?.toString(),
      studentClass: json['class']?.toString(),
      section: json['section']?.toString(),
      stream: json['stream']?.toString(),
      session: json['session']?.toString(),
      classSection: json['class_section']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      fatherMobile: json['father_mobile']?.toString(),
      motherMobile: json['mother_mobile']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

class AdmitCardInfo {
  final int? id;
  final int? dateSheetId;
  final String? examTitle;
  final String? session;
  final String? examCenterCode;
  final String? centerSchoolCode;
  final String? examCenterName;
  final String? startTime;
  final String? endTime;
  final String? examStartDate;
  final String? examEndDate;

  AdmitCardInfo({
    this.id,
    this.dateSheetId,
    this.examTitle,
    this.session,
    this.examCenterCode,
    this.centerSchoolCode,
    this.examCenterName,
    this.startTime,
    this.endTime,
    this.examStartDate,
    this.examEndDate,
  });

  factory AdmitCardInfo.fromJson(Map<String, dynamic> json) {
    return AdmitCardInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      dateSheetId: json['date_sheet_id'] is int
          ? json['date_sheet_id']
          : int.tryParse(json['date_sheet_id']?.toString() ?? ''),
      examTitle: json['exam_title']?.toString(),
      session: json['session']?.toString(),
      examCenterCode: json['exam_center_code']?.toString(),
      centerSchoolCode: json['center_school_code']?.toString(),
      examCenterName: json['exam_center_name']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      examStartDate: json['exam_start_date']?.toString(),
      examEndDate: json['exam_end_date']?.toString(),
    );
  }
}

class DatesheetScheduleItem {
  final int? id;
  final String? examDate;
  final String? formattedDate;
  final String? day;
  final String? subjectName;
  final String? subjectCode;
  final String? timing;
  final String? type;

  DatesheetScheduleItem({
    this.id,
    this.examDate,
    this.formattedDate,
    this.day,
    this.subjectName,
    this.subjectCode,
    this.timing,
    this.type,
  });

  factory DatesheetScheduleItem.fromJson(Map<String, dynamic> json) {
    return DatesheetScheduleItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      examDate: json['exam_date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      day: json['day']?.toString(),
      subjectName: json['subject_name']?.toString(),
      subjectCode: json['subject_code']?.toString(),
      timing: json['timing']?.toString(),
      type: json['type']?.toString(),
    );
  }
}

class SeatingPlanInfo {
  final bool isAssigned;
  final String? status;
  final int? totalExams;
  final int? assignedExams;
  final String? arrangementName;
  final TodaySeatInfo? todaySeat;
  final List<SeatItemInfo> allSeats;

  SeatingPlanInfo({
    this.isAssigned = false,
    this.status,
    this.totalExams,
    this.assignedExams,
    this.arrangementName,
    this.todaySeat,
    this.allSeats = const [],
  });

  factory SeatingPlanInfo.fromJson(Map<String, dynamic> json) {
    return SeatingPlanInfo(
      isAssigned: json['is_assigned'] == true,
      status: json['status']?.toString(),
      totalExams: json['total_exams'] is int
          ? json['total_exams']
          : int.tryParse(json['total_exams']?.toString() ?? ''),
      assignedExams: json['assigned_exams'] is int
          ? json['assigned_exams']
          : int.tryParse(json['assigned_exams']?.toString() ?? ''),
      arrangementName: json['arrangement_name']?.toString(),
      todaySeat: json['today_seat'] != null ? TodaySeatInfo.fromJson(json['today_seat']) : null,
      allSeats: (json['all_seats'] as List? ?? [])
          .map((item) => SeatItemInfo.fromJson(item))
          .toList(),
    );
  }
}

class TodaySeatInfo {
  final String? examDate;
  final String? formattedDate;
  final String? day;
  final String? subject;
  final bool isAssigned;
  final int? roomId;
  final String? roomName;
  final int? rowNo;
  final int? deskNo;
  final int? seatPosition;
  final String? seatPositionLabel;
  final String? seatLabel;
  final String? message;
  final bool hasExamToday;

  TodaySeatInfo({
    this.examDate,
    this.formattedDate,
    this.day,
    this.subject,
    this.isAssigned = false,
    this.roomId,
    this.roomName,
    this.rowNo,
    this.deskNo,
    this.seatPosition,
    this.seatPositionLabel,
    this.seatLabel,
    this.message,
    this.hasExamToday = false,
  });

  factory TodaySeatInfo.fromJson(Map<String, dynamic> json) {
    return TodaySeatInfo(
      examDate: json['exam_date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      day: json['day']?.toString(),
      subject: json['subject']?.toString(),
      isAssigned: json['is_assigned'] == true,
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      roomName: json['room_name']?.toString(),
      rowNo: json['row_no'] is int ? json['row_no'] : int.tryParse(json['row_no']?.toString() ?? ''),
      deskNo: json['desk_no'] is int ? json['desk_no'] : int.tryParse(json['desk_no']?.toString() ?? ''),
      seatPosition: json['seat_position'] is int
          ? json['seat_position']
          : int.tryParse(json['seat_position']?.toString() ?? ''),
      seatPositionLabel: json['seat_position_label']?.toString(),
      seatLabel: json['seat_label']?.toString(),
      message: json['message']?.toString(),
      hasExamToday: json['has_exam_today'] == true,
    );
  }
}

class SeatItemInfo {
  final String? examDate;
  final String? formattedDate;
  final String? day;
  final String? subject;
  final bool isAssigned;
  final int? roomId;
  final String? roomName;
  final int? rowNo;
  final int? deskNo;
  final int? seatPosition;
  final String? seatPositionLabel;
  final String? seatLabel;
  final String? message;

  SeatItemInfo({
    this.examDate,
    this.formattedDate,
    this.day,
    this.subject,
    this.isAssigned = false,
    this.roomId,
    this.roomName,
    this.rowNo,
    this.deskNo,
    this.seatPosition,
    this.seatPositionLabel,
    this.seatLabel,
    this.message,
  });

  factory SeatItemInfo.fromJson(Map<String, dynamic> json) {
    return SeatItemInfo(
      examDate: json['exam_date']?.toString(),
      formattedDate: json['formatted_date']?.toString(),
      day: json['day']?.toString(),
      subject: json['subject']?.toString(),
      isAssigned: json['is_assigned'] == true,
      roomId: json['room_id'] is int ? json['room_id'] : int.tryParse(json['room_id']?.toString() ?? ''),
      roomName: json['room_name']?.toString(),
      rowNo: json['row_no'] is int ? json['row_no'] : int.tryParse(json['row_no']?.toString() ?? ''),
      deskNo: json['desk_no'] is int ? json['desk_no'] : int.tryParse(json['desk_no']?.toString() ?? ''),
      seatPosition: json['seat_position'] is int
          ? json['seat_position']
          : int.tryParse(json['seat_position']?.toString() ?? ''),
      seatPositionLabel: json['seat_position_label']?.toString(),
      seatLabel: json['seat_label']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class FeeBalanceInfo {
  final bool hasDue;
  final String? status;
  final num? balanceTillToday;
  final String? formattedBalance;
  final String? message;

  FeeBalanceInfo({
    this.hasDue = false,
    this.status,
    this.balanceTillToday,
    this.formattedBalance,
    this.message,
  });

  factory FeeBalanceInfo.fromJson(Map<String, dynamic> json) {
    return FeeBalanceInfo(
      hasDue: json['has_due'] == true,
      status: json['status']?.toString(),
      balanceTillToday: json['balance_till_today'] is num
          ? json['balance_till_today']
          : num.tryParse(json['balance_till_today']?.toString() ?? ''),
      formattedBalance: json['formatted_balance']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

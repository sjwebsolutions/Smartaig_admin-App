class InvigilatorDutyResponse {
  final bool success;
  final List<InvigilatorDuty> data;

  InvigilatorDutyResponse({
    required this.success,
    required this.data,
  });

  factory InvigilatorDutyResponse.fromJson(Map<String, dynamic> json) {
    return InvigilatorDutyResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((item) => InvigilatorDuty.fromJson(item))
          .toList(),
    );
  }
}

class InvigilatorDuty {
  final int id;
  final String name;
  final String session;
  final Datesheet datesheet;
  final String? firstExamDate;
  final String? lastExamDate;
  final int totalExamDates;
  final int totalRooms;
  final int totalDutiesAssigned;
  final int uniqueTeachersAssigned;

  InvigilatorDuty({
    required this.id,
    required this.name,
    required this.session,
    required this.datesheet,
    this.firstExamDate,
    this.lastExamDate,
    required this.totalExamDates,
    required this.totalRooms,
    required this.totalDutiesAssigned,
    required this.uniqueTeachersAssigned,
  });

  factory InvigilatorDuty.fromJson(Map<String, dynamic> json) {
    return InvigilatorDuty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      session: json['session'] ?? '',
      datesheet: Datesheet.fromJson(json['datesheet'] ?? {}),
      firstExamDate: json['first_exam_date'],
      lastExamDate: json['last_exam_date'],
      totalExamDates: json['total_exam_dates'] ?? 0,
      totalRooms: json['total_rooms'] ?? 0,
      totalDutiesAssigned: json['total_duties_assigned'] ?? 0,
      uniqueTeachersAssigned: json['unique_teachers_assigned'] ?? 0,
    );
  }
}

class Datesheet {
  final int id;
  final String name;
  final String startDate;
  final String endDate;

  Datesheet({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  factory Datesheet.fromJson(Map<String, dynamic> json) {
    return Datesheet(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

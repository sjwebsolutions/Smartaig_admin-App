class SeatingPlanResponse {
  final bool success;
  final String? message;
  final List<SeatingPlan> data;

  SeatingPlanResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory SeatingPlanResponse.fromJson(Map<String, dynamic> json) {
    return SeatingPlanResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      data: (json['data'] as List? ?? [])
          .map((item) => SeatingPlan.fromJson(item))
          .toList(),
    );
  }
}

class SeatingPlan {
  final int id;
  final String name;
  final String session;
  final bool status;
  final Datesheet datesheet;
  final String? firstExamDate;
  final String? lastExamDate;
  final int totalExamDates;
  final int totalRooms;

  SeatingPlan({
    required this.id,
    required this.name,
    required this.session,
    this.status = true,
    required this.datesheet,
    this.firstExamDate,
    this.lastExamDate,
    required this.totalExamDates,
    required this.totalRooms,
  });

  factory SeatingPlan.fromJson(Map<String, dynamic> json) {
    return SeatingPlan(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      status: json['status'] == true || json['status'] == 1 || json['status'] == '1',
      datesheet: Datesheet.fromJson(json['datesheet'] ?? {}),
      firstExamDate: json['first_exam_date']?.toString(),
      lastExamDate: json['last_exam_date']?.toString(),
      totalExamDates: json['total_exam_dates'] is int
          ? json['total_exam_dates']
          : int.tryParse(json['total_exam_dates']?.toString() ?? '0') ?? 0,
      totalRooms: json['total_rooms'] is int
          ? json['total_rooms']
          : int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
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
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }
}

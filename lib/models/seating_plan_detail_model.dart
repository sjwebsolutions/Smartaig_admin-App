class SeatingPlanDetailResponse {
  final bool success;
  final SeatingPlanDetailData? data;

  SeatingPlanDetailResponse({
    required this.success,
    this.data,
  });

  factory SeatingPlanDetailResponse.fromJson(Map<String, dynamic> json) {
    return SeatingPlanDetailResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? SeatingPlanDetailData.fromJson(json['data']) : null,
    );
  }
}

class SeatingPlanDetailData {
  final PlanInfo plan;
  final String? examTiming;
  final int totalDates;
  final int totalBuiltDates;
  final List<SeatingPlanDateItem> dates;

  SeatingPlanDetailData({
    required this.plan,
    this.examTiming,
    required this.totalDates,
    required this.totalBuiltDates,
    required this.dates,
  });

  factory SeatingPlanDetailData.fromJson(Map<String, dynamic> json) {
    return SeatingPlanDetailData(
      plan: PlanInfo.fromJson(json['plan'] ?? {}),
      examTiming: json['exam_timing']?.toString(),
      totalDates: json['total_dates'] is int
          ? json['total_dates']
          : int.tryParse(json['total_dates']?.toString() ?? '0') ?? 0,
      totalBuiltDates: json['total_built_dates'] is int
          ? json['total_built_dates']
          : int.tryParse(json['total_built_dates']?.toString() ?? '0') ?? 0,
      dates: (json['dates'] as List? ?? [])
          .map((item) => SeatingPlanDateItem.fromJson(item))
          .toList(),
    );
  }
}

class PlanInfo {
  final int id;
  final String name;
  final String session;
  final String schoolName;
  final String datesheetName;
  final int totalRooms;

  PlanInfo({
    required this.id,
    required this.name,
    required this.session,
    required this.schoolName,
    required this.datesheetName,
    required this.totalRooms,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) {
    return PlanInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      datesheetName: json['datesheet_name']?.toString() ?? '',
      totalRooms: json['total_rooms'] is int
          ? json['total_rooms']
          : int.tryParse(json['total_rooms']?.toString() ?? '0') ?? 0,
    );
  }
}

class SeatingPlanDateItem {
  final String date;
  final String dayName;
  final String formattedDate;
  final bool isBuilt;
  final String statusLabel;
  final int totalStudents;
  final int totalRoomsUsed;
  final String? pdfUrl;

  SeatingPlanDateItem({
    required this.date,
    required this.dayName,
    required this.formattedDate,
    required this.isBuilt,
    required this.statusLabel,
    required this.totalStudents,
    required this.totalRoomsUsed,
    this.pdfUrl,
  });

  factory SeatingPlanDateItem.fromJson(Map<String, dynamic> json) {
    return SeatingPlanDateItem(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      isBuilt: json['is_built'] == true || json['is_built'] == 1 || json['is_built'] == '1',
      statusLabel: json['status_label']?.toString() ?? 'Not Built',
      totalStudents: json['total_students'] is int
          ? json['total_students']
          : int.tryParse(json['total_students']?.toString() ?? '0') ?? 0,
      totalRoomsUsed: json['total_rooms_used'] is int
          ? json['total_rooms_used']
          : int.tryParse(json['total_rooms_used']?.toString() ?? '0') ?? 0,
      pdfUrl: json['pdf_url']?.toString(),
    );
  }
}

class StudentCountModel {
  final bool success;
  final StudentCountData? data;

  StudentCountModel({
    required this.success,
    this.data,
  });

  factory StudentCountModel.fromJson(Map<String, dynamic> json) {
    return StudentCountModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? StudentCountData.fromJson(json['data']) : null,
    );
  }
}

class StudentCountData {
  final String date;
  final String academicYear;
  final OverallStats overallStats;
  final List<ClassWiseCount> classWiseCounts;

  StudentCountData({
    required this.date,
    required this.academicYear,
    required this.overallStats,
    required this.classWiseCounts,
  });

  factory StudentCountData.fromJson(Map<String, dynamic> json) {
    return StudentCountData(
      date: json['date'] ?? '',
      academicYear: json['academic_year'] ?? '',
      overallStats: OverallStats.fromJson(json['overall_stats'] ?? {}),
      classWiseCounts: (json['class_wise_counts'] as List? ?? [])
          .map((i) => ClassWiseCount.fromJson(i))
          .toList(),
    );
  }
}

class OverallStats {
  final int boysTotal;
  final int girlsTotal;
  final int overallTotal;

  OverallStats({
    required this.boysTotal,
    required this.girlsTotal,
    required this.overallTotal,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      boysTotal: json['boys_total'] ?? 0,
      girlsTotal: json['girls_total'] ?? 0,
      overallTotal: json['overall_total'] ?? 0,
    );
  }
}

class ClassWiseCount {
  final String className;
  final String streamName;
  final String sectionName;
  final int boys;
  final int girls;
  final int total;

  ClassWiseCount({
    required this.className,
    required this.streamName,
    required this.sectionName,
    required this.boys,
    required this.girls,
    required this.total,
  });

  factory ClassWiseCount.fromJson(Map<String, dynamic> json) {
    return ClassWiseCount(
      className: json['class_name'] ?? '',
      streamName: json['stream_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      boys: json['boys'] ?? 0,
      girls: json['girls'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

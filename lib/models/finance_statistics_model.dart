class FinanceStatisticsModel {
  final bool success;
  final FinanceData? data;

  FinanceStatisticsModel({
    required this.success,
    this.data,
  });

  factory FinanceStatisticsModel.fromJson(Map<String, dynamic> json) {
    return FinanceStatisticsModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? FinanceData.fromJson(json['data']) : null,
    );
  }
}

class FinanceData {
  final String session;
  final FinanceItem fees;
  final FinanceItem books;
  final FinanceItem uniforms;
  final FinanceItem stationary;

  FinanceData({
    required this.session,
    required this.fees,
    required this.books,
    required this.uniforms,
    required this.stationary,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) {
    return FinanceData(
      session: json['session'] ?? '',
      fees: FinanceItem.fromJson(json['fees'] ?? {}),
      books: FinanceItem.fromJson(json['books'] ?? {}),
      uniforms: FinanceItem.fromJson(json['uniforms'] ?? {}),
      stationary: FinanceItem.fromJson(json['stationary'] ?? {}),
    );
  }
}

class FinanceItem {
  final num totalReceived;
  final num todayCollection;
  final num balanceTillToday;

  FinanceItem({
    required this.totalReceived,
    required this.todayCollection,
    required this.balanceTillToday,
  });

  factory FinanceItem.fromJson(Map<String, dynamic> json) {
    return FinanceItem(
      totalReceived: json['total_received'] ?? 0,
      todayCollection: json['today_collection'] ?? 0,
      balanceTillToday: json['balance_till_today'] ?? 0,
    );
  }
}

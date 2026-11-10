class UpdatePassStatusResponseModel {
  final bool success;
  final String? message;
  final String? action;
  final String? newStatus;
  final int updatedCount;
  final List<int> updatedIds;

  UpdatePassStatusResponseModel({
    required this.success,
    this.message,
    this.action,
    this.newStatus,
    this.updatedCount = 0,
    required this.updatedIds,
  });

  factory UpdatePassStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdatePassStatusResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString(),
      action: json['action']?.toString(),
      newStatus: json['new_status']?.toString(),
      updatedCount: json['updated_count'] is int
          ? json['updated_count']
          : int.tryParse(json['updated_count']?.toString() ?? '0') ?? 0,
      updatedIds: (json['updated_ids'] as List<dynamic>?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'action': action,
      'new_status': newStatus,
      'updated_count': updatedCount,
      'updated_ids': updatedIds,
    };
  }
}

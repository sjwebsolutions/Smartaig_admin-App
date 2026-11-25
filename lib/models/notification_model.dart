class NotificationResponseModel {
  final bool success;
  final String message;
  final NotificationData? data;

  NotificationResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
    );
  }
}

class NotificationData {
  final List<AppNotification> notifications;
  final int retentionDays;
  final NotificationPagination? pagination;

  NotificationData({
    required this.notifications,
    this.retentionDays = 7,
    this.pagination,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    var notifList = json['notifications'] as List? ?? [];
    List<AppNotification> list =
        notifList.map((e) => AppNotification.fromJson(e)).toList();

    return NotificationData(
      notifications: list,
      retentionDays: json['retention_days'] ?? 7,
      pagination: json['pagination'] != null
          ? NotificationPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class AppNotification {
  final int id;
  final String module;
  final String title;
  final String body;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String timeAgo;

  AppNotification({
    required this.id,
    required this.module,
    required this.title,
    required this.body,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      module: json['module'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      isRead: json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read'] == '1',
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }
}

class NotificationPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  NotificationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 30,
      total: json['total'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

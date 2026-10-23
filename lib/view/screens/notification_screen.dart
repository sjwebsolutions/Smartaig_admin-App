import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/announcement_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/notification_controller.dart';

class _TimeParts {
  final int hour;
  final int minute;
  final int second;

  _TimeParts(this.hour, this.minute, [this.second = 0]);
}

class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String date;
  final String? time;
  final String category; // 'Announcements', 'Callbacks', 'Leaves'
  final Color color;
  final IconData icon;
  final DateTime? dateTime;
  final int sortOrder;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.time,
    required this.category,
    required this.color,
    required this.icon,
    this.dateTime,
    this.sortOrder = 0,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const int _pageSize = 10;
  int _displayedCount = 10;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final AnnouncementController _announcementController = Get.isRegistered<AnnouncementController>()
      ? Get.find<AnnouncementController>()
      : Get.put(AnnouncementController());

  final DashboardController _dashboardController = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    _announcementController.fetchAnnouncements();
    _dashboardController.fetchDashboardData();
    _scrollController.addListener(_onScroll);

    // Clear unread count on opening screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationController.to.markAsViewed();
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 60) {
      final total = _buildNotificationItems().length;
      if (_displayedCount < total && !_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            setState(() {
              _displayedCount = (_displayedCount + _pageSize).clamp(0, total);
              _isLoadingMore = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _displayedCount = _pageSize;
    });
    await Future.wait([
      _announcementController.fetchAnnouncements(),
      _dashboardController.fetchDashboardData(),
    ]);
    final total = _buildNotificationItems().length;
    NotificationController.to.markAsViewed(total);
  }

  DateTime? _parseItemDateTime(String dateStr, String? timeStr, String? createdAtStr) {
    if (createdAtStr != null && createdAtStr.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(createdAtStr.trim());
      if (parsed != null) return parsed;
    }
    if (dateStr.trim().isEmpty) return null;
    DateTime? baseDate = DateTime.tryParse(dateStr.trim());
    if (baseDate == null) {
      final parts = dateStr.trim().split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        int? d, m, y;
        if (parts[0].length == 4) {
          y = int.tryParse(parts[0]);
          m = int.tryParse(parts[1]);
          d = int.tryParse(parts[2]);
        } else {
          d = int.tryParse(parts[0]);
          m = int.tryParse(parts[1]);
          y = int.tryParse(parts[2]);
        }
        if (y != null && m != null && d != null) {
          baseDate = DateTime(y, m, d);
        }
      }
    }
    if (baseDate != null) {
      if (timeStr != null && timeStr.trim().isNotEmpty) {
        final t = _parseTimeParts(timeStr.trim());
        if (t != null) {
          return DateTime(baseDate.year, baseDate.month, baseDate.day, t.hour, t.minute, t.second);
        }
      }
      return baseDate;
    }
    return null;
  }

  _TimeParts? _parseTimeParts(String timeStr) {
    try {
      final upper = timeStr.trim().toUpperCase();
      final isPm = upper.contains('PM');
      final isAm = upper.contains('AM');
      final digitsAndColons = upper.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = digitsAndColons.split(':');
      if (parts.isNotEmpty) {
        int h = int.tryParse(parts[0]) ?? 0;
        int m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        int s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
        if (isPm && h < 12) h += 12;
        if (isAm && h == 12) h = 0;
        return _TimeParts(h, m, s);
      }
    } catch (_) {}
    return null;
  }

  String _formatDateString(String rawDate, DateTime? parsedDt) {
    if (parsedDt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${parsedDt.day.toString().padLeft(2, '0')} ${months[parsedDt.month - 1]} ${parsedDt.year}';
    }
    return rawDate.isNotEmpty ? rawDate : '';
  }

  String? _formatTimeString(String? rawTime, DateTime? parsedDt) {
    if (rawTime != null && rawTime.trim().isNotEmpty) {
      final trimmed = rawTime.trim();
      if (trimmed.toUpperCase().contains('AM') || trimmed.toUpperCase().contains('PM')) {
        return trimmed;
      }
      final t = _parseTimeParts(trimmed);
      if (t != null) {
        int h = t.hour;
        final period = h >= 12 ? 'PM' : 'AM';
        h = h % 12;
        if (h == 0) h = 12;
        final m = t.minute.toString().padLeft(2, '0');
        return '$h:$m $period';
      }
      return trimmed;
    }
    if (parsedDt != null && (parsedDt.hour != 0 || parsedDt.minute != 0)) {
      int h = parsedDt.hour;
      final period = h >= 12 ? 'PM' : 'AM';
      h = h % 12;
      if (h == 0) h = 12;
      final m = parsedDt.minute.toString().padLeft(2, '0');
      return '$h:$m $period';
    }
    return null;
  }

  List<NotificationItemModel> _buildNotificationItems() {
    final List<NotificationItemModel> items = [];

    // 1. Announcements
    for (var ann in _announcementController.announcements) {
      final parsedDt = _parseItemDateTime(
        ann.fromDate,
        ann.fromTime,
        ann.createdAt,
      );
      final formattedDate = _formatDateString(ann.fromDate, parsedDt);
      final formattedTime = _formatTimeString(ann.fromTime, parsedDt);

      items.add(
        NotificationItemModel(
          id: ann.id.toString(),
          title: ann.title.isNotEmpty ? ann.title : "Announcement",
          message: ann.description.isNotEmpty ? ann.description : "New announcement posted",
          date: formattedDate,
          time: formattedTime,
          category: 'Announcements',
          color: const Color(0xFF0EA5E9),
          icon: Icons.campaign_rounded,
          dateTime: parsedDt,
          sortOrder: ann.id,
        ),
      );
    }

    // 2. Callback Requests
    final dashData = _dashboardController.dashboardData.value;
    if (dashData?.callbackRequests != null) {
      final callbacks = dashData!.callbackRequests!;
      if (callbacks.pending > 0) {
        final now = DateTime.now();
        items.add(
          NotificationItemModel(
            id: 'callback_pending',
            title: "Pending Callback Requests",
            message: "You have ${callbacks.pending} pending callback request(s) to follow up.",
            date: _formatDateString('', now),
            time: _formatTimeString(null, now),
            category: 'Callbacks',
            color: const Color(0xFFEF4444),
            icon: Icons.phone_callback_rounded,
            dateTime: now,
            sortOrder: 999999,
          ),
        );
      }
    }

    // 3. Teacher Leave Requests
    if (dashData?.teacherLeaves != null) {
      final tLeaves = dashData!.teacherLeaves!;
      if (tLeaves.totalPendingCount > 0) {
        final now = DateTime.now();
        items.add(
          NotificationItemModel(
            id: 'teacher_leave_pending',
            title: "Teacher Leave Requests",
            message: "You have ${tLeaves.totalPendingCount} pending teacher leave request(s).",
            date: _formatDateString('', now),
            time: _formatTimeString(null, now),
            category: 'Leaves',
            color: const Color(0xFF0D9488),
            icon: Icons.free_cancellation_rounded,
            dateTime: now,
            sortOrder: 999998,
          ),
        );
      }
    }

    // 4. Student Leave Requests
    if (dashData?.studentLeaves != null) {
      final sLeaves = dashData!.studentLeaves!;
      if (sLeaves.totalPendingCount > 0) {
        final now = DateTime.now();
        items.add(
          NotificationItemModel(
            id: 'student_leave_pending',
            title: "Student Leave Requests",
            message: "You have ${sLeaves.totalPendingCount} pending student leave request(s).",
            date: _formatDateString('', now),
            time: _formatTimeString(null, now),
            category: 'Leaves',
            color: const Color(0xFF10B981),
            icon: Icons.time_to_leave_rounded,
            dateTime: now,
            sortOrder: 999997,
          ),
        );
      }
    }

    // Sort items: Latest notification on top (descending order)
    items.sort((a, b) {
      if (a.dateTime != null && b.dateTime != null) {
        final cmp = b.dateTime!.compareTo(a.dateTime!);
        if (cmp != 0) return cmp;
      } else if (a.dateTime != null) {
        return -1;
      } else if (b.dateTime != null) {
        return 1;
      }
      return b.sortOrder.compareTo(a.sortOrder);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: AppColors.appBarToolbarHeight,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: AppColors.appBarCenterTitle,
            leading: const CustomBackButton(),
            title: const Text(
              "NOTIFICATIONS",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            final bool isLoading = _announcementController.isLoading.value &&
                _dashboardController.isLoading.value;

            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final allItems = _buildNotificationItems();
            final int totalItems = allItems.length;

            // Clear unread count when items are displayed
            if (NotificationController.to.unreadCount.value > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NotificationController.to.markAsViewed(totalItems);
              });
            }

            if (totalItems == 0) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 42,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No notifications found",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "You're all caught up!",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final displayedItems = allItems.take(_displayedCount).toList();
            final bool hasMore = _displayedCount < totalItems;

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: displayedItems.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayedItems.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF132A60),
                          ),
                        ),
                      ),
                    );
                  }

                  final item = displayedItems[index];
                  return Card(
                    color: AppColors.cardColor,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppColors.cardBorderRadius,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1.8,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.date.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 9.5,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 3.5),
                                                Text(
                                                  item.date,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (item.time != null && item.time!.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.09),
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 9.5,
                                                  color: Color(0xFF0284C7),
                                                ),
                                                const SizedBox(width: 3.5),
                                                Text(
                                                  item.time!,
                                                  style: const TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0284C7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

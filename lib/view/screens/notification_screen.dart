import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/notification_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/notification_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  final NotificationController _notificationController = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _notificationController.fetchNotifications(isRefresh: true);
    _scrollController.addListener(_onScroll);

    // Clear unread count on opening screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationController.to.markAsViewed();
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 80) {
      if (_notificationController.hasMore && !_notificationController.isLoadingMore.value) {
        _notificationController.fetchMoreNotifications();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _notificationController.fetchNotifications(isRefresh: true);
    NotificationController.to.markAsViewed(_notificationController.notifications.length);
  }

  IconData _getModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'transport':
      case 'bus':
      case 'vehicle':
      case 'gps':
        return Icons.directions_bus_rounded;
      case 'attendance':
      case 'student_attendance':
      case 'teacher_attendance':
        return Icons.fact_check_rounded;
      case 'banner':
        return Icons.view_carousel_rounded;
      case 'announcement':
        return Icons.campaign_rounded;
      case 'callback':
      case 'callback_request':
        return Icons.phone_callback_rounded;
      case 'leave':
      case 'teacher_leave':
      case 'student_leave':
        return Icons.free_cancellation_rounded;
      case 'homework':
      case 'assignment':
        return Icons.menu_book_rounded;
      case 'finance':
      case 'fee':
      case 'payment':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getModuleColor(String module) {
    switch (module.toLowerCase()) {
      case 'transport':
      case 'bus':
      case 'vehicle':
      case 'gps':
        return const Color(0xFFF43F5E); // Rose Red
      case 'attendance':
      case 'student_attendance':
      case 'teacher_attendance':
        return const Color(0xFFF59E0B); // Amber / Warm Orange
      case 'banner':
        return const Color(0xFF8B5CF6); // Purple
      case 'announcement':
        return const Color(0xFF0EA5E9); // Sky Blue
      case 'callback':
      case 'callback_request':
        return const Color(0xFFEF4444); // Red
      case 'leave':
      case 'teacher_leave':
      case 'student_leave':
        return const Color(0xFF10B981); // Emerald Green
      case 'homework':
      case 'assignment':
        return const Color(0xFF6366F1); // Indigo
      case 'finance':
      case 'fee':
      case 'payment':
        return const Color(0xFF14B8A6); // Teal
      default:
        return const Color(0xFF132A60); // Navy Blue
    }
  }

  String _formatDateTime(String createdAt, String timeAgo) {
    if (timeAgo.isNotEmpty) {
      return timeAgo;
    }
    if (createdAt.isNotEmpty) {
      final parsed = DateTime.tryParse(createdAt);
      if (parsed != null) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final day = parsed.day.toString().padLeft(2, '0');
        final month = months[parsed.month - 1];
        final year = parsed.year;
        int h = parsed.hour;
        final period = h >= 12 ? 'PM' : 'AM';
        h = h % 12;
        if (h == 0) h = 12;
        final m = parsed.minute.toString().padLeft(2, '0');
        return '$day $month $year, $h:$m $period';
      }
    }
    return createdAt;
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
            if (_notificationController.isLoading.value &&
                _notificationController.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryNavy,
                ),
              );
            }

            if (_notificationController.errorMessage.isNotEmpty &&
                _notificationController.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 40,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _notificationController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Try Again"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final notifications = _notificationController.notifications;

            // Clear unread count when items are displayed
            if (NotificationController.to.unreadCount.value > 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NotificationController.to.markAsViewed(notifications.length);
              });
            }

            if (notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Notifications Yet",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "You're all caught up! New updates will appear here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primaryNavy,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                itemCount: notifications.length +
                    (_notificationController.isLoadingMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    );
                  }

                  final AppNotification item = notifications[index];
                  final Color itemColor = _getModuleColor(item.module);
                  final IconData itemIcon = _getModuleIcon(item.module);
                  final String timeDisplay = _formatDateTime(item.createdAt, item.timeAgo);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: item.isRead
                          ? Colors.white
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: item.isRead
                            ? const Color(0xFFE2E8F0)
                            : itemColor.withValues(alpha: 0.35),
                        width: item.isRead ? 1.0 : 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left indicator stripe for unread items
                            if (!item.isRead)
                              Container(
                                width: 4.5,
                                color: itemColor,
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Module Icon Container
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: itemColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        itemIcon,
                                        color: itemColor,
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Notification Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Top Row: Title on Left, Time Ago on Right
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: item.isRead
                                                        ? FontWeight.bold
                                                        : FontWeight.w800,
                                                    color: const Color(0xFF0F172A),
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                              if (timeDisplay.isNotEmpty) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  timeDisplay,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Body Text
                                          Text(
                                            item.body,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF334155),
                                              height: 1.45,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          // Bottom Right Row: Read Status Ticks
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                item.isRead
                                                    ? Icons.done_all_rounded
                                                    : Icons.done_rounded,
                                                size: 16,
                                                color: item.isRead
                                                    ? const Color(0xFF10B981)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

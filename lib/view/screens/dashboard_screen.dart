import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view/widgets/custom_shimmer.dart';
import 'package:smart_aig_admins_app/view/screens/meeting_screen.dart';
import 'package:smart_aig_admins_app/view/screens/deadlines_screen.dart';
import 'package:smart_aig_admins_app/view/screens/announcement_screen.dart';
import 'package:smart_aig_admins_app/view/screens/banner_screen.dart';
import 'package:smart_aig_admins_app/view/screens/billing_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/marks_entry_screen.dart';
import 'package:smart_aig_admins_app/view/screens/exam_result_screen.dart';
import 'package:smart_aig_admins_app/view/screens/homework_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_count_screen.dart';
import 'package:smart_aig_admins_app/view/screens/admission_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/meeting_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/deadlines_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/announcement_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/banner_controller.dart';

import '../../view_models/getX/dashboard_controller.dart';
import 'assets_report.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    final MeetingController meetingController = Get.put(MeetingController());
    final DeadlinesController deadlinesController = Get.put(DeadlinesController());
    final StudentAttendanceController studentAttendanceController = Get.put(StudentAttendanceController());
    final TeacherAttendanceController teacherAttendanceController = Get.put(TeacherAttendanceController());
    final AnnouncementController announcementController = Get.put(AnnouncementController());
    final BannerController bannerController = Get.put(BannerController());

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FE),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading();
          }

        final data = controller.dashboardData.value;
        if (data == null) {
          return const Center(child: Text("No data available"));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDashboardData();
            await meetingController.fetchMeetings();
            await deadlinesController.fetchDeadlines();
            await studentAttendanceController.fetchAttendanceSummary();
            await teacherAttendanceController.fetchAttendanceSummary();
            await announcementController.fetchAnnouncements();
            await bannerController.fetchBanners();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          data.teacher.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // School Logo & Name Section
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFF0038A8).withOpacity(0.1), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: data.school.logo != null && data.school.logo!.isNotEmpty
                                    ? Image.network(
                                        data.school.logo!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(
                                            Icons.school_rounded,
                                            size: 40,
                                            color: Color(0xFF0038A8),
                                          ),
                                        ),
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.school_rounded,
                                          size: 40,
                                          color: Color(0xFF0038A8),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data.school.schoolName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "ID: ${data.school.schoolCode}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Statistics Section

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFE2E8F0).withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.people_alt_rounded,
                                        color: Color(0xFF6366F1),
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Total Students",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              data.totalActiveStudents.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: const Color(0xFFE2E8F0),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.school_rounded,
                                        color: Color(0xFF10B981),
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Total Teachers",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              data.totalActiveTeachers.toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: _buildStatCard(
                      //         icon: Icons.people_alt_rounded,
                      //         color: const Color(0xFF6366F1),
                      //         title: "Total Students",
                      //         value: data.totalActiveStudents.toString(),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 10),
                      //     Expanded(
                      //       child: _buildStatCard(
                      //         icon: Icons.school_rounded,
                      //         color: const Color(0xFF10B981),
                      //         title: "Total Teachers",
                      //         value: data.totalActiveTeachers.toString(),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 10),

                      // School Modules Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.63,
                              children: [
                                Obx(() {
                                  final count = announcementController.totalAnnouncements;
                                  return _buildGridMenuItem(
                                    icon: Icons.campaign_rounded,
                                    color: const Color(0xFF0EA5E9), // Sky Blue
                                    title: "Announcement",
                                    badgeCount: count > 0 ? count : null,
                                    badgeColor: const Color(0xFFEF4444),
                                    isBlinking: false,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AnnouncementScreen()),
                                      );
                                    },
                                  );
                                }),
                                Obx(() {
                                  final todayCount = meetingController.todayOngoingMeetings.length;

                                  return _buildGridMenuItem(
                                    icon: Icons.groups_rounded,
                                    color: const Color(0xFF10B981), // Green
                                    title: "Meetings",
                                    badgeCount: todayCount > 0 ? todayCount : null,
                                    badgeColor: const Color(0xFF10B981), // Green Badge
                                    isBlinking: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MeetingScreen()),
                                      );
                                    },
                                  );
                                }),
                                Obx(() {
                                  final upcomingDeadlinesCount = deadlinesController.deadlinesList.where((d) => (d.daysRemaining ?? 0) >= 0).length;
                                  return _buildGridMenuItem(
                                    icon: Icons.event_available_rounded,
                                    color: const Color(0xFFF59E0B), // Orange
                                    title: "Deadlines",
                                    badgeCount: upcomingDeadlinesCount > 0 ? upcomingDeadlinesCount : null,
                                    badgeColor: const Color(0xFFEF4444),
                                    isBlinking: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DeadlinesScreen()),
                                      );
                                    },
                                  );
                                }),
                                Obx(() {
                                  final count = bannerController.totalBanners;
                                  return _buildGridMenuItem(
                                    icon: Icons.view_carousel_rounded,
                                    color: const Color(0xFFF43F5E), // Rose/Pink
                                    title: "Banners",
                                    badgeCount: count > 0 ? count : null,
                                    badgeColor: const Color(0xFFEF4444),
                                    isBlinking: false,

                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const BannerScreen()),
                                      );
                                    },
                                  );
                                }),
                                _buildGridMenuItem(
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFF3B82F6), // Blue
                                  title: "Billing",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BillingScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.assessment_rounded,
                                  color: const Color(0xFFF59E0B), // Amber
                                  title: "Assets Report",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AssetsReport()),
                                    );
                                  },
                                ),
                                Obx(() {
                                  final unread = studentAttendanceController.unreadCount.value;
                                  return _buildGridMenuItem(
                                    icon: Icons.assignment_ind_rounded,
                                    color: const Color(0xFF6366F1), // Indigo
                                    title: "Student Attendance",
                                    badgeCount: unread > 0 ? unread : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StudentAttendanceReportScreen()),
                                      );
                                    },
                                  );
                                }),
                                Obx(() {
                                  final unread = teacherAttendanceController.unreadCount.value;
                                  return _buildGridMenuItem(
                                    icon: Icons.supervisor_account_rounded,
                                    color: const Color(0xFF06B6D4), // Cyan
                                    title: "Teacher Attendance",
                                    badgeCount: unread > 0 ? unread : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const TeacherAttendanceReportScreen()),
                                      );
                                    },
                                  );
                                }),
                                _buildGridMenuItem(
                                  icon: Icons.edit_note_rounded,
                                  color: const Color(0xFFF43F5E), // Rose
                                  title: "Marks Entry",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MarksEntryScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.emoji_events_rounded,
                                  color: const Color(0xFF8B5CF6), // Purple
                                  title: "Exam Result",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ExamResultScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.home_work_rounded,
                                  color: const Color(0xFF4F46E5), // Indigo
                                  title: "Homework",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeworkScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.bar_chart_rounded,
                                  color: const Color(0xFF0EA5E9), // Sky Blue
                                  title: "Student Count",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const StudentCountScreen()),
                                    );
                                  },
                                ),
                                _buildGridMenuItem(
                                  icon: Icons.group_add_rounded,
                                  color: const Color(0xFF7C3AED), // Violet
                                  title: "Admission",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AdmissionScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🙏';
    if (hour < 17) return 'Good Afternoon 🙏';
    return 'Good Evening 🙏';
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildGridMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color? badgeColor,
    Color? badgeBorderColor,
    Color? iconBgColor,
    bool isBlinking = true,
  }) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor ?? Colors.red,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Center(
        child: Text(
          badgeCount?.toString() ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor ?? color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -15,
                    right: -8,
                    child: isBlinking ? BlinkingBadge(child: badge) : badge,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // School Logo Shimmer
          const CustomShimmer.circular(width: 80, height: 80),
          const SizedBox(height: 10),
          // School Name Shimmer
          const CustomShimmer.rectangular(height: 20, width: 200),
          const SizedBox(height: 15),
          // Profile Greeting Card Shimmer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                CustomShimmer.circular(width: 50, height: 50),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer.rectangular(height: 16, width: 120),
                    SizedBox(height: 8),
                    CustomShimmer.rectangular(height: 12, width: 80),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          // Grid Section title Shimmer
          const Align(
            alignment: Alignment.centerLeft,
            child: CustomShimmer.rectangular(height: 18, width: 150),
          ),
          const SizedBox(height: 15),
          // Grid Items Shimmer
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 15,
            childAspectRatio: 0.63,
            children: List.generate(
              12,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomShimmer.circular(width: 32, height: 32),
                    SizedBox(height: 10),
                    CustomShimmer.rectangular(height: 12, width: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlinkingBadge extends StatefulWidget {
  final Widget child;
  const BlinkingBadge({super.key, required this.child});

  @override
  State<BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1).animate(_controller),
      child: FadeTransition(
        opacity: Tween(begin: 0.6, end: 1.0).animate(_controller),
        child: widget.child,
      ),
    );
  }
}

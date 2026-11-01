import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/admission_screen.dart';
import 'package:smart_aig_admins_app/view/screens/admit_card_scan_screen.dart';
import 'package:smart_aig_admins_app/view/screens/announcement_screen.dart';
import 'package:smart_aig_admins_app/view/screens/assets_report.dart';
import 'package:smart_aig_admins_app/view/screens/banner_screen.dart';
import 'package:smart_aig_admins_app/view/screens/billing_screen.dart';
import 'package:smart_aig_admins_app/view/screens/callback_screen.dart';
import 'package:smart_aig_admins_app/view/screens/deadlines_screen.dart';
import 'package:smart_aig_admins_app/view/screens/event_screen.dart';
import 'package:smart_aig_admins_app/view/screens/exam_result_screen.dart';
import 'package:smart_aig_admins_app/view/screens/homework_screen.dart';
import 'package:smart_aig_admins_app/view/screens/invigilator_duty_screen.dart';
import 'package:smart_aig_admins_app/view/screens/marks_entry_screen.dart';
import 'package:smart_aig_admins_app/view/screens/meeting_screen.dart';
import 'package:smart_aig_admins_app/view/screens/scan_attendance_screen.dart';
import 'package:smart_aig_admins_app/view/screens/setting_plan_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_count_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/syllabus_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_attendance_report_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/transport_screen.dart';

import 'package:smart_aig_admins_app/view_models/getX/announcement_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/banner_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/dashboard_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/deadlines_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/meeting_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_leave_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_leave_controller.dart';

class DashboardModules extends StatelessWidget {
  final double? sectionTitleFontSize;
  final double? gridCardTitleFontSize;
  final double? gridCardAspectRatio;

  const DashboardModules({
    super.key,
    this.sectionTitleFontSize,
    this.gridCardTitleFontSize,
    this.gridCardAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double effSectionTitleFontSize =
        sectionTitleFontSize ?? (screenWidth * 0.032).clamp(11.5, 13.5);
    final double effGridCardTitleFontSize =
        gridCardTitleFontSize ?? (screenWidth * 0.027).clamp(9.5, 11.5);
    final double effGridCardAspectRatio =
        gridCardAspectRatio ?? ((screenWidth - 24 - 12) / 3 / 96).clamp(0.96, 1.20);

    final DashboardController controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final MeetingController meetingController = Get.isRegistered<MeetingController>()
        ? Get.find<MeetingController>()
        : Get.put(MeetingController());
    final DeadlinesController deadlinesController = Get.isRegistered<DeadlinesController>()
        ? Get.find<DeadlinesController>()
        : Get.put(DeadlinesController());
    final StudentAttendanceController studentAttendanceController = Get.isRegistered<StudentAttendanceController>()
        ? Get.find<StudentAttendanceController>()
        : Get.put(StudentAttendanceController());
    final TeacherAttendanceController teacherAttendanceController = Get.isRegistered<TeacherAttendanceController>()
        ? Get.find<TeacherAttendanceController>()
        : Get.put(TeacherAttendanceController());
    final AnnouncementController announcementController = Get.isRegistered<AnnouncementController>()
        ? Get.find<AnnouncementController>()
        : Get.put(AnnouncementController());
    final BannerController bannerController = Get.isRegistered<BannerController>()
        ? Get.find<BannerController>()
        : Get.put(BannerController());
    final StudentLeaveController studentLeaveController = Get.isRegistered<StudentLeaveController>()
        ? Get.find<StudentLeaveController>()
        : Get.put(StudentLeaveController());
    final TeacherLeaveController teacherLeaveController = Get.isRegistered<TeacherLeaveController>()
        ? Get.find<TeacherLeaveController>()
        : Get.put(TeacherLeaveController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Attendance Management Section
        _buildSectionCard(
          title: "Attendance Management",
          accentColor: const Color(0xFF6366F1),
          sectionIcon: Icons.school_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Student Attendance
            Obx(() {
              final unread = studentAttendanceController.unreadCount.value;
              return _buildGridCard(
                icon: Icons.assignment_ind_rounded,
                color: const Color(0xFF6366F1), // Indigo
                circleBgColor: const Color(0xFFEDE9FE),
                title: "Student Attendance",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: unread > 0 ? unread : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentAttendanceReportScreen()),
                  );
                },
              );
            }),

            // 2. Teacher Attendance
            Obx(() {
              final unread = teacherAttendanceController.unreadCount.value;
              return _buildGridCard(
                icon: Icons.supervisor_account_rounded,
                color: const Color(0xFF06B6D4), // Cyan
                circleBgColor: const Color(0xFFCFFAFE),
                title: "Teacher Attendance",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: unread > 0 ? unread : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TeacherAttendanceReportScreen()),
                  );
                },
              );
            }),

            // 3. Student Leave
            Obx(() {
              final dashData = controller.dashboardData.value;
              final pending = dashData?.studentLeaves?.totalPendingCount ??
                  studentLeaveController.pendingCount;
              return _buildGridCard(
                icon: Icons.time_to_leave_rounded,
                color: const Color(0xFF10B981), // Emerald Green
                circleBgColor: const Color(0xFFD1FAE5),
                title: "Student Leave",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: pending > 0 ? pending : null,
                badgeColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentLeaveScreen()),
                  );
                },
              );
            }),

            // 4. Teacher Leave
            Obx(() {
              final dashData = controller.dashboardData.value;
              final pending = dashData?.teacherLeaves?.totalPendingCount ??
                  teacherLeaveController.pendingCount;
              return _buildGridCard(
                icon: Icons.free_cancellation_rounded,
                color: const Color(0xFF0D9488), // Teal
                circleBgColor: const Color(0xFFCCFBF1),
                title: "Teacher Leave",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: pending > 0 ? pending : null,
                badgeColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TeacherLeaveScreen()),
                  );
                },
              );
            }),

            // 5. Scan Attendance
            _buildGridCard(
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF0284C7), // Sky Blue
              circleBgColor: const Color(0xFFE0F2FE),
              title: "Scan Attendance",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanAttendanceScreen()),
                );
              },
            ),
          ],
        ),

        // 2. Academic Management Section
        _buildSectionCard(
          title: "Academic Management",
          accentColor: const Color(0xFF0D9488),
          sectionIcon: Icons.menu_book_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Syllabus
            _buildGridCard(
              icon: Icons.book_rounded,
              color: const Color(0xFF0D9488), // Teal
              circleBgColor: const Color(0xFFCCFBF1),
              title: "Syllabus",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SyllabusScreen()),
                );
              },
            ),

            // 2. Home Work
            _buildGridCard(
              icon: Icons.home_work_rounded,
              color: const Color(0xFF4F46E5), // Indigo
              circleBgColor: const Color(0xFFE0E7FF),
              title: "Home Work",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeworkScreen()),
                );
              },
            ),

            // 3. Event
            _buildGridCard(
              icon: Icons.event_rounded,
              color: const Color(0xFFEF4444), // Red
              circleBgColor: const Color(0xFFFEE2E2),
              title: "Event E-Pass",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EventScreen()),
                );
              },
            ),
          ],
        ),

        // 3. Admission Management Section
        _buildSectionCard(
          title: "Admission Management",
          accentColor: const Color(0xFF7C3AED),
          sectionIcon: Icons.person_add_alt_1_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Admission Form
            _buildGridCard(
              icon: Icons.group_add_rounded,
              color: const Color(0xFF7C3AED), // Violet
              circleBgColor: const Color(0xFFF3E8FF),
              title: "Admission Form",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdmissionScreen()),
                );
              },
            ),
          ],
        ),

        // 4. Exam Management Section
        _buildSectionCard(
          title: "Exam Management",
          accentColor: const Color(0xFFF43F5E),
          sectionIcon: Icons.assignment_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Marks Report
            _buildGridCard(
              icon: Icons.edit_note_rounded,
              color: const Color(0xFFF43F5E), // Rose
              circleBgColor: const Color(0xFFFFE4E6),
              title: "Marks Report",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MarksEntryScreen()),
                );
              },
            ),

            // 2. Exam Result
            _buildGridCard(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFF8B5CF6), // Purple
              circleBgColor: const Color(0xFFEDE9FE),
              title: "Exam Result",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ExamResultScreen()),
                );
              },
            ),

            // 3. Admit Card Scan
            _buildGridCard(
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFF059669), // Emerald
              circleBgColor: const Color(0xFFD1FAE5),
              title: "Admit Card Scan",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdmitCardScanScreen()),
                );
              },
            ),

            // 4. Invigilator Duty
            _buildGridCard(
              icon: Icons.assignment_turned_in_rounded,
              color: const Color(0xFF6366F1), // Indigo
              circleBgColor: const Color(0xFFEDE9FE),
              title: "Invigilator Duties",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InvigilatorDutyScreen()),
                );
              },
            ),

            // 5. Seating Plan
            _buildGridCard(
              icon: Icons.event_seat_rounded,
              color: const Color(0xFFEA580C), // Orange / Amber
              circleBgColor: const Color(0xFFFFEDD5),
              title: "Seating Plan",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingPlanScreen()),
                );
              },
            ),
          ],
        ),

        // 5. Communication Management Section
        _buildSectionCard(
          title: "Communication Management",
          accentColor: const Color(0xFF0EA5E9),
          sectionIcon: Icons.campaign_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Announcement
            Obx(() {
              final count = announcementController.totalAnnouncements;
              return _buildGridCard(
                icon: Icons.campaign_rounded,
                color: const Color(0xFF0EA5E9), // Sky Blue
                circleBgColor: const Color(0xFFE0F2FE),
                title: "Announcement",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: count > 0 ? count : null,
                badgeColor: const Color(0xFFEF4444),
                isBlinking: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AnnouncementScreen()),
                  );
                },
              );
            }),

            // 2. Banner
            Obx(() {
              final count = bannerController.totalBanners;
              return _buildGridCard(
                icon: Icons.view_carousel_rounded,
                color: const Color(0xFFEC4899), // Pink
                circleBgColor: const Color(0xFFFCE7F3),
                title: "Banner",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: count > 0 ? count : null,
                badgeColor: const Color(0xFFEF4444),
                isBlinking: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BannerScreen()),
                  );
                },
              );
            }),

            // 3. Call Back Request
            Obx(() {
              final data = controller.dashboardData.value;
              return _buildGridCard(
                icon: Icons.phone_callback_rounded,
                color: const Color(0xFFEF4444), // Red
                circleBgColor: const Color(0xFFFEE2E2),
                title: "Call Back Request",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: (data?.callbackRequests?.pending ?? 0) > 0
                    ? data?.callbackRequests?.pending
                    : null,
                badgeColor: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CallbackScreen()),
                  );
                },
              );
            }),
          ],
        ),

        // 6. Finance Management Section
        _buildSectionCard(
          title: "Finance Management",
          accentColor: const Color(0xFFF59E0B),
          sectionIcon: Icons.account_balance_wallet_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Assets Reports
            _buildGridCard(
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFFF59E0B), // Amber
              circleBgColor: const Color(0xFFFEF3C7),
              title: "Assets Reports",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AssetsReport()),
                );
              },
            ),
          ],
        ),

        // 7. AIG Portal Section
        _buildSectionCard(
          title: "AIG Portal",
          accentColor: const Color(0xFF10B981),
          sectionIcon: Icons.grid_view_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. AIG Meetings
            Obx(() {
              final todayCount = meetingController.todayOngoingMeetings.length;
              return _buildGridCard(
                icon: Icons.groups_rounded,
                color: const Color(0xFF10B981), // Emerald Green
                circleBgColor: const Color(0xFFD1FAE5),
                title: "AIG Meetings",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: todayCount > 0 ? todayCount : null,
                badgeColor: const Color(0xFF10B981),
                isBlinking: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MeetingScreen()),
                  );
                },
              );
            }),

            // 2. Upcoming Deadlines
            Obx(() {
              final upcomingDeadlinesCount = deadlinesController.deadlinesList
                  .where((d) => (d.daysRemaining ?? 0) >= 0)
                  .length;
              return _buildGridCard(
                icon: Icons.event_available_rounded,
                color: const Color(0xFFF59E0B), // Amber / Orange
                circleBgColor: const Color(0xFFFEF3C7),
                title: "Upcoming Deadlines",
                titleFontSize: effGridCardTitleFontSize,
                badgeCount: upcomingDeadlinesCount > 0
                    ? upcomingDeadlinesCount
                    : null,
                badgeColor: const Color(0xFFEF4444),
                isBlinking: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DeadlinesScreen()),
                  );
                },
              );
            }),

            // 3. AIG Payments
            _buildGridCard(
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF2563EB), // Blue
              circleBgColor: const Color(0xFFDBEAFE),
              title: "AIG Payments",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BillingScreen()),
                );
              },
            ),
          ],
        ),

        // 8. Administration & Services Section
        _buildSectionCard(
          title: "Administration & Services",
          accentColor: const Color(0xFF64748B),
          sectionIcon: Icons.widgets_rounded,
          titleFontSize: effSectionTitleFontSize,
          childAspectRatio: effGridCardAspectRatio,
          children: [
            // 1. Student Count
            _buildGridCard(
              icon: Icons.pie_chart_rounded,
              color: const Color(0xFF0EA5E9), // Sky Blue
              circleBgColor: const Color(0xFFE0F2FE),
              title: "Student Count",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentCountScreen()),
                );
              },
            ),

            // 2. Transport
            _buildGridCard(
              icon: Icons.directions_bus_rounded,
              color: const Color(0xFFD97706), // Amber/Orange
              circleBgColor: const Color(0xFFFEF3C7),
              title: "Transport",
              titleFontSize: effGridCardTitleFontSize,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TransportScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color accentColor,
    required IconData sectionIcon,
    required List<Widget> children,
    double titleFontSize = 13,
    double childAspectRatio = 1.20,
  }) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: AppColors.cardBorderRadius,
            border: Border.all(
              color: Colors.white,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF90A4AE).withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          sectionIcon,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: children,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required Color color,
    required Color circleBgColor,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color? badgeColor,
    bool isBlinking = false,
    double titleFontSize = 10.5,
  }) {
    Widget badge = Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: badgeColor ?? const Color(0xFFEF4444),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Center(
        child: Text(
          badgeCount?.toString() ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Button Body
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.20),
                  width: 1.1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: circleBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notification / Counter Badge on Top-Right Corner of Button Card
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: isBlinking ? BlinkingBadge(child: badge) : badge,
              ),
          ],
        ),
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

class _BlinkingBadgeState extends State<BlinkingBadge>
    with SingleTickerProviderStateMixin {
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

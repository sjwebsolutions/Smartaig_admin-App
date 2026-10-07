import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:smart_aig_admins_app/view/screens/syllabus_screen.dart';
import 'package:smart_aig_admins_app/view/screens/invigilator_duty_screen.dart';
import 'package:smart_aig_admins_app/view/screens/setting_plan_screen.dart';
import 'package:smart_aig_admins_app/view/screens/admit_card_scan_screen.dart';
import 'package:smart_aig_admins_app/view/screens/callback_screen.dart';
import 'package:smart_aig_admins_app/view/screens/student_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/teacher_leave_screen.dart';
import 'package:smart_aig_admins_app/view/screens/scan_attendance_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/meeting_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/deadlines_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_attendance_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/announcement_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/banner_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/invigilator_duty_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_leave_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_leave_controller.dart';
import 'package:smart_aig_admins_app/models/dashboard_model.dart';

import '../../view_models/getX/dashboard_controller.dart';
import '../../utils/app_colors.dart';
import 'assets_report.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double profileNameFontSize = (screenWidth * 0.039).clamp(13.5, 16.5);
    final double greetingNameFontSize = (screenWidth * 0.046).clamp(16.0, 19.5);
    final double schoolNameFontSize = (screenWidth * 0.033).clamp(11.5, 14.0);
    final double schoolCodeFontSize = (screenWidth * 0.027).clamp(9.5, 11.5);
    final double statTitleFontSize = (screenWidth * 0.028).clamp(9.5, 12.0);
    final double statValueFontSize = (screenWidth * 0.045).clamp(15.0, 20.0);
    final double sectionTitleFontSize = (screenWidth * 0.032).clamp(11.5, 13.5);
    final double gridCardTitleFontSize = (screenWidth * 0.027).clamp(9.5, 11.5);
    final double gridCardAspectRatio = ((screenWidth - 32 - 12) / 3 / 88).clamp(1.05, 1.30);

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
    final InvigilatorDutyController invigilatorDutyController = Get.isRegistered<InvigilatorDutyController>()
        ? Get.find<InvigilatorDutyController>()
        : Get.put(InvigilatorDutyController());
    final StudentLeaveController studentLeaveController = Get.isRegistered<StudentLeaveController>()
        ? Get.find<StudentLeaveController>()
        : Get.put(StudentLeaveController());
    final TeacherLeaveController teacherLeaveController = Get.isRegistered<TeacherLeaveController>()
        ? Get.find<TeacherLeaveController>()
        : Get.put(TeacherLeaveController());

    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
        body: Obx(() {
          final bool isDashboardLoading = controller.isLoading.value &&
              (controller.dashboardData.value == null && !controller.hasError.value);

          if (isDashboardLoading) {
            return _buildShimmerLoading();
          }

          final data = controller.dashboardData.value;
          if (data == null || controller.hasError.value) {
            return _buildOfflineErrorView(
              context: context,
              controller: controller,
              meetingController: meetingController,
              deadlinesController: deadlinesController,
              studentAttendanceController: studentAttendanceController,
              teacherAttendanceController: teacherAttendanceController,
              announcementController: announcementController,
              bannerController: bannerController,
              invigilatorDutyController: invigilatorDutyController,
              studentLeaveController: studentLeaveController,
              teacherLeaveController: teacherLeaveController,
            );
          }



          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchDashboardData();
              // Trigger sub-controllers refresh asynchronously in background
              Future.wait([
                meetingController.fetchMeetings(),
                deadlinesController.fetchDeadlines(),
                studentAttendanceController.fetchAttendanceSummary(),
                teacherAttendanceController.fetchAttendanceSummary(),
                announcementController.fetchAnnouncements(),
                bannerController.fetchBanners(),
                invigilatorDutyController.fetchDuties(),
                studentLeaveController.fetchStudentLeaves(showLoading: false),
                teacherLeaveController.fetchTeacherLeaves(showLoading: false),
              ]).catchError((e) {
                return <void>[];
              });
            },
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Greeting & Teacher Reviewer Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getGreeting(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  data.teacher.name,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: greetingNameFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/images/verified_badge.png',
                                width: (greetingNameFontSize * 0.95).clamp(15.0, 18.5),
                                height: (greetingNameFontSize * 0.95).clamp(15.0, 18.5),
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Main School Profile Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardColor,
                          borderRadius: AppColors.cardBorderRadius,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. TOP ROW: Square Image on Left + Admin Name on Right
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Square School Avatar Container
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFE2E8F0),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF64748B).withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: data.school.logo != null && data.school.logo!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: data.school.logo!,
                                            fit: BoxFit.cover,
                                            memCacheWidth: 150,
                                            memCacheHeight: 150,
                                            placeholder: (context, url) => _buildDefaultAvatar(),
                                            errorWidget: (context, url, error) => _buildDefaultAvatar(),
                                          )
                                        : _buildDefaultAvatar(),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Admin / User Name & Verified Badge Inline
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_outline_rounded,
                                            size: (profileNameFontSize * 1.05).clamp(14.0, 17.5),
                                            color: const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: data.teacher.name,
                                                    style: TextStyle(
                                                      fontSize: profileNameFontSize,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  WidgetSpan(
                                                    alignment: PlaceholderAlignment.middle,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: Image(
                                                        image: const AssetImage('assets/images/verified_badge.png'),
                                                        width: (profileNameFontSize * 0.95).clamp(13.0, 15.5),
                                                        height: (profileNameFontSize * 0.95).clamp(13.0, 15.5),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // 2. DIVIDER LINE
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                height: 1,
                                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                              ),
                            ),

                            // 3. BOTTOM ROW: School Name & School ID Badge
                            Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: data.school.schoolName,
                                          style: TextStyle(
                                            fontSize: schoolNameFontSize,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF475569),
                                            height: 1.2,
                                          ),
                                        ),
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Image(
                                              image: const AssetImage('assets/images/verified_badge.png'),
                                              width: (schoolNameFontSize * 1.1).clamp(13.0, 15.5),
                                              height: (schoolNameFontSize * 1.1).clamp(13.0, 15.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // School ID Badge Card
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDE9FE),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFDDD6FE),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "ID: ${data.school.schoolCode}",
                                    style: TextStyle(
                                      fontSize: schoolCodeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF6366F1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Statistics Card (Total Students & Total Teachers)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        child: Row(
                          children: [
                            // Total Students
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: (screenWidth * 0.10).clamp(38.0, 44.0),
                                    height: (screenWidth * 0.10).clamp(38.0, 44.0),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEDE9FE), // Light purple
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.people_alt_rounded,
                                        color: const Color(0xFF6366F1),
                                        size: (screenWidth * 0.05).clamp(18.0, 22.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Total Students",
                                          style: TextStyle(
                                            fontSize: statTitleFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          data.totalActiveStudents.toString(),
                                          style: TextStyle(
                                            fontSize: statValueFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Vertical Divider
                            Container(
                              width: 1,
                              height: 38,
                              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                            ),

                            // Total Teachers
                            Expanded(
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Container(
                                    width: (screenWidth * 0.10).clamp(38.0, 44.0),
                                    height: (screenWidth * 0.10).clamp(38.0, 44.0),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD1FAE5), // Light mint green
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.school_rounded,
                                        color: const Color(0xFF10B981),
                                        size: (screenWidth * 0.05).clamp(18.0, 22.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Total Teachers",
                                          style: TextStyle(
                                            fontSize: statTitleFontSize,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          data.totalActiveTeachers.toString(),
                                          style: TextStyle(
                                            fontSize: statValueFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Callback Requests Card
                    if (data.callbackRequests != null &&
                        data.callbackRequests!.hasPendingOrInProgress) ...[
                      _buildCallbackRequestsCard(
                        context,
                        data.callbackRequests,
                        countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                        labelFontSize: statTitleFontSize,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Teacher Leaves Card
                    if (data.teacherLeaves != null &&
                        data.teacherLeaves!.totalPendingCount > 0) ...[
                      _buildTeacherLeavesCard(
                        context,
                        data.teacherLeaves,
                        countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                        labelFontSize: statTitleFontSize,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Student Leaves Card
                    if (data.studentLeaves != null &&
                        data.studentLeaves!.totalPendingCount > 0) ...[
                      _buildStudentLeavesCard(
                        context,
                        data.studentLeaves,
                        countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                        labelFontSize: statTitleFontSize,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 1. Attendance Management Section
                    _buildSectionCard(
                      title: "Attendance Management",
                      accentColor: const Color(0xFF6366F1),
                      sectionIcon: Icons.school_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Student Attendance
                        Obx(() {
                          final unread = studentAttendanceController.unreadCount.value;
                          return _buildGridCard(
                            icon: Icons.assignment_ind_rounded,
                            color: const Color(0xFF6366F1), // Indigo
                            circleBgColor: const Color(0xFFEDE9FE),
                            title: "Student Attendance",
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: unread > 0 ? unread : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StudentAttendanceReportScreen()),
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
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: unread > 0 ? unread : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TeacherAttendanceReportScreen()),
                              );
                            },
                          );
                        }),

                        // 3. Student Leave
                        Obx(() {
                          final dashData = controller.dashboardData.value;
                          final pending = dashData?.studentLeaves?.totalPendingCount ?? studentLeaveController.pendingCount;
                          return _buildGridCard(
                            icon: Icons.time_to_leave_rounded,
                            color: const Color(0xFF10B981), // Emerald Green
                            circleBgColor: const Color(0xFFD1FAE5),
                            title: "Student Leave",
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: pending > 0 ? pending : null,
                            badgeColor: const Color(0xFFEF4444),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StudentLeaveScreen()),
                              );
                            },
                          );
                        }),

                        // 4. Teacher Leave
                        Obx(() {
                          final dashData = controller.dashboardData.value;
                          final pending = dashData?.teacherLeaves?.totalPendingCount ?? teacherLeaveController.pendingCount;
                          return _buildGridCard(
                            icon: Icons.free_cancellation_rounded,
                            color: const Color(0xFF0D9488), // Teal
                            circleBgColor: const Color(0xFFCCFBF1),
                            title: "Teacher Leave",
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: pending > 0 ? pending : null,
                            badgeColor: const Color(0xFFEF4444),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const TeacherLeaveScreen()),
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
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ScanAttendanceScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 2. Academic Management Section
                    _buildSectionCard(
                      title: "Academic Management",
                      accentColor: const Color(0xFF0D9488),
                      sectionIcon: Icons.menu_book_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Syllabus
                        _buildGridCard(
                          icon: Icons.book_rounded,
                          color: const Color(0xFF0D9488), // Teal
                          circleBgColor: const Color(0xFFCCFBF1),
                          title: "Syllabus",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SyllabusScreen()),
                            );
                          },
                        ),

                        // 2. Home Work
                        _buildGridCard(
                          icon: Icons.home_work_rounded,
                          color: const Color(0xFF4F46E5), // Indigo
                          circleBgColor: const Color(0xFFE0E7FF),
                          title: "Home Work",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeworkScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 3. Admission Management Section
                    _buildSectionCard(
                      title: "Admission Management",
                      accentColor: const Color(0xFF7C3AED),
                      sectionIcon: Icons.person_add_alt_1_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Admission Form
                        _buildGridCard(
                          icon: Icons.group_add_rounded,
                          color: const Color(0xFF7C3AED), // Violet
                          circleBgColor: const Color(0xFFF3E8FF),
                          title: "Admission Form",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdmissionScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 4. Exam Management Section
                    _buildSectionCard(
                      title: "Exam Management",
                      accentColor: const Color(0xFFF43F5E),
                      sectionIcon: Icons.assignment_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Marks Report
                        _buildGridCard(
                          icon: Icons.edit_note_rounded,
                          color: const Color(0xFFF43F5E), // Rose
                          circleBgColor: const Color(0xFFFFE4E6),
                          title: "Marks Report",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MarksEntryScreen()),
                            );
                          },
                        ),

                        // 2. Exam Result
                        _buildGridCard(
                          icon: Icons.emoji_events_rounded,
                          color: const Color(0xFF8B5CF6), // Purple
                          circleBgColor: const Color(0xFFEDE9FE),
                          title: "Exam Result",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ExamResultScreen()),
                            );
                          },
                        ),

                        // 3. Admit Card Scan
                        _buildGridCard(
                          icon: Icons.qr_code_scanner_rounded,
                          color: const Color(0xFF059669), // Emerald
                          circleBgColor: const Color(0xFFD1FAE5),
                          title: "Admit Card Scan",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdmitCardScanScreen()),
                            );
                          },
                        ),

                        // 4. Invigilator Duty
                        _buildGridCard(
                          icon: Icons.assignment_turned_in_rounded,
                          color: const Color(0xFF6366F1), // Indigo
                          circleBgColor: const Color(0xFFEDE9FE),
                          title: "Invigilator Duties",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const InvigilatorDutyScreen()),
                            );
                          },
                        ),

                        // 5. Seating Plan
                        _buildGridCard(
                          icon: Icons.event_seat_rounded,
                          color: const Color(0xFFEA580C), // Orange / Amber
                          circleBgColor: const Color(0xFFFFEDD5),
                          title: "Seating Plan",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingPlanScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 5. Communication Management Section
                    _buildSectionCard(
                      title: "Communication Management",
                      accentColor: const Color(0xFF0EA5E9),
                      sectionIcon: Icons.campaign_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Announcement
                        Obx(() {
                          final count = announcementController.totalAnnouncements;
                          return _buildGridCard(
                            icon: Icons.campaign_rounded,
                            color: const Color(0xFF0EA5E9), // Sky Blue
                            circleBgColor: const Color(0xFFE0F2FE),
                            title: "Announcement",
                            titleFontSize: gridCardTitleFontSize,
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

                        // 2. Banner
                        Obx(() {
                          final count = bannerController.totalBanners;
                          return _buildGridCard(
                            icon: Icons.view_carousel_rounded,
                            color: const Color(0xFFEC4899), // Pink
                            circleBgColor: const Color(0xFFFCE7F3),
                            title: "Banner",
                            titleFontSize: gridCardTitleFontSize,
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

                        // 3. Call Back Request
                        _buildGridCard(
                          icon: Icons.phone_callback_rounded,
                          color: const Color(0xFFEF4444), // Red
                          circleBgColor: const Color(0xFFFEE2E2),
                          title: "Call Back Request",
                          titleFontSize: gridCardTitleFontSize,
                          badgeCount: (data.callbackRequests?.pending ?? 0) > 0
                              ? data.callbackRequests?.pending
                              : null,
                          badgeColor: const Color(0xFFEF4444),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CallbackScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 6. Finance Management Section
                    _buildSectionCard(
                      title: "Finance Management",
                      accentColor: const Color(0xFFF59E0B),
                      sectionIcon: Icons.account_balance_wallet_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Assets Reports
                        _buildGridCard(
                          icon: Icons.bar_chart_rounded,
                          color: const Color(0xFFF59E0B), // Amber
                          circleBgColor: const Color(0xFFFEF3C7),
                          title: "Assets Reports",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AssetsReport()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 7. AIG Portal Section
                    _buildSectionCard(
                      title: "AIG Portal",
                      accentColor: const Color(0xFF10B981),
                      sectionIcon: Icons.grid_view_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. AIG Meetings
                        Obx(() {
                          final todayCount = meetingController.todayOngoingMeetings.length;
                          return _buildGridCard(
                            icon: Icons.groups_rounded,
                            color: const Color(0xFF10B981), // Emerald Green
                            circleBgColor: const Color(0xFFD1FAE5),
                            title: "AIG Meetings",
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: todayCount > 0 ? todayCount : null,
                            badgeColor: const Color(0xFF10B981),
                            isBlinking: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MeetingScreen()),
                              );
                            },
                          );
                        }),

                        // 2. Upcoming Deadlines
                        Obx(() {
                          final upcomingDeadlinesCount = deadlinesController.deadlinesList.where((d) => (d.daysRemaining ?? 0) >= 0).length;
                          return _buildGridCard(
                            icon: Icons.event_available_rounded,
                            color: const Color(0xFFF59E0B), // Amber / Orange
                            circleBgColor: const Color(0xFFFEF3C7),
                            title: "Upcoming Deadlines",
                            titleFontSize: gridCardTitleFontSize,
                            badgeCount: upcomingDeadlinesCount > 0 ? upcomingDeadlinesCount : null,
                            badgeColor: const Color(0xFFEF4444),
                            isBlinking: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const DeadlinesScreen()),
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
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BillingScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 8. Administration & Services Section
                    _buildSectionCard(
                      title: "Administration & Services",
                      accentColor: const Color(0xFF64748B),
                      sectionIcon: Icons.widgets_rounded,
                      titleFontSize: sectionTitleFontSize,
                      childAspectRatio: gridCardAspectRatio,
                      children: [
                        // 1. Student Count
                        _buildGridCard(
                          icon: Icons.pie_chart_rounded,
                          color: const Color(0xFF0EA5E9), // Sky Blue
                          circleBgColor: const Color(0xFFE0F2FE),
                          title: "Student Count",
                          titleFontSize: gridCardTitleFontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentCountScreen()),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }),
        ),
      ),
    );
  }

  Widget _buildCallbackRequestsCard(BuildContext context, CallbackRequestsModel? callbackRequests, {double countFontSize = 16, double labelFontSize = 11}) {
    if (callbackRequests == null || !callbackRequests.hasPendingOrInProgress) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            // Header Row: Title (Non-clickable)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_callback_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Callback Requests",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            // Stats Row: Pending, In Progress, Completed Today
            Row(
              children: [
                // Pending
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Pending",
                    count: callbackRequests.pending,
                    color: const Color(0xFFEF4444), // Red
                    bgColor: const Color(0xFFFEE2E2),
                    icon: Icons.pending_actions_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                ),
                // In Progress
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "In Progress",
                    count: callbackRequests.inProgress,
                    color: const Color(0xFF2563EB), // Blue
                    bgColor: const Color(0xFFDBEAFE),
                    icon: Icons.sync_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                ),
                // Completed Today
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Completed",
                    count: callbackRequests.completedToday,
                    color: const Color(0xFF10B981), // Emerald Green
                    bgColor: const Color(0xFFD1FAE5),
                    icon: Icons.check_circle_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherLeavesCard(BuildContext context, LeaveSummaryModel? teacherLeaves, {double countFontSize = 16, double labelFontSize = 11}) {
    if (teacherLeaves == null || teacherLeaves.totalPendingCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            // Header Row: Title (Non-clickable)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCCFBF1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.free_cancellation_rounded,
                      color: Color(0xFF0D9488),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Teacher Leave Requests",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Total Pending",
                    count: teacherLeaves.totalPendingCount,
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                    icon: Icons.pending_actions_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                ),
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Pending Today",
                    count: teacherLeaves.todayPendingCount,
                    color: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFEDD5),
                    icon: Icons.today_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentLeavesCard(BuildContext context, LeaveSummaryModel? studentLeaves, {double countFontSize = 16, double labelFontSize = 11}) {
    if (studentLeaves == null || studentLeaves.totalPendingCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            // Header Row: Title (Non-clickable)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.time_to_leave_rounded,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Student Leave Requests",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Total Pending",
                    count: studentLeaves.totalPendingCount,
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                    icon: Icons.pending_actions_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                ),
                Expanded(
                  child: _buildCallbackStatItem(
                    label: "Pending Today",
                    count: studentLeaves.todayPendingCount,
                    color: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFEDD5),
                    icon: Icons.today_rounded,
                    countFontSize: countFontSize,
                    labelFontSize: labelFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallbackStatItem({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
    double countFontSize = 16,
    double labelFontSize = 11,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: color, size: 13),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: countFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🙏';
    if (hour < 17) return 'Good Afternoon 🙏';
    return 'Good Evening 🙏';
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                crossAxisSpacing: 6,
                mainAxisSpacing: 8,
                childAspectRatio: childAspectRatio,
                children: children,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 40,
          color: Color(0xFF94A3B8),
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

  Widget _buildShimmerLoading() {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Greeting & Teacher Name Shimmer (Good afternoon / User Name)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer.rectangular(
                  height: 13,
                  width: 110,
                ),
                SizedBox(height: 6),
                CustomShimmer.rectangular(
                  height: 20,
                  width: 160,
                ),
              ],
            ),

            const SizedBox(height: 16),

          // Profile Card Shimmer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: AppColors.cardBorderRadius,
              border: Border.all(
                color: Colors.white,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    CustomShimmer.rectangular(
                      width: 58,
                      height: 58,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CustomShimmer.rectangular(
                        height: 16,
                        width: 140,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomShimmer.rectangular(height: 13, width: 130),
                    ),
                    SizedBox(width: 8),
                    CustomShimmer.rectangular(height: 18, width: 50),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Stat Card Shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: const Row(
              children: [
                CustomShimmer.circular(width: 44, height: 44),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer.rectangular(
                        height: 11,
                        width: 70,
                      ),
                      SizedBox(height: 6),
                      CustomShimmer.rectangular(
                        height: 18,
                        width: 45,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                CustomShimmer.circular(width: 44, height: 44),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer.rectangular(
                        height: 11,
                        width: 70,
                      ),
                      SizedBox(height: 6),
                      CustomShimmer.rectangular(
                        height: 18,
                        width: 45,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Callback Requests Shimmer
          Container(
            padding: const EdgeInsets.all(14),
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
            child: const Column(
              children: [
                Row(
                  children: [
                    CustomShimmer.rectangular(height: 14, width: 130),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomShimmer.rectangular(height: 28, width: 60),
                    CustomShimmer.rectangular(height: 28, width: 60),
                    CustomShimmer.rectangular(height: 28, width: 60),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Section Card Shimmers
          ...List.generate(
            2,
            (sectionIndex) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF90A4AE).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomShimmer.rectangular(
                      height: 15,
                      width: 160,
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.20,
                      children: List.generate(
                        3,
                        (index) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomShimmer.circular(width: 38, height: 38),
                              SizedBox(height: 6),
                              CustomShimmer.rectangular(
                                height: 10,
                                width: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildOfflineErrorView({
    required BuildContext context,
    required DashboardController controller,
    required MeetingController meetingController,
    required DeadlinesController deadlinesController,
    required StudentAttendanceController studentAttendanceController,
    required TeacherAttendanceController teacherAttendanceController,
    required AnnouncementController announcementController,
    required BannerController bannerController,
    required InvigilatorDutyController invigilatorDutyController,
    required StudentLeaveController studentLeaveController,
    required TeacherLeaveController teacherLeaveController,
  }) {
    void retryAll() {
      controller.fetchDashboardData();
      meetingController.fetchMeetings();
      deadlinesController.fetchDeadlines();
      studentAttendanceController.fetchAttendanceSummary();
      teacherAttendanceController.fetchAttendanceSummary();
      announcementController.fetchAnnouncements();
      bannerController.fetchBanners();
      invigilatorDutyController.fetchDuties();
      studentLeaveController.fetchStudentLeaves();
      teacherLeaveController.fetchTeacherLeaves();
    }

    return RefreshIndicator(
      onRefresh: () async => retryAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(
                  color: Colors.white,
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF90A4AE).withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFECACA),
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 38,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No Internet Connection",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please check your internet connection or mobile data and try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: retryAll,
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        "TRY AGAIN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                      style: AppColors.primaryButtonStyle(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
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

/*
// ==========================================
// PREVIOUS DASHBOARD IMPLEMENTATION (COMMENTED)
// ==========================================

class _OldDashboardScreenBackup extends StatelessWidget {
  const _OldDashboardScreenBackup({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();
    final MeetingController meetingController = Get.put(MeetingController());
    final DeadlinesController deadlinesController = Get.put(DeadlinesController());
    final StudentAttendanceController studentAttendanceController = Get.put(StudentAttendanceController());
    final TeacherAttendanceController teacherAttendanceController = Get.put(TeacherAttendanceController());
    final AnnouncementController announcementController = Get.put(AnnouncementController());
    final BannerController bannerController = Get.put(BannerController());
    final InvigilatorDutyController invigilatorDutyController = Get.put(InvigilatorDutyController());

    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildOldShimmerLoading();
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
              await invigilatorDutyController.fetchDuties();
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
                          _getOldGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  data.teacher.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Image.asset(
                                'assets/images/verified_badge.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ],
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      data.school.schoolName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    'assets/images/verified_badge.png',
                                    width: 19,
                                    height: 19,
                                    fit: BoxFit.contain,
                                  ),
                                ],
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

                        const SizedBox(height: 10),

                        // School Modules Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0).withOpacity(0.6),
                              width: 1,
                            ),
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.campaign_rounded,
                                      color: const Color(0xFF0EA5E9),
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.groups_rounded,
                                      color: const Color(0xFF10B981),
                                      title: "Meetings",
                                      badgeCount: todayCount > 0 ? todayCount : null,
                                      badgeColor: const Color(0xFF10B981),
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.event_available_rounded,
                                      color: const Color(0xFFF59E0B),
                                      title: "Deadlines",
                                      badgeCount: upcomingDeadlinesCount > 0 ? upcomingDeadlinesCount : null,
                                      badgeColor: const Color(0xFFEF4444),
                                      isBlinking: false,
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.view_carousel_rounded,
                                      color: const Color(0xFFF43F5E),
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
                                  _buildOldGridMenuItem(
                                    icon: Icons.account_balance_wallet_rounded,
                                    color: const Color(0xFF3B82F6),
                                    title: "Billing",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const BillingScreen()),
                                      );
                                    },
                                  ),
                                  _buildOldGridMenuItem(
                                    icon: Icons.assessment_rounded,
                                    color: const Color(0xFFF59E0B),
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.assignment_ind_rounded,
                                      color: const Color(0xFF6366F1),
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
                                    return _buildOldGridMenuItem(
                                      icon: Icons.supervisor_account_rounded,
                                      color: const Color(0xFF06B6D4),
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
                                  _buildOldGridMenuItem(
                                    icon: Icons.edit_note_rounded,
                                    color: const Color(0xFFF43F5E),
                                    title: "Marks Report",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MarksEntryScreen()),
                                      );
                                    },
                                  ),
                                  _buildOldGridMenuItem(
                                    icon: Icons.emoji_events_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    title: "Exam Result",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ExamResultScreen()),
                                      );
                                    },
                                  ),
                                  _buildOldGridMenuItem(
                                    icon: Icons.home_work_rounded,
                                    color: const Color(0xFF4F46E5),
                                    title: "Homework",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeworkScreen()),
                                      );
                                    },
                                  ),
                                  _buildOldGridMenuItem(
                                    icon: Icons.bar_chart_rounded,
                                    color: const Color(0xFF0EA5E9),
                                    title: "Student Count",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const StudentCountScreen()),
                                      );
                                    },
                                  ),
                                  _buildOldGridMenuItem(
                                    icon: Icons.group_add_rounded,
                                    color: const Color(0xFF7C3AED),
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
        ),
      ),
    );
  }

  String _getOldGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🙏';
    if (hour < 17) return 'Good Afternoon 🙏';
    return 'Good Evening 🙏';
  }

  Widget _buildOldGridMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color? badgeColor,
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.04),
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
                    color: color.withOpacity(0.08),
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

  Widget _buildOldShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const CustomShimmer.circular(width: 80, height: 80),
          const SizedBox(height: 10),
          const CustomShimmer.rectangular(height: 20, width: 200),
          const SizedBox(height: 15),
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
*/

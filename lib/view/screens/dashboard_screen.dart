import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view/widgets/custom_shimmer.dart';
import 'package:smart_aig_admins_app/view/widgets/dashboard_modules.dart';
import 'package:smart_aig_admins_app/view/widgets/live_telecast_card.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_entry_controller.dart';
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double profileNameFontSize = (screenWidth * 0.039).clamp(13.5, 16.5);
    final double greetingNameFontSize = (screenWidth * 0.046).clamp(16.0, 19.5);
    final double schoolNameFontSize = (screenWidth * 0.033).clamp(11.5, 14.0);
    final double statTitleFontSize = (screenWidth * 0.028).clamp(9.5, 12.0);
    final double statValueFontSize = (screenWidth * 0.045).clamp(15.0, 20.0);
    final double sectionTitleFontSize = (screenWidth * 0.032).clamp(11.5, 13.5);
    final double gridCardTitleFontSize = (screenWidth * 0.027).clamp(9.5, 11.5);
    final double gridCardAspectRatio = ((screenWidth - 24 - 12) / 3 / 109).clamp(0.85, 1.00);

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
    final EventEntryController eventEntryController = Get.isRegistered<EventEntryController>()
        ? Get.find<EventEntryController>()
        : Get.put(EventEntryController());

    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmerLoading(context);
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
                await controller.fetchDashboardData(showLoading: false);
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
                  eventEntryController.fetchActiveEvents(),
                ]).catchError((e) {
                  return <void>[];
                });
              },
              child: SafeArea(
                top: false,
                bottom: false,
                child: isLandscape
                    ? Obx(() {
                        final liveEvents = eventEntryController.activeEventsList.where((e) {
                          final telecast = e.liveTelecast;
                          if (telecast == null || !telecast.isLive) return false;
                          final hasVideo = (telecast.youtubeVideoId != null && telecast.youtubeVideoId!.isNotEmpty) ||
                              (telecast.youtubeUrl != null && telecast.youtubeUrl!.isNotEmpty) ||
                              (telecast.embedUrl != null && telecast.embedUrl!.isNotEmpty);
                          return hasVideo;
                        }).toList();

                        if (liveEvents.isNotEmpty) {
                          return Center(
                            child: LiveTelecastCard(event: liveEvents.first),
                          );
                        }

                        return const SizedBox.shrink();
                      })
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                      // Greeting & Teacher Reviewer Row
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 6),
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

                      // Main School Profile Card
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Square School Avatar Container
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Obx(() {
                                    final String? teacherUrl = data.teacher.uploadedProfileImageUrl;
                                    final String? logoUrl = data.school.formattedLogo;
                                    final String? displayUrl = (logoUrl != null && logoUrl.isNotEmpty)
                                        ? logoUrl
                                        : teacherUrl ?? (data.teacher.profileImageUrl.isNotEmpty ? data.teacher.profileImageUrl : null);

                                    final String localPath = controller.localImagePath.value;
                                    if (localPath.isNotEmpty && File(localPath).existsSync()) {
                                      return Image.file(
                                        File(localPath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildNetworkOrFallbackImage(displayUrl, teacherUrl);
                                        },
                                      );
                                    }
                                    return _buildNetworkOrFallbackImage(displayUrl, teacherUrl);
                                  }),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // School Info Column: Name, ID, & AIG Memo No
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. School Name & Verified Badge
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: data.school.schoolName,
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
                                    const SizedBox(height: 3),

                                    // 2. School ID (Below School Name)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "ID - ",
                                            style: TextStyle(
                                              fontSize: schoolNameFontSize,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B),
                                              height: 1.2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.school.schoolCode,
                                            style: TextStyle(
                                              fontSize: schoolNameFontSize,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF475569),
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),

                                    // 3. AIG Membership ID (Below School ID)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "AIG MEMO NO - ",
                                            style: TextStyle(
                                              fontSize: schoolNameFontSize,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B),
                                              height: 1.2,
                                            ),
                                          ),
                                          TextSpan(
                                            text: data.school.aigMembershipId.isNotEmpty
                                                ? data.school.aigMembershipId
                                                : 'N/A',
                                            style: TextStyle(
                                              fontSize: schoolNameFontSize,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF475569),
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Statistics Card (Total Students & Total Teachers)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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

                      // Callback Requests Card
                      if (data.callbackRequests != null &&
                          data.callbackRequests!.hasPendingOrInProgress)
                        _buildCallbackRequestsCard(
                          context,
                          data.callbackRequests,
                          countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                          labelFontSize: statTitleFontSize,
                        ),

                      // Teacher Leaves Card
                      if (data.teacherLeaves != null &&
                          data.teacherLeaves!.totalPendingCount > 0)
                        _buildTeacherLeavesCard(
                          context,
                          data.teacherLeaves,
                          countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                          labelFontSize: statTitleFontSize,
                        ),

                      // Student Leaves Card
                      if (data.studentLeaves != null &&
                          data.studentLeaves!.totalPendingCount > 0)
                        _buildStudentLeavesCard(
                          context,
                          data.studentLeaves,
                          countFontSize: (statValueFontSize * 0.85).clamp(14.0, 17.0),
                          labelFontSize: statTitleFontSize,
                        ),

                      // Live Telecast Card
                      Obx(() {
                        final liveEvents = eventEntryController.activeEventsList.where((e) {
                          final telecast = e.liveTelecast;
                          if (telecast == null || !telecast.isLive) return false;
                          final hasVideo = (telecast.youtubeVideoId != null && telecast.youtubeVideoId!.isNotEmpty) ||
                              (telecast.youtubeUrl != null && telecast.youtubeUrl!.isNotEmpty) ||
                              (telecast.embedUrl != null && telecast.embedUrl!.isNotEmpty);
                          return hasVideo;
                        }).toList();

                        if (liveEvents.isEmpty) return const SizedBox.shrink();

                        return Column(
                          children: liveEvents.map((event) => LiveTelecastCard(event: event)).toList(),
                        );
                      }),

                      // Dashboard Modules
                      DashboardModules(
                        sectionTitleFontSize: sectionTitleFontSize,
                        gridCardTitleFontSize: gridCardTitleFontSize,
                        gridCardAspectRatio: gridCardAspectRatio,
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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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

  Widget _buildNetworkOrFallbackImage(String? displayUrl, String? teacherUrl) {
    return displayUrl != null && displayUrl.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: displayUrl,
            fit: BoxFit.cover,
            memCacheWidth: 150,
            memCacheHeight: 150,
            placeholder: (context, url) => _buildDefaultAvatar(isPerson: displayUrl == teacherUrl),
            errorWidget: (context, url, error) {
              if (displayUrl != teacherUrl && teacherUrl != null && teacherUrl.isNotEmpty) {
                return CachedNetworkImage(
                  imageUrl: teacherUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 150,
                  memCacheHeight: 150,
                  placeholder: (context, url) => _buildDefaultAvatar(isPerson: true),
                  errorWidget: (context, url, error) => _buildDefaultAvatar(),
                );
              }
              return _buildDefaultAvatar(isPerson: displayUrl == teacherUrl);
            },
          )
        : _buildDefaultAvatar(isPerson: teacherUrl != null);
  }

  Widget _buildDefaultAvatar({bool isPerson = false}) {
    return Container(
      color: isPerson ? const Color(0xFFEDE9FE) : const Color(0xFFE2E8F0),
      child: Center(
        child: Icon(
          isPerson ? Icons.person_rounded : Icons.school_rounded,
          size: isPerson ? 32 : 38,
          color: isPerson ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridCardAspectRatio = ((screenWidth - 32 - 12) / 3 / 109).clamp(0.85, 1.00);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomShimmer.rectangular(
                  width: 70,
                  height: 70,
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer.rectangular(
                        height: 16,
                        width: 140,
                      ),
                      SizedBox(height: 6),
                      CustomShimmer.rectangular(height: 13, width: 80),
                      SizedBox(height: 6),
                      CustomShimmer.rectangular(height: 13, width: 130),
                    ],
                  ),
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
              padding: const EdgeInsets.only(bottom: 10),
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
                      mainAxisSpacing: 10,
                      childAspectRatio: gridCardAspectRatio,
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
      controller.fetchDashboardData(showLoading: true);
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

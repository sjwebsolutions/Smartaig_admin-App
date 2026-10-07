import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/teacher_attendance_controller.dart';
import 'package:smart_aig_admins_app/models/teacher_attendance_report_model.dart';
import 'package:smart_aig_admins_app/view/widgets/custom_shimmer.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class TeacherAttendanceReportScreen extends StatelessWidget {
  const TeacherAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TeacherAttendanceController controller = Get.put(
      TeacherAttendanceController(),
    );

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
              "TEACHER ATTENDANCE",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return _buildShimmerLoading();
            }

            if (controller.attendanceData.value == null) {
              return const Center(
                child: Text(
                  "No teacher attendance data available",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              );
            }

            final stats = controller.attendanceData.value!.stats;
            final staffList =
                controller.attendanceData.value!.staffAttendanceData;

            return RefreshIndicator(
              onRefresh: () => controller.fetchAttendanceSummary(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header: Teacher Summary
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Teacher Summary",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildSummaryGrid(stats),
                    const SizedBox(height: 20),

                    if (staffList.isNotEmpty) ...[
                      // Section Header: Staff Attendance List
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Staff Attendance List",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: staffList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = staffList[index];
                          return _buildStaffCard(item);
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(TeacherAttendanceStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildStatBox(
          label: "Total Staff",
          value: stats.totalStaff.toString(),
          icon: Icons.supervisor_account_rounded,
          color: const Color(0xFF6366F1),
          bgColor: const Color(0xFFEDE9FE),
        ),
        _buildStatBox(
          label: "Present Today",
          value: stats.present.toString(),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFD1FAE5),
        ),
        _buildStatBox(
          label: "Absent Today",
          value: stats.absent.toString(),
          icon: Icons.cancel_rounded,
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEE2E2),
        ),
        _buildStatBox(
          label: "On Leave",
          value: stats.leave.toString(),
          icon: Icons.event_busy_rounded,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFEF3C7),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffAttendanceData item) {
    Color statusColor;
    Color statusBgColor;

    switch (item.attendanceStatus.toLowerCase()) {
      case 'present':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        break;
      case 'absent':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      case 'leave':
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
      case 'late':
      case 'half day':
      case 'halfday':
        statusColor = const Color(0xFFEA580C);
        statusBgColor = const Color(0xFFFFEDD5);
        break;
      default:
        statusColor = const Color(0xFF6366F1);
        statusBgColor = const Color(0xFFEDE9FE);
    }

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar Box
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.teacherName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "UID: ${item.teacherUid}${item.wingName.isNotEmpty ? ' • ${item.wingName}' : ''}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item.attendanceStatus,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (item.checkIn.isNotEmpty || item.checkOut.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  height: 1,
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.checkIn.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.login_rounded,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "In: ${item.checkIn}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  if (item.checkOut.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Out: ${item.checkOut}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            if (item.remarks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  "Remarks: ${item.remarks}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: CustomShimmer.rectangular(height: 16, width: 150),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: List.generate(
              4,
              (index) => Container(
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: const Row(
                  children: [
                    CustomShimmer.circular(width: 38, height: 38),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomShimmer.rectangular(height: 16, width: 40),
                          SizedBox(height: 4),
                          CustomShimmer.rectangular(height: 10, width: 65),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: CustomShimmer.rectangular(height: 16, width: 140),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(
                  color: Colors.white,
                  width: 1.8,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomShimmer.rectangular(height: 16, width: 120),
                      CustomShimmer.rectangular(height: 20, width: 65),
                    ],
                  ),
                  SizedBox(height: 10),
                  CustomShimmer.rectangular(height: 12, width: 100),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomShimmer.rectangular(height: 12, width: 70),
                      CustomShimmer.rectangular(height: 12, width: 70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

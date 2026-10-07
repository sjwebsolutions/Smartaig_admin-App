import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_attendance_controller.dart';
import 'package:smart_aig_admins_app/models/student_attendance_report_model.dart';
import 'package:smart_aig_admins_app/view/widgets/custom_shimmer.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class StudentAttendanceReportScreen extends StatelessWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentAttendanceController controller = Get.put(
      StudentAttendanceController(),
    );

    return Container(
      decoration: AppColors.screenDecoration,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: AppColors.appBarToolbarHeight,
            elevation: 0,
            centerTitle: AppColors.appBarCenterTitle,
            leading: const CustomBackButton(),
            title: const Text(
              "ATTENDANCE REPORT",
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
                  "No attendance data available",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              );
            }

            final stats = controller.attendanceData.value!.stats;
            final classWiseData = controller.attendanceData.value!.classWiseData;

            return RefreshIndicator(
              onRefresh: () => controller.fetchAttendanceSummary(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header: Overall Summary
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
                          "Overall Summary",
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

                    // Section Header: Class-wise Details
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Class-wise Details",
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
                      itemCount: classWiseData.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = classWiseData[index];
                        return _buildClassCard(item);
                      },
                    ),
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

  Widget _buildSummaryGrid(AttendanceStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildStatBox(
          label: "Total Students",
          value: stats.totalStudents.toString(),
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF6366F1),
          bgColor: const Color(0xFFEDE9FE),
        ),
        _buildStatBox(
          label: "Present Today",
          value: stats.presentToday.toString(),
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFD1FAE5),
        ),
        _buildStatBox(
          label: "Absent Today",
          value: stats.absentToday.toString(),
          icon: Icons.cancel_rounded,
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEE2E2),
        ),
        _buildStatBox(
          label: "On Leave",
          value: stats.leaveToday.toString(),
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

  Widget _buildClassCard(ClassWiseAttendance item) {
    double attendancePercentage = item.totalStudents > 0
        ? (item.present / item.totalStudents) * 100
        : 0;

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
          children: [
            // Class Header Row
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.class_rounded,
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
                        item.className,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${attendancePercentage.toStringAsFixed(1)}% Present Today",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                // Total Students Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFDDD6FE),
                      width: 1,
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(text: "Total: "),
                        TextSpan(
                          text: item.totalStudents.toString(),
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: attendancePercentage / 100,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B981),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildClassStatPill(
                    label: "Present",
                    value: item.present.toString(),
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFD1FAE5),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildClassStatPill(
                    label: "Absent",
                    value: item.absent.toString(),
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildClassStatPill(
                    label: "Leave",
                    value: item.leave.toString(),
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassStatPill({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
            child: CustomShimmer.rectangular(height: 16, width: 140),
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
            child: CustomShimmer.rectangular(height: 16, width: 130),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
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
                      CustomShimmer.rectangular(height: 20, width: 70),
                    ],
                  ),
                  SizedBox(height: 12),
                  CustomShimmer.rectangular(height: 6, width: double.infinity),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: CustomShimmer.rectangular(height: 38, width: 60)),
                      SizedBox(width: 8),
                      Expanded(child: CustomShimmer.rectangular(height: 38, width: 60)),
                      SizedBox(width: 8),
                      Expanded(child: CustomShimmer.rectangular(height: 38, width: 60)),
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

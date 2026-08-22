import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_attendance_controller.dart';
import 'package:smart_aig_admins_app/models/student_attendance_report_model.dart';
import 'package:smart_aig_admins_app/view/widgets/custom_shimmer.dart';

class StudentAttendanceReportScreen extends StatelessWidget {
  const StudentAttendanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentAttendanceController controller = Get.put(
      StudentAttendanceController(),
    );

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF8F9FE)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FE),
          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: const Color(0xFF1E293B),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "ATTENDANCE REPORT",
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.attendanceData.value == null) {
            return const Center(child: Text("No attendance data available"));
          }

          final stats = controller.attendanceData.value!.stats;
          final classWiseData = controller.attendanceData.value!.classWiseData;

          return RefreshIndicator(
            onRefresh: () => controller.fetchAttendanceSummary(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: Text(
                      "Overall Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _buildSummaryGrid(stats),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    child: Text(
                      "Class-wise Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: classWiseData.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
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
    );
  }

  Widget _buildSummaryGrid(AttendanceStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _buildStatBox(
          "Total",
          stats.totalStudents.toString(),
          const Color(0xFF334155),
        ),
        _buildStatBox(
          "Present",
          stats.presentToday.toString(),
          const Color(0xFF10B981),
        ),
        _buildStatBox(
          "Absent",
          stats.absentToday.toString(),
          const Color(0xFFEF4444),
        ),
        _buildStatBox(
          "On Leave",
          stats.leaveToday.toString(),
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0038A8).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0038A8).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF0038A8).withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.class_rounded,
                    size: 20,
                    color: Color(0xFF0038A8),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: "Total Student : "),
                      TextSpan(
                        text: item.totalStudents.toString(),
                        style: const TextStyle(
                          color: Color(0xFF0038A8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: attendancePercentage / 100,
                backgroundColor: Colors.grey[100],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF10B981),
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  "Present",
                  item.present.toString(),
                  const Color(0xFF10B981),
                ),
                _buildStatItem(
                  "Absent",
                  item.absent.toString(),
                  const Color(0xFFEF4444),
                ),
                _buildStatItem(
                  "Leave",
                  item.leave.toString(),
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 20, width: 1, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: CustomShimmer.rectangular(height: 20, width: 140),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: List.generate(
              4,
              (index) => const CustomShimmer.rectangular(height: 60),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
            child: CustomShimmer.rectangular(height: 20, width: 120),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomShimmer.rectangular(height: 16, width: 100),
                      CustomShimmer.rectangular(height: 18, width: 70),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          CustomShimmer.rectangular(height: 12, width: 45),
                          SizedBox(height: 4),
                          CustomShimmer.rectangular(height: 14, width: 30),
                        ],
                      ),
                      Column(
                        children: [
                          CustomShimmer.rectangular(height: 12, width: 45),
                          SizedBox(height: 4),
                          CustomShimmer.rectangular(height: 14, width: 30),
                        ],
                      ),
                      Column(
                        children: [
                          CustomShimmer.rectangular(height: 12, width: 45),
                          SizedBox(height: 4),
                          CustomShimmer.rectangular(height: 14, width: 30),
                        ],
                      ),
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

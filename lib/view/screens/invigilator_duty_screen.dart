import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/invigilator_duty_detail_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/invigilator_duty_controller.dart';

class InvigilatorDutyScreen extends StatelessWidget {
  const InvigilatorDutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InvigilatorDutyController controller = Get.put(InvigilatorDutyController());

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
              'INVIGILATOR DUTY',
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF132A60)),
              );
            }

            if (controller.duties.isEmpty) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchDuties(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  // 1. Executive Summary Hero Overview
                  _buildHeroOverview(controller.duties),

                  const SizedBox(height: 16),

                  // 2. Section Header
                  Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFF132A60)),
                      const SizedBox(width: 8),
                      const Text(
                        "Duty Schedules",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF132A60).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${controller.duties.length} Plans",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132A60),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. Duty Cards List
                  ...controller.duties.map((duty) => _buildDutyCard(context, duty)),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(InvigilatorDutyController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFF132A60).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                size: 44,
                color: Color(0xFF132A60),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Invigilator Duties Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No duties have been assigned yet.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => controller.fetchDuties(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132A60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroOverview(List<InvigilatorDuty> duties) {
    int totalRooms = 0;
    int totalDuties = 0;
    int totalTeachers = 0;

    for (var d in duties) {
      totalRooms += d.totalRooms;
      totalDuties += d.totalDutiesAssigned;
      totalTeachers += d.uniqueTeachersAssigned;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132A60).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF132A60)),
              SizedBox(width: 6),
              Text(
                "DUTY OVERVIEW",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildHeroStatTile(
                  icon: Icons.meeting_room_rounded,
                  label: "Rooms",
                  value: totalRooms.toString(),
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStatTile(
                  icon: Icons.assignment_ind_rounded,
                  label: "Duties",
                  value: totalDuties.toString(),
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFA7F3D0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHeroStatTile(
                  icon: Icons.groups_rounded,
                  label: "Teachers",
                  value: totalTeachers.toString(),
                  color: const Color(0xFF4338CA),
                  bgColor: const Color(0xFFEEF2FF),
                  borderColor: const Color(0xFFC7D2FE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyCard(BuildContext context, InvigilatorDuty duty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Session Badge Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    size: 18,
                    color: Color(0xFF132A60),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    duty.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132A60),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Text(
                    duty.session,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.event_note_rounded, "Exam", duty.datesheet.name),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.calendar_today_rounded,
                    "Datesheet",
                    "${duty.datesheet.startDate} to ${duty.datesheet.endDate}",
                  ),
                  if (duty.firstExamDate != null && duty.lastExamDate != null) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      Icons.date_range_rounded,
                      "Exam Range",
                      "${duty.firstExamDate} to ${duty.lastExamDate}",
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // View Details Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => InvigilatorDutyDetailScreen(
                        planId: duty.id,
                        planName: duty.name,
                      ));
                },
                icon: const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
                label: const Text(
                  "View Details",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF132A60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

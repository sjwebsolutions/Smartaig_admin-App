import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/seating_plan_detail_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/seating_plan_detail_controller.dart';

class SeatingPlanDetailScreen extends StatelessWidget {
  final int planId;
  final String planName;

  const SeatingPlanDetailScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  static final BorderRadius _cardRadius = AppColors.cardBorderRadius;

  @override
  Widget build(BuildContext context) {
    final SeatingPlanDetailController controller = Get.put(
      SeatingPlanDetailController(planId: planId),
      tag: planId.toString(),
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
            title: Text(
              planName.toUpperCase(),
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF132A60)),
              );
            }

            final data = controller.detailData.value;
            if (data == null) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchPlanDetails(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                children: [
                  // 1. Plan Overview Hero Card
                  _buildPlanOverviewCard(data.plan, data.examTiming),

                  const SizedBox(height: 14),

                  // 2. Statistics Summary Cards Bar
                  _buildStatsSummaryBar(data),

                  const SizedBox(height: 18),

                  // 3. Section Title
                  _buildSectionTitle(data),

                  const SizedBox(height: 12),

                  // 4. Date-wise Seating Matrix Cards
                  if (data.dates.isEmpty)
                    _buildEmptyDatesState()
                  else
                    ...data.dates.map((dateItem) => _buildDateCard(context, controller, dateItem)),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(SeatingPlanDetailController controller) {
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
              child: const Icon(Icons.event_seat_rounded, size: 44, color: Color(0xFF132A60)),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Seating Details Found",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              "Unable to load seating plan schedule.",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => controller.fetchPlanDetails(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132A60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDatesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_rounded, size: 36, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            const Text(
              "No Exam Dates Found",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            const Text(
              "No seating schedule available for this plan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOverviewCard(PlanInfo plan, String? examTiming) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: _cardRadius,
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
          // Header Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF132A60).withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF132A60),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF132A60),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        plan.schoolName,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Text(
                    plan.session,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.event_note_rounded,
                  "Datesheet",
                  plan.datesheetName,
                ),
                if (examTiming != null && examTiming.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time_filled_rounded,
                    "Exam Timing",
                    examTiming,
                  ),
                ],
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.meeting_room_rounded,
                  "Total Plan Rooms",
                  "${plan.totalRooms} Rooms Assigned",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryBar(SeatingPlanDetailData data) {
    final pendingDates = (data.totalDates - data.totalBuiltDates).clamp(0, 9999);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: _cardRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Dates
          Expanded(
            child: _buildStatItem(
              icon: Icons.calendar_month_rounded,
              label: "Total Dates",
              value: data.totalDates.toString(),
              color: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              borderColor: const Color(0xFFBFDBFE),
            ),
          ),
          const SizedBox(width: 8),
          // Ready / Built
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_rounded,
              label: "Ready / Built",
              value: data.totalBuiltDates.toString(),
              color: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              borderColor: const Color(0xFFA7F3D0),
            ),
          ),
          const SizedBox(width: 8),
          // Pending
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending_actions_rounded,
              label: "Pending",
              value: pendingDates.toString(),
              color: const Color(0xFFEA580C),
              bgColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFFEDD5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
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

  Widget _buildSectionTitle(SeatingPlanDetailData data) {
    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF132A60)),
        const SizedBox(width: 8),
        const Text(
          "Seating Matrix Schedule",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF132A60),
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
            "${data.dates.length} Dates",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF132A60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(
    BuildContext context,
    SeatingPlanDetailController controller,
    SeatingPlanDateItem item,
  ) {
    final bool isReady = item.isBuilt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: _cardRadius,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date, Day & Status Chip Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isReady
                          ? const Color(0xFF059669).withValues(alpha: 0.1)
                          : const Color(0xFFEA580C).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReady ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 20,
                      color: isReady ? const Color(0xFF059669) : const Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.formattedDate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.dayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isReady
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isReady
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFFFEDD5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReady ? Icons.check_rounded : Icons.access_time_rounded,
                          size: 12,
                          color: isReady ? const Color(0xFF047857) : const Color(0xFFC2410C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isReady ? const Color(0xFF047857) : const Color(0xFFC2410C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.5, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Stats Pills: Students & Rooms
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          const Text(
                            "Students: ",
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          Expanded(
                            child: Text(
                              item.totalStudents.toString(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.meeting_room_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          const Text(
                            "Rooms: ",
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          Expanded(
                            child: Text(
                              item.totalRoomsUsed.toString(),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // View Master PDF Button or Warning Message
              if (item.pdfUrl != null && item.pdfUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.viewMasterPdf(item.pdfUrl!, item.formattedDate);
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 17),
                    label: const Text(
                      "View Master PDF",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132A60),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ] else if (!isReady) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEA580C)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "Seating matrix not generated for this date",
                          style: TextStyle(fontSize: 11.5, color: Color(0xFFC2410C), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
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

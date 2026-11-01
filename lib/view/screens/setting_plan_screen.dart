import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/seating_plan_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/seating_plan_detail_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/seating_plan_controller.dart';

typedef SeatingPlanScreen = SettingPlanScreen;

class SettingPlanScreen extends StatelessWidget {
  const SettingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SeatingPlanController controller = Get.put(SeatingPlanController());

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
              'SEATING PLAN',
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF132A60)),
              );
            }

            if (controller.plans.isEmpty) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchPlans(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  // 1. Hero Overview Stats Card
                  _buildHeroStats(controller.plans),

                  const SizedBox(height: 16),

                  // 2. Search Plan Bar
                  _buildSearchBar(controller),

                  const SizedBox(height: 16),

                  // 3. Section Title & Count Badge
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF132A60)),
                      const SizedBox(width: 8),
                      const Text(
                        "All Seating Plans",
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
                          color: const Color(0xFF132A60).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${controller.filteredPlans.length} Plans",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF132A60),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4. Plans List
                  if (controller.filteredPlans.isEmpty)
                    _buildEmptySearchState()
                  else
                    ...controller.filteredPlans.map((plan) => _buildPlanCard(context, plan)),

                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyState(SeatingPlanController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF132A60).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chair_alt_rounded,
                size: 54,
                color: Color(0xFF132A60),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Seating Plans Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No exam seating arrangements found at this moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.fetchPlans(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132A60),
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
    );
  }

  Widget _buildEmptySearchState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              "No matching seating plan found",
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStats(List<SeatingPlan> plans) {
    int totalRooms = 0;
    int totalExamDates = 0;
    for (var p in plans) {
      totalRooms += p.totalRooms;
      totalExamDates += p.totalExamDates;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withAlpha(38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: Color(0xFF132A60)),
              SizedBox(width: 6),
              Text(
                "EXAMINATION OVERVIEW",
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
              // Total Plans
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_seat_rounded, size: 18, color: Color(0xFF4338CA)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plans.length.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Total Plans",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3730A3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Rooms Assigned
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.meeting_room_rounded, size: 18, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalRooms.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Rooms",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Exam Dates
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF059669)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalExamDates.toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Exam Dates",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(SeatingPlanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchPlanQuery.value = val;
        },
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: "Search plan name, session or exam...",
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: controller.searchPlanQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                  onPressed: () {
                    controller.searchPlanQuery.value = '';
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SeatingPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Seat Icon, Name, Session & Status Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withAlpha(18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chair_alt_rounded,
                    size: 18,
                    color: Color(0xFF132A60),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132A60),
                      height: 1.2,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plan.status
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: plan.status
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        plan.status ? "ACTIVE" : "INACTIVE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: plan.status ? const Color(0xFF047857) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        plan.session,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.event_note_rounded, "Exam", plan.datesheet.name),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.calendar_month_rounded,
                    "Datesheet",
                    "${plan.datesheet.startDate} to ${plan.datesheet.endDate}",
                  ),
                  if (plan.firstExamDate != null && plan.lastExamDate != null) ...[
                    const SizedBox(height: 6),
                    _buildInfoRow(
                      Icons.date_range_rounded,
                      "Exam Range",
                      "${plan.firstExamDate} to ${plan.lastExamDate}",
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Footer Row: Stat Badges + View Details Action Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 4),
                            Text(
                              "${plan.totalExamDates} Exam Dates",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.meeting_room_rounded, size: 14, color: Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            Text(
                              "${plan.totalRooms} Rooms",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => SeatingPlanDetailScreen(
                          planId: plan.id,
                          planName: plan.name,
                        ));
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 15, color: Colors.white),
                  label: const Text(
                    "View Details",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF132A60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 15, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

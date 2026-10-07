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
            return const Center(child: CircularProgressIndicator(color: Color(0xFF132A60)));
          }

          if (controller.plans.isEmpty) {
            return _buildEmptyState(controller);
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchPlans(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // 1. Hero Overview Stats Card
                _buildHeroStats(controller.plans),

                const SizedBox(height: 14),

                // 2. Search Plan Bar
                _buildSearchBar(controller),

                const SizedBox(height: 14),

                // 3. Plans List
                if (controller.filteredPlans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        "No matching seating plan found",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                      ),
                    ),
                  )
                else
                  ...controller.filteredPlans.map((plan) => _buildPlanCard(context, plan)),

                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(SeatingPlanController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_seat_rounded,
              size: 50,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Seating Plans',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No seating arrangements found.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.fetchPlans(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Refresh"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF132A60),
              foregroundColor: Colors.white,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chair_alt_rounded,
              size: 28,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Examination Seating Plans",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132A60),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${plans.length} Total Plans • $totalRooms Rooms Assigned",
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF132A60).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  totalExamDates.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF132A60),
                  ),
                ),
                const Text(
                  "Exam Dates",
                  style: TextStyle(
                    fontSize: 10,
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

  Widget _buildSearchBar(SeatingPlanController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          controller.searchPlanQuery.value = val;
        },
        decoration: InputDecoration(
          hintText: "Search plan name or session...",
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SeatingPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => SeatingPlanDetailScreen(
                  planId: plan.id,
                  planName: plan.name,
                ));
          },
          borderRadius: AppColors.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name, Session, and Status Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF132A60),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plan.status
                            ? const Color(0xFF059669).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan.status ? "ACTIVE" : "INACTIVE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: plan.status ? const Color(0xFF059669) : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF132A60).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan.session,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF132A60),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Exam & Datesheet Info
                _buildInfoRow(Icons.event_note_rounded, "Exam", plan.datesheet.name),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  "Datesheet",
                  "${plan.datesheet.startDate} to ${plan.datesheet.endDate}",
                ),
                if (plan.firstExamDate != null && plan.lastExamDate != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.date_range_rounded,
                    "Exam Range",
                    "${plan.firstExamDate} to ${plan.lastExamDate}",
                  ),
                ],

                const Divider(height: 24, thickness: 0.5, color: Color(0xFFE2E8F0)),

                // Statistics & View Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn("Exam Dates", plan.totalExamDates.toString()),
                    _buildStatColumn("Rooms", plan.totalRooms.toString()),
                    Row(
                      children: [
                        Text(
                          "View Grid",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF132A60),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/finance_statistics_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/finance_controller.dart';

class AssetsReport extends StatelessWidget {
  const AssetsReport({super.key});

  String _formatCurrency(num amount) {
    final String str = amount.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d+?)(?=(\d{3})+(?!\d))');
    final String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return "₹$formatted";
  }

  @override
  Widget build(BuildContext context) {
    final FinanceController controller = Get.put(FinanceController());

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
              "FINANCE REPORT",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.financeData.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 54, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    const Text(
                      "No Finance Data Available",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchFinanceStatistics(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF132A60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = controller.financeData.value!;

            // Grand Totals
            final num grandTotalReceived = data.fees.totalReceived +
                data.books.totalReceived +
                data.uniforms.totalReceived +
                data.stationary.totalReceived;

            final num grandTodayCollection = data.fees.todayCollection +
                data.books.todayCollection +
                data.uniforms.todayCollection +
                data.stationary.todayCollection;

            final num grandBalance = data.fees.balanceTillToday +
                data.books.balanceTillToday +
                data.uniforms.balanceTillToday +
                data.stationary.balanceTillToday;

            return RefreshIndicator(
              onRefresh: () => controller.fetchFinanceStatistics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Academic Session Banner Pill
                    if (data.session.isNotEmpty)
                      _buildSessionHeaderPill(data.session),

                    if (data.session.isNotEmpty)
                      const SizedBox(height: 12),

                    // Grand Financial Summary Card
                    _buildGrandSummaryCard(
                      grandTotalReceived,
                      grandTodayCollection,
                      grandBalance,
                    ),

                    const SizedBox(height: 18),

                    // Section Title
                    const Row(
                      children: [
                        Icon(Icons.category_rounded, size: 18, color: Color(0xFF132A60)),
                        SizedBox(width: 8),
                        Text(
                          "Category Breakdown",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Fees Statistics
                    _buildCategoryCard(
                      title: "Fees Statistics",
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF3B82F6),
                      item: data.fees,
                    ),
                    const SizedBox(height: 10),

                    // Books Statistics
                    _buildCategoryCard(
                      title: "Books Statistics",
                      icon: Icons.auto_stories_rounded,
                      color: const Color(0xFF10B981),
                      item: data.books,
                    ),
                    const SizedBox(height: 10),

                    // Uniforms Statistics
                    _buildCategoryCard(
                      title: "Uniforms Statistics",
                      icon: Icons.checkroom_rounded,
                      color: const Color(0xFFF59E0B),
                      item: data.uniforms,
                    ),
                    const SizedBox(height: 10),

                    // Stationary Statistics
                    _buildCategoryCard(
                      title: "Stationary Statistics",
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFFEC4899),
                      item: data.stationary,
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

  Widget _buildSessionHeaderPill(String session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132A60).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF132A60)),
          const SizedBox(width: 8),
          Text(
            "Financial Session: $session",
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandSummaryCard(
    num grandTotalReceived,
    num grandTodayCollection,
    num grandBalance,
  ) {
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
              Icon(Icons.pie_chart_outline_rounded, size: 18, color: Color(0xFF132A60)),
              SizedBox(width: 6),
              Text(
                "TOTAL FINANCIAL OVERVIEW",
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

          // 3 Cards in 1 Row: Total Received, Today's Collection, Balance
          Row(
            children: [
              // Total Received Card (Soft Green)
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
                          color: const Color(0xFF10B981).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_downward_rounded, size: 16, color: Color(0xFF059669)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(grandTotalReceived),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Total Received",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF065F46),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Today's Collection Card (Soft Blue)
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
                          color: const Color(0xFF3B82F6).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.today_rounded, size: 16, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(grandTodayCollection),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Today's Coll.",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Balance Card (Soft Rose/Red)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(grandBalance),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Balance",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF991B1B),
                        ),
                        textAlign: TextAlign.center,
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

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required FinanceItem item,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3 Cards in 1 Row: Total Received, Today's Collection, Balance
          Row(
            children: [
              // Total Received
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Received",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(item.totalReceived),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Today's Collection
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Today's Coll.",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(item.todayCollection),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Balance
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Balance",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatCurrency(item.balanceTillToday),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}

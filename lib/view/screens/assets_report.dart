import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/finance_controller.dart';
import 'package:smart_aig_admins_app/models/finance_statistics_model.dart';

class AssetsReport extends StatelessWidget {
  const AssetsReport({super.key});

  @override
  Widget build(BuildContext context) {
    final FinanceController controller = Get.put(FinanceController());

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF8F9FE)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFFF8F9FE),
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
            "FINANCE REPORT",
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.financeData.value == null) {
            return const Center(child: Text("No finance data available"));
          }

          final data = controller.financeData.value!;

          return RefreshIndicator(
            onRefresh: () => controller.fetchFinanceStatistics(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Info
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       "Financial Summary",
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.bold,
                  //         color: Color(0xFF1E293B),
                  //       ),
                  //     ),
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //       decoration: BoxDecoration(
                  //         color: const Color(0xFF0038A8).withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: Text(
                  //         "Session: ${data.session}",
                  //         style: const TextStyle(
                  //           fontSize: 12,
                  //           fontWeight: FontWeight.bold,
                  //           color: Color(0xFF0038A8),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 20),
                  _buildFinanceCard(
                    title: "Fees Statistics",
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF3B82F6), // Blue
                    item: data.fees,
                    labels: [
                      "Total Fee Received",
                      "Today’s Collection",
                      "Balance till today",
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFinanceCard(
                    title: "Books Statistics",
                    icon: Icons.auto_stories_rounded,
                    color: const Color(0xFF10B981), // Emerald
                    item: data.books,
                    labels: [
                      "Total Books Collection",
                      "Today’s Collection",
                      "Balance till today",
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFinanceCard(
                    title: "Uniforms Statistics",
                    icon: Icons.checkroom_rounded,
                    color: const Color(0xFFF59E0B), // Amber
                    item: data.uniforms,
                    labels: [
                      "Total Uniform Collection",
                      "Today’s Collection",
                      "Balance Till Today",
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFinanceCard(
                    title: "Stationary Statistics",
                    icon: Icons.edit_note_rounded,
                    color: const Color(0xFFEC4899), // Pink
                    item: data.stationary,
                    labels: [
                      "Total Stationary Collection",
                      "Today’s Collection",
                      "Balance Till Today",
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFinanceCard({
    required String title,
    required IconData icon,
    required Color color,
    required FinanceItem item,
    required List<String> labels,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  labels[0],
                  item.totalReceived.toString(),
                  Colors.green,
                ),
                _buildDivider(),
                _buildStatItem(
                  labels[1],
                  item.todayCollection.toString(),
                  const Color(0xFF0038A8),
                ),
                _buildDivider(),
                _buildStatItem(
                  labels[2],
                  item.balanceTillToday.toString(),
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "₹$value",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.2));
  }
}

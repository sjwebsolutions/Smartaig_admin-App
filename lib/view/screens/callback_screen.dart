import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/callback_request_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/callback_detail_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/callback_controller.dart';

typedef CallBackScreen = CallbackScreen;

class CallbackScreen extends StatefulWidget {
  final String? initialStatus;
  final String? initialDate;
  final String? initialFromDate;
  final String? initialToDate;

  const CallbackScreen({
    super.key,
    this.initialStatus,
    this.initialDate,
    this.initialFromDate,
    this.initialToDate,
  });

  @override
  State<CallbackScreen> createState() => _CallbackScreenState();
}

class _CallbackScreenState extends State<CallbackScreen> {
  late final CallbackController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CallbackController());
    if (widget.initialStatus != null ||
        widget.initialDate != null ||
        widget.initialFromDate != null ||
        widget.initialToDate != null) {
      controller.fetchCallbackRequests(
        status: widget.initialStatus,
        date: widget.initialDate,
        from: widget.initialFromDate,
        to: widget.initialToDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              "CALLBACK REQUESTS",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            final summary = controller.summary.value;
            final items = controller.filteredCallbackList;
            final isLoading = controller.isLoading.value;

            return RefreshIndicator(
              onRefresh: () => controller.fetchCallbackRequests(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  // 1. Summary Stats
                  _buildSummaryCard(summary),

                  const SizedBox(height: 14),

                  // 2. Status Filters Chips
                  _buildFilterSection(),

                  const SizedBox(height: 14),

                  // 3. Loader or Request Cards or Empty View
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _getFilterColor(controller.selectedStatus.value),
                        ),
                      ),
                    )
                  else if (items.isEmpty)
                    _buildEmptyState()
                  else ...[
                    for (var item in items) _buildCallbackCard(item),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _getFilterColor(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Amber / Orange
      case 'in_progress':
        return const Color(0xFF2563EB); // Royal Blue
      case 'completed':
        return const Color(0xFF10B981); // Emerald Green
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF0284C7); // Sky Blue (All / Total)
    }
  }

  Widget _buildSummaryCard(CallbackSummary? summary) {
    final total = summary?.total ?? 0;
    final pending = summary?.pending ?? 0;
    final completed = summary?.completed ?? 0;
    final inProgress = summary?.inProgress ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn("Pending", pending.toString(), const Color(0xFFF59E0B), const Color(0xFFFEF3C7), Icons.pending_actions_rounded, 'pending'),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildStatColumn("In Progress", inProgress.toString(), const Color(0xFF2563EB), const Color(0xFFDBEAFE), Icons.sync_rounded, 'in_progress'),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildStatColumn("Completed", completed.toString(), const Color(0xFF10B981), const Color(0xFFD1FAE5), Icons.check_circle_rounded, 'completed'),
          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
          _buildStatColumn("Total", total.toString(), const Color(0xFF0284C7), const Color(0xFFE0F2FE), Icons.phone_callback_rounded, 'All'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, Color color, Color bgColor, IconData icon, String statusKey) {
    final isSelected = controller.selectedStatus.value.toLowerCase() == statusKey.toLowerCase();

    return InkWell(
      onTap: () => controller.setFilterStatus(statusKey),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? color : bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : color, size: 17),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = [
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'In Progress', 'value': 'in_progress'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'All', 'value': 'All'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.selectedDate.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_rounded, size: 14, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        "Date: ${controller.selectedDate.value}",
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => controller.setDateFilter(null),
                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF0284C7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = controller.selectedStatus.value.toLowerCase() == f['value']!.toLowerCase();
              final chipColor = _getFilterColor(f['value']!);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: chipColor,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? chipColor : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      controller.setFilterStatus(f['value']!);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCallbackCard(CallbackData item) {
    final status = item.status.toLowerCase();
    Color statusColor;
    Color statusBg;
    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0xFFD1FAE5);
        break;
      case 'in_progress':
        statusColor = const Color(0xFF2563EB);
        statusBg = const Color(0xFFDBEAFE);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0xFFFEF3C7);
    }

    final parentName = item.parent?.name ?? 'Parent Name N/A';
    final parentMobile = item.parent?.mobile ?? '';
    final studentName = item.student?.name ?? 'N/A';
    final classSec = item.student?.classSectionDisplay ?? '';

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
        Get.to(() => CallbackDetailScreen(requestId: item.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: AppColors.cardBorderRadius,
          border: Border.all(color: Colors.white, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90A4AE).withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Parent Name & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Student: $studentName ${classSec.isNotEmpty ? '($classSec)' : ''}",
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
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Reason text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_outlined, size: 16, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.reason,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            if (item.latestNote != null && item.latestNote!.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note_alt_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            "Latest Note${item.latestNote?.staffName != null ? ' by ${item.latestNote!.staffName}' : ''}:",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.latestNote!.notes,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Time & Phone Number
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  item.timeAgo ?? item.requestedAt ?? '',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                ),
                const Spacer(),
                if (parentMobile.isNotEmpty)
                  const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF0284C7)),
                if (parentMobile.isNotEmpty)
                  const SizedBox(width: 4),
                if (parentMobile.isNotEmpty)
                  Text(
                    parentMobile,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_callback_rounded,
                size: 40,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Callback Requests Found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "There are no callback requests matching your current filters.",
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

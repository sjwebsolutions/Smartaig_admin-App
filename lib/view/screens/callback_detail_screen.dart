import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/callback_detail_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/callback_controller.dart';

class CallbackDetailScreen extends StatefulWidget {
  final int requestId;

  const CallbackDetailScreen({super.key, required this.requestId});

  @override
  State<CallbackDetailScreen> createState() => _CallbackDetailScreenState();
}

class _CallbackDetailScreenState extends State<CallbackDetailScreen> {
  late final CallbackController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CallbackController>();
    controller.fetchCallbackDetail(widget.requestId);
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
              "CALLBACK DETAILS",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isDetailLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0284C7),
                ),
              );
            }

            final detail = controller.selectedDetail.value;
            if (detail == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text(
                      "Failed to load details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.fetchCallbackDetail(widget.requestId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Retry"),
                      style: AppColors.primaryButtonStyle(),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchCallbackDetail(widget.requestId),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Status & Header Card
                  _buildHeaderCard(detail),

                  const SizedBox(height: 14),

                  // 2. Parent & Student Card
                  _buildContactCard(detail),

                  const SizedBox(height: 14),

                  // 3. Reason Card
                  _buildReasonCard(detail),

                  const SizedBox(height: 14),

                  // 4. Logs / Activity History
                  _buildLogsSection(detail.logs),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(CallbackDetailData detail) {
    Color statusColor;
    Color statusBg;
    switch (detail.status.toLowerCase()) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Request #${detail.id}",
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  detail.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.access_time_rounded, "Requested At", "${detail.requestedAt ?? 'N/A'} (${detail.timeAgo ?? ''})"),
          if (detail.completedAt != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.check_circle_outline_rounded, "Completed At", detail.completedAt!),
          ],
          if (detail.completedVia != null && detail.completedVia!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.where_to_vote_outlined, "Completed Via", detail.completedVia!),
          ],
          if (detail.reminderCount > 0) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.notifications_active_outlined, "Reminders Sent", "${detail.reminderCount}"),
          ],
        ],
      ),
    );
  }

  Widget _buildContactCard(CallbackDetailData detail) {
    final parent = detail.parent;
    final student = detail.student;

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            "CONTACT & STUDENT INFO",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0284C7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Color(0xFF0284C7), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parent?.name ?? 'Parent Name N/A',
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Mobile: ${parent?.mobile ?? 'N/A'}",
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (student != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.school_rounded, color: Color(0xFF6366F1), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Class: ${student.classSectionDisplay} | Roll No: ${student.rollNo}",
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonCard(CallbackDetailData detail) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            "CALLBACK REASON",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0284C7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Text(
            detail.reason,
            softWrap: true,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF334155),
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection(List<CallbackLog> logs) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: Color(0xFF0284C7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "ACTIVITY & NOTE LOGS (${logs.length})",
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0284C7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          if (logs.isEmpty)
            const Text(
              "No logs available yet.",
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogTile(log, index == logs.length - 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogTile(CallbackLog log, bool isLast) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  log.action.replaceAll('_', ' ').toUpperCase(),
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log.timeAgo ?? log.createdAt ?? '',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.notes,
            softWrap: true,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              height: 1.35,
            ),
          ),
          if (log.staffName != null && log.staffName!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.badge_outlined, size: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "By: ${log.staffName} ${log.staffRole != null ? '(${log.staffRole})' : ''}",
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 6),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

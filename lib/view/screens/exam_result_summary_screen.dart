import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/exam_result_summary_controller.dart';
import 'package:smart_aig_admins_app/models/exam_result_summary_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class ExamResultSummaryScreen extends StatelessWidget {
  final int marksEntryId;
  final int classId;
  final String className;
  final String? sectionName;
  final int? sectionId;
  final int? streamId;
  final String? streamName;
  final String? examTitle;

  const ExamResultSummaryScreen({
    super.key,
    required this.marksEntryId,
    required this.classId,
    required this.className,
    this.sectionName,
    this.sectionId,
    this.streamId,
    this.streamName,
    this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    final ExamResultSummaryController controller = Get.put(
      ExamResultSummaryController(
        marksEntryId: marksEntryId,
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
      ),
      tag: "result_summary_${marksEntryId}_${classId}_${sectionId ?? ''}_${streamId ?? ''}",
    );

    final TextEditingController searchController = TextEditingController();

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
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "RESULT SUMMARY",
                style: AppColors.appBarTitleStyle,
              ),
              const SizedBox(height: 2),
              Text(
                "$className ${sectionName != null ? '- Section $sectionName' : ''} ${streamName != null ? '($streamName)' : ''}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
              ),
            );
          }

          if (!controller.success.value && controller.summaryList.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.fetchSummary(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Failed to load result summary",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please check your connection and try again",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchSummary(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.buttonTextColor,
                            shape: AppColors.buttonShape,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchSummary(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Statistics Card
                        _buildSummaryCard(controller),
                        const SizedBox(height: 16),

                        // Search Field
                        _buildSearchField(controller, searchController),
                        const SizedBox(height: 12),

                        // Status Filter Chips
                        _buildStatusFilters(controller),
                      ],
                    ),
                  ),
                ),

                // Content List or Empty State
                if (controller.filteredList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No matching results",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.searchQuery.value.isNotEmpty
                                  ? "No students found matching \"${controller.searchQuery.value}\""
                                  : "No result records found for this section.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (controller.searchQuery.value.isNotEmpty ||
                                controller.selectedStatusFilter.value != 'All') ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  searchController.clear();
                                  controller.setSearchQuery('');
                                  controller.setStatusFilter('All');
                                },
                                icon: const Icon(Icons.clear_all_rounded, size: 18),
                                label: const Text("Clear Filters"),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = controller.filteredList[index];
                          return _buildStudentCard(item);
                        },
                        childCount: controller.filteredList.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Summary Metrics Card
  Widget _buildSummaryCard(ExamResultSummaryController controller) {
    final double passPercent = controller.passRatio * 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF059669).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Class Performance",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${controller.passedCount} of ${controller.totalStudents} Students Passed",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: passPercent >= 50
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${passPercent.toStringAsFixed(0)}% Pass",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: passPercent >= 50
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: controller.passRatio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                passPercent >= 50
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                title: "Total Students",
                value: "${controller.totalStudents}",
                color: const Color(0xFF64748B),
                bgColor: const Color(0xFFF1F5F9),
                icon: Icons.people_alt_outlined,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                title: "Passed",
                value: "${controller.passedCount}",
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                title: "Failed",
                value: "${controller.failedCount}",
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
                icon: Icons.highlight_off_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search Field
  Widget _buildSearchField(
    ExamResultSummaryController controller,
    TextEditingController textController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        onChanged: (value) => controller.setSearchQuery(value),
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: "Search by student name or admission no...",
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF64748B),
          ),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    textController.clear();
                    controller.setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // Status Filters (All, Pass, Fail)
  Widget _buildStatusFilters(ExamResultSummaryController controller) {
    final filters = [
      {'label': 'All Students', 'value': 'All', 'count': controller.totalStudents},
      {'label': 'Passed', 'value': 'Pass', 'count': controller.passedCount},
      {'label': 'Failed', 'value': 'Fail', 'count': controller.failedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          final value = f['value'] as String;
          final count = f['count'] as int;
          final isSelected = controller.selectedStatusFilter.value == value;

          Color activeColor = const Color(0xFF059669);
          if (value == 'Pass') activeColor = const Color(0xFF10B981);
          if (value == 'Fail') activeColor = const Color(0xFFEF4444);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                ),
              ),
              onSelected: (_) => controller.setStatusFilter(value),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Student Result Card
  Widget _buildStudentCard(ExamResultSummaryItem item) {
    bool isPass = item.resultStatus.trim().toLowerCase() == 'pass';
    Color statusColor = isPass ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Center(
                    child: Icon(
                      isPass ? Icons.emoji_events_rounded : Icons.person_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Adm: ${item.admissionNo}",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                          if (item.grade.isNotEmpty && item.grade != 'N/A') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Grade: ${item.grade}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item.resultStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Obtained / Total Marks",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${item.obtainedMarks} / ${item.totalMarks}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Percentage",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.percentage.endsWith('%') ? item.percentage : "${item.percentage}%",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
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
      ),
    );
  }
}

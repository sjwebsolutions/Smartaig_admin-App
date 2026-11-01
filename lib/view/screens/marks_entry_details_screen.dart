import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/marks_entry_class_details_controller.dart';
import 'package:smart_aig_admins_app/models/marks_entry_class_details_model.dart';
import 'package:smart_aig_admins_app/view/screens/marks_upload_status_screen.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class MarksEntryDetailsScreen extends StatelessWidget {
  final int examId;
  final int classId;
  final String className;
  final String? examTitle;

  const MarksEntryDetailsScreen({
    super.key,
    required this.examId,
    required this.classId,
    required this.className,
    this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    final MarksEntryClassDetailsController controller = Get.put(
      MarksEntryClassDetailsController(examId: examId, classId: classId),
      tag: "marks_entry_details_${examId}_$classId",
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
              className.toUpperCase(),
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                ),
              );
            }

            if (!controller.success.value ||
                controller.classDetails.value == null) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchClassDetails(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Failed to load class details",
                            style: TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchClassDetails(),
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

            final data = controller.classDetails.value!;

            return RefreshIndicator(
              onRefresh: () => controller.fetchClassDetails(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  _buildClassCard(context, data, controller),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    ClassDetailsData data,
    MarksEntryClassDetailsController controller,
  ) {
    final int totalOptions = data.sections.length + data.streams.length;
    final bool hasBoth = data.sections.isNotEmpty && data.streams.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF0038A8).withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row (Class Name & Exam Details)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF0038A8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (examTitle != null && examTitle!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Exam: $examTitle",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasBoth
                        ? "${data.sections.length} Sec • ${data.streams.length} Str"
                        : "$totalOptions Options",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0038A8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. Body List (TabBar if both, or single list)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If both section and stream exist, display TabBar
                if (hasBoth) ...[
                  DefaultTabController(
                    length: 2,
                    initialIndex: controller.selectedTab.value.clamp(0, 1),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TabBar(
                            isScrollable: false,
                            dividerColor: Colors.transparent,
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                            splashFactory: NoSplash.splashFactory,
                            onTap: (index) {
                              controller.selectedTab.value = index;
                            },
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF0038A8),
                                  Color(0xFF1E40AF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0038A8).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: const Color(0xFF64748B),
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: [
                              Tab(
                                height: 38,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.grid_view_rounded, size: 16),
                                    const SizedBox(width: 6),
                                    Text("Sections (${data.sections.length})"),
                                  ],
                                ),
                              ),
                              Tab(
                                height: 38,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.account_tree_rounded, size: 16),
                                    const SizedBox(width: 6),
                                    Text("Streams (${data.streams.length})"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() => controller.selectedTab.value == 0
                            ? Column(
                                children: data.sections
                                    .map((section) => _buildOptionTile(
                                          context,
                                          title: "Section ${section.name}",
                                          icon: Icons.grid_view_rounded,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MarksUploadStatusScreen(
                                                  marksEntryId: examId,
                                                  classId: classId,
                                                  className: className,
                                                  sectionId: section.id,
                                                  sectionName: section.name,
                                                ),
                                              ),
                                            );
                                          },
                                        ))
                                    .toList(),
                              )
                            : Column(
                                children: data.streams
                                    .map((stream) => _buildOptionTile(
                                          context,
                                          title: stream.name,
                                          icon: Icons.account_tree_rounded,
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MarksUploadStatusScreen(
                                                  marksEntryId: examId,
                                                  classId: classId,
                                                  className: className,
                                                  streamId: stream.id,
                                                  streamName: stream.name,
                                                ),
                                              ),
                                            );
                                          },
                                        ))
                                    .toList(),
                              )),
                      ],
                    ),
                  ),
                ] else ...[
                  // Streams List (when only streams exist)
                  if (data.streams.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "SELECT STREAM:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...data.streams.map((stream) => _buildOptionTile(
                          context,
                          title: stream.name,
                          icon: Icons.account_tree_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarksUploadStatusScreen(
                                  marksEntryId: examId,
                                  classId: classId,
                                  className: className,
                                  streamId: stream.id,
                                  streamName: stream.name,
                                ),
                              ),
                            );
                          },
                        )),
                  ],

                  // Sections List (when only sections exist)
                  if (data.sections.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "SELECT SECTION:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...data.sections.map((section) => _buildOptionTile(
                          context,
                          title: "Section ${section.name}",
                          icon: Icons.grid_view_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarksUploadStatusScreen(
                                  marksEntryId: examId,
                                  classId: classId,
                                  className: className,
                                  sectionId: section.id,
                                  sectionName: section.name,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ],

                // Fallback when both empty
                if (data.sections.isEmpty && data.streams.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 32,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No sections or streams available",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MarksUploadStatusScreen(
                                    marksEntryId: examId,
                                    classId: classId,
                                    className: className,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                            label: const Text("View Class Upload Status"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonColor,
                              foregroundColor: AppColors.buttonTextColor,
                              shape: AppColors.buttonShape,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF0038A8).withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0038A8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

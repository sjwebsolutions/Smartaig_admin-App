import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/marks_entry_class_details_controller.dart';
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: AppColors.appBarToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: AppColors.appBarCenterTitle,
          leading: const CustomBackButton(),
          title: Column(
            children: [
              Text(
                className.toUpperCase(),
                style: AppColors.appBarTitleStyle,
              ),
              const Text(
                "SELECT SECTION/STREAM",
                style: TextStyle(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.streams.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        "Streams",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: data.streams.length,
                      itemBuilder: (context, index) {
                        final stream = data.streams[index];
                        return _buildItemCard(
                          stream.name,
                          Icons.account_tree_rounded,
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
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (data.sections.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        "Sections",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: data.sections.length,
                      itemBuilder: (context, index) {
                        final section = data.sections[index];
                        return _buildItemCard(
                          section.name,
                          Icons.grid_view_rounded,
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
                        );
                      },
                    ),
                  ],
                  if (data.sections.isEmpty && data.streams.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Text("No sections or streams available"),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildItemCard(String title, IconData icon, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF0038A8).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppColors.cardBorderRadius,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0038A8)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



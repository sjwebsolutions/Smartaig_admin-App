import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'syllabus_attachment_viewer.dart';
import '../../view_models/getX/syllabus_controller.dart';
import '../../models/syllabus_model.dart';
import '../../utils/app_colors.dart';

class SyllabusScreen extends StatelessWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SyllabusController controller = Get.put(SyllabusController());

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
            "SYLLABUS",
            style: AppColors.appBarTitleStyle,
          ),
        ),
        body: Column(
          children: [
            Obx(() {
              if (controller.termsList.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.termsList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTermChip(null, "All");
                    }
                    final term = controller.termsList[index - 1];
                    return _buildTermChip(term.id, term.name);
                  },
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.syllabusList.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Syllabus available",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchSyllabus(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.syllabusList.length,
                    itemBuilder: (context, index) {
                      final syllabus = controller.syllabusList[index];
                      return _buildSyllabusCard(context, syllabus);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTermChip(int? id, String name) {
    final SyllabusController controller = Get.find<SyllabusController>();
    return Obx(() {
      final isSelected = controller.selectedTermId.value == id;
      return GestureDetector(
        onTap: () => controller.selectTerm(id),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0038A8) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF0038A8) : const Color(0xFFE2E8F0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0038A8).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSyllabusCard(BuildContext context, Syllabus syllabus) {
    return Card(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppColors.cardBorderRadius,
        side: const BorderSide(
          color: Color(0xFF0038A8),
          width: 1.2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syllabus.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Uploaded by ${syllabus.uploadedBy}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    syllabus.session,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0038A8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              syllabus.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            if (syllabus.term != null || syllabus.subject != null)
              Row(
                children: [
                  if (syllabus.term != null)
                    _buildInfoTag(Icons.calendar_today, syllabus.term!),
                  if (syllabus.term != null && syllabus.subject != null)
                    const SizedBox(width: 8),
                  if (syllabus.subject != null)
                    _buildInfoTag(Icons.book, syllabus.subject!),
                ],
              ),
            if (syllabus.term != null || syllabus.subject != null)
              const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    syllabus.targetAudience,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (syllabus.attachments != null && syllabus.attachments!.isNotEmpty) ...[
              ...syllabus.attachments!.map((attachment) {
                final isImage = attachment.isImage;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isImage
                            ? Icons.image_outlined
                            : Icons.picture_as_pdf_outlined,
                        size: 20,
                        color: isImage ? Colors.blue : Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          attachment.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => SyllabusAttachmentViewer(
                                url: attachment.url,
                                title: attachment.title,
                                isImage: isImage,
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.buttonTextColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: AppColors.buttonShape,
                        ),
                        child: Text(
                          isImage ? "View Image" : "View PDF",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      CustomSnackBar.showError("Error", "Could not launch URL");
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/getX/announcement_controller.dart';
import 'announcement_detail_screen.dart';
import 'add_announcement_screen.dart';
import 'banner_details_screen.dart';
import '../../utils/app_colors.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnouncementController controller = Get.put(AnnouncementController());

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
            "ANNOUNCEMENTS",
            style: AppColors.appBarTitleStyle,
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FloatingActionButton.extended(
            onPressed: () => Get.to(() => AddAnnouncementScreen()),
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.buttonTextColor,
            shape: AppColors.buttonShape,
            elevation: 4,
            icon: const Icon(Icons.add, color: AppColors.buttonTextColor),
            label: const Text(
              "Add",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.announcements.isEmpty) {
            return const Center(
              child: Text(
                "No Announcements available",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchAnnouncements(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: controller.announcements.length,
              itemBuilder: (context, index) {
                final announcement = controller.announcements[index];
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (announcement.imageUrl != null &&
                            announcement.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              announcement.imageUrl!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(
                                        announcement.type,
                                      ).withAlpha(30),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      announcement.type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getTypeColor(announcement.type),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    announcement.fromDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                announcement.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      announcement.createdBy,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: announcement.isEditable
                                        ? () => _showToggleConfirmationDialog(
                                              context,
                                              controller,
                                              announcement,
                                            )
                                        : null,
                                    child: Text(
                                      announcement.status == 1
                                          ? "Active"
                                          : "Inactive",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: announcement.status == 1
                                            ? const Color(0xFF16A34A)
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: announcement.status == 1,
                                      activeThumbColor: const Color(0xFF16A34A),
                                      onChanged: announcement.isEditable
                                          ? (_) => _showToggleConfirmationDialog(
                                                context,
                                                controller,
                                                announcement,
                                              )
                                          : null, // Disable if not editable
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, thickness: 0.5),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  // 1. View Details Button
                                  _buildCardActionButton(
                                    icon: Icons.visibility_outlined,
                                    label: "View Details",
                                    color: const Color(0xFF0038A8),
                                    onTap: () {
                                      Get.to(
                                        () => AnnouncementDetailScreen(
                                          id: announcement.id,
                                          announcement: announcement,
                                        ),
                                      );
                                    },
                                  ),

                                  // 2. Edit Button
                                  if (announcement.isEditable &&
                                      announcement.submitStatus
                                              .toLowerCase() !=
                                          'locked' &&
                                      announcement.submitStatus
                                              .toLowerCase() !=
                                          'submitted')
                                      _buildCardActionButton(
                                        icon: Icons.edit_outlined,
                                        label: "Edit",
                                        color: const Color(0xFF2563EB),
                                        onTap: () async {
                                          Get.dialog(
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            barrierDismissible: false,
                                          );
                                          await controller
                                              .fetchAnnouncementDetails(
                                                announcement.id,
                                              );
                                          Get.back(); // close loading dialog
                                          if (controller
                                                  .announcementDetail
                                                  .value !=
                                              null) {
                                            Get.to(
                                              () => AddAnnouncementScreen(
                                                announcement: controller
                                                    .announcementDetail
                                                    .value,
                                              ),
                                            );
                                          }
                                        },
                                      ),

                                    // 2. Lock / Unlock Button
                                    if (announcement.isEditable) ...[
                                      if (announcement.submitStatus
                                                  .toLowerCase() ==
                                              'locked' ||
                                          announcement.submitStatus
                                                  .toLowerCase() ==
                                              'submitted')
                                        _buildCardActionButton(
                                          icon: Icons.lock_open_rounded,
                                          label: "Unlock",
                                          color: const Color(0xFFD97706),
                                          onTap: () {
                                            Get.dialog(
                                              AlertDialog(
                                                title: const Text(
                                                  "Unlock Announcement",
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to unlock this announcement?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      controller
                                                          .unlockAnnouncement(
                                                            announcement.id,
                                                          );
                                                    },
                                                    child: const Text(
                                                      "Unlock",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      else
                                        _buildCardActionButton(
                                          icon: Icons.lock_outline_rounded,
                                          label: "Lock",
                                          color: const Color(0xFF0D9488),
                                          onTap: () {
                                            Get.dialog(
                                              AlertDialog(
                                                title: const Text(
                                                  "Lock Announcement",
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to lock this announcement?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      controller
                                                          .lockAnnouncement(
                                                            announcement.id,
                                                          );
                                                    },
                                                    child: const Text(
                                                      "Lock",
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                    ],

                                    // 3. Download / View Image Button
                                    if (announcement.imageUrl != null &&
                                        announcement.imageUrl!.isNotEmpty)
                                      _buildCardActionButton(
                                        icon: Icons.download_rounded,
                                        label: "Download",
                                        color: const Color(0xFF7C3AED),
                                        onTap: () => Get.to(
                                          () => BannerDetailsScreen(
                                            imageUrl: announcement.imageUrl!,
                                            title: announcement.title,
                                          ),
                                        ),
                                      ),

                                    // 4. Publish / Unpublish Button
                                    if (announcement.isEditable)
                                      _buildCardActionButton(
                                        icon: announcement.publishStatus
                                                .toLowerCase()
                                                .contains('publish')
                                            ? Icons.unpublished_outlined
                                            : Icons.publish_rounded,
                                        label: announcement.publishStatus
                                                .toLowerCase()
                                                .contains('publish')
                                            ? "Unpublish"
                                            : "Publish",
                                        color: announcement.publishStatus
                                                .toLowerCase()
                                                .contains('publish')
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF0038A8),
                                        onTap: () {
                                          if (announcement.publishStatus
                                              .toLowerCase()
                                              .contains('publish')) {
                                            Get.dialog(
                                              AlertDialog(
                                                title: const Text(
                                                  "Unpublish Announcement",
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to unpublish this announcement?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Get.back(),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      controller
                                                          .unpublishAnnouncement(
                                                            announcement.id,
                                                          );
                                                    },
                                                    child: const Text(
                                                      "Unpublish",
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            Get.bottomSheet(
                                              Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(20),
                                                      ),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "PUBLISH TO",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(0xFF1E293B),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    _buildPublishOption(
                                                      icon: Icons.person_outline,
                                                      title: "Parents Only",
                                                      color: Colors.blue,
                                                      onTap: () {
                                                        Get.back();
                                                        controller
                                                            .publishAnnouncement(
                                                              announcement.id,
                                                              sendToParents: 1,
                                                              sendToTeachers: 0,
                                                              sendToSupportCrew: 0,
                                                            );
                                                      },
                                                    ),
                                                    _buildPublishOption(
                                                      icon: Icons.school_outlined,
                                                      title: "Teachers Only",
                                                      color: Colors.orange,
                                                      onTap: () {
                                                        Get.back();
                                                        controller
                                                            .publishAnnouncement(
                                                              announcement.id,
                                                              sendToParents: 0,
                                                              sendToTeachers: 1,
                                                              sendToSupportCrew: 0,
                                                            );
                                                      },
                                                    ),
                                                    _buildPublishOption(
                                                      icon: Icons.support_agent_outlined,
                                                      title: "Support Crew Only",
                                                      color: Colors.teal,
                                                      onTap: () {
                                                        Get.back();
                                                        controller
                                                            .publishAnnouncement(
                                                              announcement.id,
                                                              sendToParents: 0,
                                                              sendToTeachers: 0,
                                                              sendToSupportCrew: 1,
                                                            );
                                                      },
                                                    ),
                                                    _buildPublishOption(
                                                      icon: Icons.group_outlined,
                                                      title:
                                                          "Parents & Teachers",
                                                      color: Colors.indigo,
                                                      onTap: () {
                                                        Get.back();
                                                        controller
                                                            .publishAnnouncement(
                                                              announcement.id,
                                                              sendToParents: 1,
                                                              sendToTeachers: 1,
                                                              sendToSupportCrew: 0,
                                                            );
                                                      },
                                                    ),
                                                    _buildPublishOption(
                                                      icon: Icons.groups_outlined,
                                                      title:
                                                          "All (Parents, Teachers & Support Crew)",
                                                      color: Colors.purple,
                                                      onTap: () {
                                                        Get.back();
                                                        controller
                                                            .publishAnnouncement(
                                                              announcement.id,
                                                              sendToParents: 1,
                                                              sendToTeachers: 1,
                                                              sendToSupportCrew: 1,
                                                            );
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ],

                          ),
                        ),
                      ],
                    ),
                  );
                },
            ),
          );
        }),
      ),
      ),
    );
  }

  void _showToggleConfirmationDialog(
    BuildContext context,
    AnnouncementController controller,
    dynamic announcement,
  ) {
    final bool isActive = announcement.status == 1;
    final String actionText = isActive ? "Deactivate" : "Activate";
    final Color actionColor = isActive ? const Color(0xFFEF4444) : const Color(0xFF16A34A);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Colors.white,
              width: 1.8,
            ),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon Container
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive
                        ? Icons.power_settings_new_rounded
                        : Icons.check_circle_rounded,
                    color: actionColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  "$actionText Announcement?",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),

                // Content Description
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "Are you sure you want to "),
                      TextSpan(
                        text: actionText.toLowerCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                      const TextSpan(text: " the announcement "),
                      TextSpan(
                        text: '"${announcement.title}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons Row: Cancel & Confirm
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          controller.toggleStatus(announcement.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "CONFIRM",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return Colors.red;
      case 'notice':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCardActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublishOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

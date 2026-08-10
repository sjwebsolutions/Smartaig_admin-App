import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/getX/announcement_controller.dart';
import 'announcement_detail_screen.dart';
import 'add_announcement_screen.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnouncementController controller = Get.put(AnnouncementController());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3E9FF),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF0038A8),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "ANNOUNCEMENTS",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() =>  AddAnnouncementScreen()),
          backgroundColor: const Color(0xFF1E293B),
          child: const Icon(Icons.add, color: Colors.white),
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
              padding: const EdgeInsets.all(16),
              itemCount: controller.announcements.length,
              itemBuilder: (context, index) {
                final announcement = controller.announcements[index];
                return GestureDetector(
                  onTap: () {
                    Get.to(() => AnnouncementDetailScreen(id: announcement.id));
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.withAlpha(40)),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(announcement.type).withAlpha(30),
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
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          if (announcement.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                announcement.imageUrl!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  announcement.createdBy,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: announcement.status == 1,
                                  activeColor: Colors.green,
                                  onChanged: announcement.isEditable
                                      ? (val) {
                                          controller.toggleStatus(announcement.id);
                                        }
                                      : null, // Disable if not editable
                                ),
                              ),
                              if (announcement.isEditable && 
                                  announcement.submitStatus.toLowerCase() != 'locked' && 
                                  announcement.submitStatus.toLowerCase() != 'submitted')
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  icon: const Icon(Icons.edit_note, size: 24, color: Colors.blue),
                                  onPressed: () async {
                                    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                                    await controller.fetchAnnouncementDetails(announcement.id);
                                    Get.back(); // close loading dialog
                                    if (controller.announcementDetail.value != null) {
                                      Get.to(() => AddAnnouncementScreen(announcement: controller.announcementDetail.value));
                                    }
                                  },
                                ),
                              if (announcement.isEditable) ...[
                                // Check if it's currently locked
                                if (announcement.submitStatus.toLowerCase() == 'locked' || 
                                    announcement.submitStatus.toLowerCase() == 'submitted')
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    icon: const Icon(Icons.lock, size: 20, color: Colors.orange),
                                    onPressed: () {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text("Unlock Announcement"),
                                          content: const Text("Are you sure you want to unlock this announcement?"),
                                          actions: [
                                            TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                                controller.unlockAnnouncement(announcement.id);
                                              },
                                              child: const Text("Unlock", style: TextStyle(color: Colors.green)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    icon: const Icon(Icons.lock_open, size: 20, color: Colors.green),
                                    onPressed: () {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text("Lock Announcement"),
                                          content: const Text("Are you sure you want to lock this announcement?"),
                                          actions: [
                                            TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                                controller.lockAnnouncement(announcement.id);
                                              },
                                              child: const Text("Lock", style: TextStyle(color: Colors.orange)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                              if (announcement.isEditable)
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  icon: Icon(
                                    announcement.publishStatus.toLowerCase().contains('publish')
                                        ? Icons.unpublished
                                        : Icons.publish,
                                    size: 20,
                                    color: announcement.publishStatus.toLowerCase().contains('publish')
                                        ? Colors.redAccent
                                        : Colors.indigo,
                                  ),
                                  onPressed: () {
                                    if (announcement.publishStatus.toLowerCase().contains('publish')) {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text("Unpublish Announcement"),
                                          content: const Text("Are you sure you want to unpublish this announcement?"),
                                          actions: [
                                            TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                                controller.unpublishAnnouncement(announcement.id);
                                              },
                                              child: const Text("Unpublish", style: TextStyle(color: Colors.redAccent)),
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
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "PUBLISH TO",
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                              ),
                                              const SizedBox(height: 20),
                                              _buildPublishOption(
                                                icon: Icons.person_outline,
                                                title: "Parents Only",
                                                color: Colors.blue,
                                                onTap: () {
                                                  Get.back();
                                                  controller.publishAnnouncement(announcement.id, sendToParents: 1, sendToTeachers: 0);
                                                },
                                              ),
                                              _buildPublishOption(
                                                icon: Icons.school_outlined,
                                                title: "Teachers Only",
                                                color: Colors.orange,
                                                onTap: () {
                                                  Get.back();
                                                  controller.publishAnnouncement(announcement.id, sendToParents: 0, sendToTeachers: 1);
                                                },
                                              ),
                                              _buildPublishOption(
                                                icon: Icons.group_outlined,
                                                title: "Both Parents & Teachers",
                                                color: Colors.indigo,
                                                onTap: () {
                                                  Get.back();
                                                  controller.publishAnnouncement(announcement.id, sendToParents: 1, sendToTeachers: 1);
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
                  ),
                );
              },
            ),
          );
        }),
      ),
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

  Widget _buildPublishOption({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}

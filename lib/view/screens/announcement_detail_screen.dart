import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/getX/announcement_controller.dart';
import 'add_announcement_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final int id;
  const AnnouncementDetailScreen({super.key, required this.id});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final AnnouncementController controller = Get.find<AnnouncementController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAnnouncementDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            "ANNOUNCEMENT DETAILS",
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
        body: Obx(() {
        if (controller.isLoadingDetails.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final detail = controller.announcementDetail.value;
        if (detail == null) {
          return const Center(
            child: Text(
              "No details found",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchAnnouncementDetails(widget.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.imageUrl != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.network(
                        detail.imageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Text(
                    detail.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  "Schedule Information",
                  [
                    _buildInfoRow(Icons.calendar_today, "From Date", detail.fromDate),
                    if (detail.fromTime != null)
                      _buildInfoRow(Icons.access_time, "From Time", detail.fromTime!),
                    _buildInfoRow(Icons.calendar_today, "To Date", detail.toDate),
                    if (detail.toTime != null)
                      _buildInfoRow(Icons.access_time, "To Time", detail.toTime!),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  "Target Audience",
                  [
                    _buildInfoRow(Icons.group, "Target Type", detail.targetType.capitalizeFirst ?? detail.targetType),
                    _buildInfoRow(
                      Icons.person_outline,
                      "Send to Parents",
                      detail.sendToParents == 1 ? "Yes" : "No",
                    ),
                    _buildInfoRow(
                      Icons.school_outlined,
                      "Send to Teachers",
                      detail.sendToTeachers == 1 ? "Yes" : "No",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  "Status",
                  [
                    _buildInfoRow(Icons.info_outline, "Submit Status", detail.submitStatus.capitalizeFirst ?? detail.submitStatus),
                    _buildStatusToggleRow(
                      Icons.publish,
                      "Publish Status",
                      detail.publishStatus,
                      () => controller.toggleStatus(detail.id),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleRow(IconData icon, String label, String status, VoidCallback onToggle) {
    bool isActive = status.toLowerCase() == 'active' || status.toLowerCase() == 'published';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          Text(
            status.capitalizeFirst ?? status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: isActive,
              onChanged: (_) => onToggle(),
              activeColor: Colors.green,
              activeTrackColor: Colors.green.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

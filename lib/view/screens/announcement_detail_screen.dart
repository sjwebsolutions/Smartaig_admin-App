import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/announcement_model.dart';
import '../../view_models/getX/announcement_controller.dart';
import '../../utils/app_colors.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final int id;
  final Announcement? announcement;

  const AnnouncementDetailScreen({
    super.key,
    required this.id,
    this.announcement,
  });

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
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
      decoration: AppColors.screenDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: AppColors.appBarToolbarHeight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: AppColors.appBarCenterTitle,
          leading: const CustomBackButton(),
          title: const Text(
            "ANNOUNCEMENT DETAILS",
            style: AppColors.appBarTitleStyle,
          ),
        ),
        body: Obx(() {
          final detail = controller.announcementDetail.value;
          final fallback = widget.announcement ??
              controller.announcements.firstWhereOrNull((a) => a.id == widget.id);

          if (controller.isLoadingDetails.value && detail == null && fallback == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (detail == null && fallback == null) {
            return const Center(
              child: Text(
                "No details found",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            );
          }

          final String title = detail?.title ?? fallback?.title ?? "";
          final String description = detail?.description ?? fallback?.description ?? "";
          final String? imageUrl = detail?.imageUrl ?? fallback?.imageUrl;
          final String fromDate = detail?.fromDate ?? fallback?.fromDate ?? "";
          final String? fromTime = detail?.fromTime ?? fallback?.fromTime;
          final String toDate = detail?.toDate ?? fallback?.toDate ?? "";
          final String? toTime = detail?.toTime ?? fallback?.toTime;
          final String targetType = detail?.targetType ?? fallback?.targetsSummary ?? "All";
          final int sendToParents = detail?.sendToParents ?? fallback?.sendToParents ?? 0;
          final int sendToTeachers = detail?.sendToTeachers ?? fallback?.sendToTeachers ?? 0;
          final int sendToSupportCrew = detail?.sendToSupportCrew ?? fallback?.sendToSupportCrew ?? 0;
          final String submitStatus = detail?.submitStatus ?? fallback?.submitStatus ?? "";
          final String publishStatus = detail?.publishStatus ?? fallback?.publishStatus ?? "";
          final String createdBy = fallback?.createdBy ?? "";

          return RefreshIndicator(
            onRefresh: () => controller.fetchAnnouncementDetails(widget.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: AppColors.cardBorderRadius,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection("Schedule Information", [
                    _buildInfoRow(
                      Icons.calendar_today,
                      "From Date",
                      fromDate,
                    ),
                    if (fromTime != null && fromTime.isNotEmpty)
                      _buildInfoRow(
                        Icons.access_time,
                        "From Time",
                        fromTime,
                      ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      "To Date",
                      toDate,
                    ),
                    if (toTime != null && toTime.isNotEmpty)
                      _buildInfoRow(
                        Icons.access_time,
                        "To Time",
                        toTime,
                      ),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection("Target Audience", [
                    if (createdBy.isNotEmpty)
                      _buildInfoRow(
                        Icons.person,
                        "Created By",
                        createdBy,
                      ),
                    _buildInfoRow(
                      Icons.group,
                      "Target Scope",
                      targetType.capitalizeFirst ?? targetType,
                    ),
                    _buildInfoRow(
                      Icons.person_outline,
                      "Send to Parents",
                      sendToParents == 1 ? "Yes" : "No",
                    ),
                    _buildInfoRow(
                      Icons.school_outlined,
                      "Send to Teachers",
                      sendToTeachers == 1 ? "Yes" : "No",
                    ),
                    _buildInfoRow(
                      Icons.support_agent_outlined,
                      "Send to Support Crew",
                      sendToSupportCrew == 1 ? "Yes" : "No",
                    ),
                  ]),
                  const SizedBox(height: 16),
                  if (submitStatus.isNotEmpty || publishStatus.isNotEmpty)
                    _buildInfoSection("Status", [
                      if (submitStatus.isNotEmpty)
                        _buildInfoRow(
                          Icons.info_outline,
                          "Submit Status",
                          submitStatus.capitalizeFirst ?? submitStatus,
                        ),
                      if (publishStatus.isNotEmpty)
                        _buildStatusToggleRow(
                          Icons.publish,
                          "Publish Status",
                          publishStatus,
                          () => controller.toggleStatus(widget.id),
                        ),
                    ]),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        }),
      ),
    );
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
            color: AppColors.cardColor,
            borderRadius: AppColors.cardBorderRadius,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(children: children),
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

  Widget _buildStatusToggleRow(
    IconData icon,
    String label,
    String status,
    VoidCallback onToggle,
  ) {
    bool isActive =
        status.toLowerCase() == 'active' || status.toLowerCase() == 'published';
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
              activeThumbColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

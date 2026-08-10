import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/meeting_controller.dart';
import 'package:smart_aig_admins_app/models/meeting_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingScreen extends StatelessWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MeetingController controller = Get.put(MeetingController());
    final bool isPushed = ModalRoute.of(context)?.canPop ?? false;

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
        appBar: isPushed 
          ? AppBar(
              toolbarHeight: 80,
              backgroundColor: const Color(0xFF0038A8),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "MEETINGS",
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
            )
          : null,
        body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.meetings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No meetings scheduled",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMeetings(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.meetings.length,
            itemBuilder: (context, index) {
              final meeting = controller.meetings[index];
              return _buildMeetingCard(meeting);
            },
          ),
        );
      }),
    ));
  }

  Widget _buildMeetingCard(Meeting meeting) {
    final now = DateTime.now();
    final start = meeting.startDateTime;
    final end = meeting.endDateTime;

    String displayStatus = "";
    Color statusColor = Colors.grey;
    bool isEnded = false;

    if (meeting.status == 'past' || now.isAfter(end)) {
      displayStatus = "OVER";
      statusColor = Colors.red;
      isEnded = true;
    } else if (now.isAfter(start) && now.isBefore(end)) {
      displayStatus = "LIVE";
      statusColor = Colors.green;
    } else {
      displayStatus = "UPCOMING";
      statusColor = const Color(0xFF0038A8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isEnded ? Colors.transparent : statusColor.withAlpha(30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(isEnded ? 10 : 20),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (displayStatus == "LIVE")
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      displayStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  meeting.formattedDate,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoTile(Icons.access_time_rounded, "${meeting.fromTime} - ${meeting.toTime}"),
                if (meeting.remarks != null && 
                    meeting.remarks!.isNotEmpty && 
                    meeting.remarks!.trim() != meeting.subject.trim()) ...[
                  const SizedBox(height: 10),
                  Text(
                    meeting.remarks!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!isEnded && meeting.liveLink != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL(meeting.liveLink!),
                          icon: const Icon(Icons.videocam_rounded, size: 18),
                          label: const Text("Join Meeting"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0038A8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    if (isEnded)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Meeting Over",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    if (meeting.recordingLink != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchURL(meeting.recordingLink!),
                          icon: const Icon(Icons.play_circle_outline, size: 18),
                          label: const Text("Recording"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0038A8),
                            side: const BorderSide(color: Color(0xFF0038A8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Could not launch meeting link");
    }
  }
}

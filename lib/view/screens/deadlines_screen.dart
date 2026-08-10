import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/deadlines_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeadlinesController controller = Get.put(DeadlinesController());

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
            "DEADLINES",
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
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.deadlinesList.isEmpty) {
          return const Center(child: Text("No deadlines available"));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDeadlines(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.deadlinesList.length,
            itemBuilder: (context, index) {
              final deadline = controller.deadlinesList[index];
              return _buildDeadlineCard(deadline);
            },
          ),
        );
      }),
    ));
  }

  Widget _buildDeadlineCard(deadline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  deadline.name ?? "No Name",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0038A8).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deadline.boardType?.toUpperCase() ?? "",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0038A8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, "Closing Date", deadline.formattedDateOfSubmission ?? "N/A"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.timer_outlined, "Days Remaining", "${deadline.daysRemaining ?? 0} Days", 
            valueColor: (deadline.daysRemaining ?? 0) <= 5 ? Colors.red : Colors.green),
          const SizedBox(height: 12),
          if (deadline.remarks != null && deadline.remarks!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withAlpha(50)),
              ),
              child: Text(
                deadline.remarks!,
                style: TextStyle(fontSize: 12, color: Colors.orange[900], height: 1.4),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (deadline.link != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(deadline.link!),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text("Open Portal"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0038A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              if (deadline.link != null && deadline.docLink != null) const SizedBox(width: 12),
              if (deadline.docLink != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      String url = deadline.docLink!;
                      if (!url.startsWith("http")) {
                        url = "https://smartaig.com/$url";
                      }
                      _launchUrl(url);
                    },
                    icon: const Icon(Icons.description_outlined, size: 18),
                    label: const Text("View Doc"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0038A8),
                      side: const BorderSide(color: Color(0xFF0038A8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Error", "Could not launch $urlString");
      }
    } catch (e) {
      Get.snackbar("Error", "Could not open link");
    }
  }
}

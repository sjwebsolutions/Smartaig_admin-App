import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_aig_admins_app/view_models/getX/admission_detail_controller.dart';
import 'package:smart_aig_admins_app/models/admission_detail_model.dart';

class AdmissionDetailScreen extends StatelessWidget {
  final int enquiryId;
  const AdmissionDetailScreen({super.key, required this.enquiryId});

  @override
  Widget build(BuildContext context) {
    final AdmissionDetailController controller = Get.put(
      AdmissionDetailController(id: enquiryId),
      tag: enquiryId.toString(),
    );

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF8F9FE)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFFF8F9FE),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: const Color(0xFF1E293B),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "ENQUIRY DETAILS",
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.success.value ||
              controller.enquiryDetail.value == null) {
            return const Center(child: Text("Failed to load enquiry details"));
          }

          final data = controller.enquiryDetail.value!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(data),
                const SizedBox(height: 16),
                _buildSectionTitle("Personal Information"),
                _buildInfoCard([
                  _buildDetailRow("Full Name", data.fullName),
                  _buildDetailRow("Gender", data.gender),
                  _buildDetailRow("Date of Birth", data.dob),
                  _buildDetailRow("Aadhaar No", data.aadhaarNo ?? 'N/A'),
                  _buildDetailRow("Category", data.category ?? 'N/A'),
                  _buildDetailRow("Religion", data.religion ?? 'N/A'),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle("Academic Details"),
                _buildInfoCard([
                  _buildDetailRow("Class", data.className),
                  _buildDetailRow("Session", data.sessionYear),
                  _buildDetailRow(
                    "Previous School",
                    data.previousSchool ?? 'N/A',
                  ),
                  _buildDetailRow(
                    "Last Class",
                    data.lastClassAttended ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle("Family Information"),
                _buildInfoCard([
                  _buildDetailRow("Father's Name", data.fatherName ?? 'N/A'),
                  _buildDetailRow(
                    "Father's Mobile",
                    data.fatherMobile ?? 'N/A',
                  ),
                  _buildDetailRow("Mother's Name", data.motherName ?? 'N/A'),
                  _buildDetailRow(
                    "Mother's Mobile",
                    data.motherMobile ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle("Address Information"),
                _buildInfoCard([
                  _buildDetailRow("Address", data.address),
                  _buildDetailRow(
                    "City/State",
                    "${data.city ?? 'N/A'}/${data.state ?? 'N/A'}",
                  ),
                  _buildDetailRow("Pincode", data.pincode ?? 'N/A'),
                ]),
                const SizedBox(height: 16),
                _buildSectionTitle("Other Details"),
                _buildInfoCard([
                  _buildDetailRow(
                    "Interest Level",
                    data.interestLevel ?? 'N/A',
                  ),
                  _buildDetailRow(
                    "Follow-up Status",
                    data.followUpStatus ?? 'N/A',
                  ),
                  _buildDetailRow("Remarks", data.remarks ?? 'N/A'),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeaderCard(EnquiryDetailData data) {
    Color statusColor;
    switch (data.status.toLowerCase()) {
      case 'under_process':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      default:
        statusColor = const Color(0xFF3B82F6);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF0038A8).withOpacity(0.1),
            backgroundImage: data.studentImageUrl != null
                ? NetworkImage(data.studentImageUrl!)
                : null,
            child: data.studentImageUrl == null
                ? const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF0038A8),
                    size: 40,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "ID: ${data.inquiryNumber}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0038A8),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_aig_admins_app/models/transport_location_requests_model.dart';
import 'package:smart_aig_admins_app/services/transport_service.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/transport_controller.dart';

class TransportLocationRequestDetailScreen extends StatefulWidget {
  final int requestId;
  final TransportLocationRequest? initialRequest;

  const TransportLocationRequestDetailScreen({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  @override
  State<TransportLocationRequestDetailScreen> createState() =>
      _TransportLocationRequestDetailScreenState();
}

class _TransportLocationRequestDetailScreenState
    extends State<TransportLocationRequestDetailScreen> {
  final TransportService _service = TransportService();
  late final TransportController controller;

  bool isLoading = false;
  TransportLocationRequest? request;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TransportController>()
        ? Get.find<TransportController>()
        : Get.put(TransportController());

    if (widget.initialRequest != null) {
      request = widget.initialRequest;
    }
    _loadRequestDetails();
  }

  Future<void> _loadRequestDetails() async {
    if (request == null) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final res = await _service.getLocationRequestDetails(widget.requestId);
      if (res['success'] == true && res['data'] != null) {
        final Map<String, dynamic> data = res['data'];
        setState(() {
          request = TransportLocationRequest.fromJson(data);
          isLoading = false;
        });
      } else {
        if (request == null) {
          setState(() {
            errorMessage = res['message'] ?? "Failed to load request details.";
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (request == null) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      CustomSnackBar.showError("Invalid Phone", "No valid phone number provided.");
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error launching phone call: $e");
      }
      CustomSnackBar.showError("Call Failed", "Could not place call to $cleanPhone.");
    }
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
          title: Text(
            "REQUEST ${widget.requestId} DETAILS",
            style: AppColors.appBarTitleStyle,
          ),
        ),
        body: SafeArea(
          child: _buildBodyContent(),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading && request == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null && request == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 54, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRequestDetails,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final req = request!;
    final student = req.student;
    final transport = req.transport;
    final oldCoords = req.oldCoordinates;
    final propCoords = req.proposedCoordinates;
    final audit = req.audit;

    Color statusColor;
    Color statusBgColor;

    switch (req.status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        break;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            children: [
              // Status Badge Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.2),
                ),
                child: Row(
                  children: [
                    Text(
                      "STATUS:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      req.statusLabel.toUpperCase(),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Text(
                        "Via ${req.requestedVia ?? 'App'}",
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Student Information Card
              if (student != null) ...[
                const Text(
                  "STUDENT INFORMATION",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF132A60), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: AppColors.cardBorderRadius,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF90A4AE).withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                            child: Text(
                              student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : 'S',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                if (student.className != null)
                                  Text(
                                    "Class ${student.className}-${student.sectionName ?? ''} ${student.uniqueId != null ? '• ID: ${student.uniqueId}' : ''}",
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                              ],
                            ),
                          ),
                          if (student.parentPhone != null && student.parentPhone!.isNotEmpty)
                            IconButton(
                              onPressed: () => _makePhoneCall(student.parentPhone!),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.12),
                              ),
                              icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 20),
                            ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Requested By: ${req.requestedByName ?? 'Parent'} (${req.requestedByRole ?? 'Parent'})",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ),
                          Text(
                            req.requestedAtTime ?? req.requestedAt ?? '',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Transport Details Card
              if (transport != null) ...[
                const Text(
                  "TRANSPORT DETAILS",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF132A60), letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: AppColors.cardBorderRadius,
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_rounded, size: 20, color: Color(0xFF0284C7)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${transport.busNumber ?? 'Bus'} • ${transport.routeName ?? ''}",
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                            ),
                          ),
                        ],
                      ),
                      if (transport.stoppageName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Current Stoppage: ${transport.stoppageName}",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Location Comparison Card
              const Text(
                "LOCATION CHANGE COMPARISON",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF132A60), letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppColors.cardBorderRadius,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF90A4AE).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Current Registered Address:",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                oldCoords?.address ?? "Not set",
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                              ),
                              if (oldCoords != null &&
                                  (oldCoords.pickupLatitude != null || oldCoords.dropLatitude != null)) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (oldCoords.pickupLatitude != null && oldCoords.pickupLongitude != null)
                                      _buildCoordsChip(
                                        icon: Icons.pin_drop_rounded,
                                        label: "Pickup GPS",
                                        lat: oldCoords.pickupLatitude,
                                        lng: oldCoords.pickupLongitude,
                                        color: const Color(0xFF0284C7),
                                        bgColor: const Color(0xFFE0F2FE),
                                      ),
                                    if (oldCoords.dropLatitude != null &&
                                        oldCoords.dropLongitude != null &&
                                        (oldCoords.dropLatitude != oldCoords.pickupLatitude ||
                                         oldCoords.dropLongitude != oldCoords.pickupLongitude))
                                      _buildCoordsChip(
                                        icon: Icons.place_rounded,
                                        label: "Drop GPS",
                                        lat: oldCoords.dropLatitude,
                                        lng: oldCoords.dropLongitude,
                                        color: const Color(0xFF6366F1),
                                        bgColor: const Color(0xFFEEF2FF),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 24),
                          Icon(Icons.arrow_downward_rounded, size: 18, color: Color(0xFF10B981)),
                          SizedBox(width: 6),
                          Text(
                            "Requested Change To:",
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ),

                    // Proposed Address
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Proposed New Address:",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                propCoords?.address ?? "Address not specified",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              if (propCoords != null &&
                                  (propCoords.pickupLatitude != null || propCoords.dropLatitude != null)) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (propCoords.pickupLatitude != null && propCoords.pickupLongitude != null)
                                      _buildCoordsChip(
                                        icon: Icons.pin_drop_rounded,
                                        label: "Pickup GPS",
                                        lat: propCoords.pickupLatitude,
                                        lng: propCoords.pickupLongitude,
                                        color: const Color(0xFF059669),
                                        bgColor: const Color(0xFFD1FAE5),
                                      ),
                                    if (propCoords.dropLatitude != null &&
                                        propCoords.dropLongitude != null &&
                                        (propCoords.dropLatitude != propCoords.pickupLatitude ||
                                         propCoords.dropLongitude != propCoords.pickupLongitude))
                                      _buildCoordsChip(
                                        icon: Icons.place_rounded,
                                        label: "Drop GPS",
                                        lat: propCoords.dropLatitude,
                                        lng: propCoords.dropLongitude,
                                        color: const Color(0xFF0D9488),
                                        bgColor: const Color(0xFFCCFBF1),
                                      ),
                                  ],
                                ),
                              ],
                              if ((propCoords?.notes != null && propCoords!.notes!.isNotEmpty) ||
                                  (req.addressNotes != null && req.addressNotes!.isNotEmpty)) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Notes: \"${propCoords?.notes ?? req.addressNotes}\"",
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: Color(0xFFB45309)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Audit / Action Info
              if (audit != null &&
                  (audit.rejectionReason != null || audit.actionByName != null || audit.actionAt != null)) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: req.status.toLowerCase() == 'rejected' ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                    borderRadius: AppColors.cardBorderRadius,
                    border: Border.all(
                      color: req.status.toLowerCase() == 'rejected' ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            req.status.toLowerCase() == 'rejected' ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                            size: 18,
                            color: req.status.toLowerCase() == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            req.status.toLowerCase() == 'rejected' ? "Rejection Reason & Action" : "Approval Action Details",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: req.status.toLowerCase() == 'rejected' ? const Color(0xFF991B1B) : const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                      if (audit.rejectionReason != null && audit.rejectionReason!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          audit.rejectionReason!,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF7F1D1D)),
                        ),
                      ],
                      if (audit.actionByName != null || audit.actionAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Action by: ${audit.actionByName ?? 'Admin'}"
                          "${audit.actionAt != null ? ' • ${_formatActionAt(audit.actionAt!)}' : ''}",
                          style: TextStyle(
                            fontSize: 11.5,
                            color: req.status.toLowerCase() == 'rejected' ? const Color(0xFF991B1B) : const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Action Buttons if Pending
        if (req.status.toLowerCase().contains('pending'))
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _showApproveDialog(req),
                      icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                      label: const Text("Approve", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRejectDialog(req),
                      icon: const Icon(Icons.cancel_rounded, size: 18, color: Colors.white),
                      label: const Text("Reject", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCoordsChip({
    required IconData icon,
    required String label,
    required double? lat,
    required double? lng,
    required Color color,
    required Color bgColor,
  }) {
    if (lat == null || lng == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            "$label: $lat, $lng",
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(TransportLocationRequest req) {
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
              SizedBox(width: 8),
              Text(
                "Approve Request",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to approve the transport location change for ${req.student?.name ?? 'this student'}?",
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
              ),
              if (req.proposedCoordinates?.address != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "New Address: ${req.proposedCoordinates!.address}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Optional remarks...",
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final ok = await controller.approveRequest(
                  req.id,
                  remarks: remarksController.text.trim(),
                );
                if (ok) {
                  _loadRequestDetails();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(TransportLocationRequest req) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 8),
              Text(
                "Reject Request",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please enter a reason for rejecting the request for ${req.student?.name ?? 'this student'}:",
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Rejection reason is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Reason for rejection...",
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  final ok = await controller.rejectRequest(
                    req.id,
                    reasonController.text.trim(),
                  );
                  if (ok) {
                    _loadRequestDetails();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _formatActionAt(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }
}

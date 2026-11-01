import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/event_pass_scan_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class EventScanResultScreen extends StatelessWidget {
  final EventPassScanModel scanResult;

  const EventScanResultScreen({
    super.key,
    required this.scanResult,
  });

  @override
  Widget build(BuildContext context) {
    final data = scanResult.data;
    final pass = data?.pass;
    final event = data?.event;
    final student = data?.student;
    final approvedAttendees = data?.approvedAttendees ?? [];

    final bool isWarning = scanResult.isAlreadyCheckedIn || !scanResult.success || scanResult.warning != null;
    final Color alertBgColor = isWarning ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final Color alertBorderColor = isWarning ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0);
    final Color alertIconColor = isWarning ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final Color alertTextColor = isWarning ? const Color(0xFF991B1B) : const Color(0xFF065F46);

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
              "PASS SCAN RESULT",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(color: alertIconColor.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF90A4AE).withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alert Banner Header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: alertBgColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(bottom: BorderSide(color: alertBorderColor, width: 1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isWarning ? Icons.report_problem_rounded : Icons.check_circle_rounded,
                          color: alertIconColor,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWarning ? "DUPLICATE CHECK-IN ALERT" : "PASS VALIDATED SUCCESSFULLY",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: alertTextColor,
                                ),
                              ),
                              if (scanResult.warning != null && scanResult.warning!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  scanResult.warning!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: alertTextColor,
                                    height: 1.35,
                                  ),
                                ),
                              ] else if (scanResult.message != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  scanResult.message!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: alertTextColor,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
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
                        // Pass Details Header Row
                        if (pass != null) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.qr_code_rounded, size: 15, color: Color(0xFF132A60)),
                                    const SizedBox(width: 5),
                                    Text(
                                      pass.passNumber,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF132A60),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isWarning ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  pass.checkinStatus.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Student Details Box
                        if (student != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: student.photoUrl.isNotEmpty
                                          ? Image.network(
                                              student.photoUrl,
                                              width: 52,
                                              height: 52,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 52,
                                                height: 52,
                                                color: const Color(0xFFEEF2FF),
                                                child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 26),
                                              ),
                                            )
                                          : Container(
                                              width: 52,
                                              height: 52,
                                              color: const Color(0xFFEEF2FF),
                                              child: const Icon(Icons.person, color: Color(0xFF6366F1), size: 26),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.studentName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "Class: ${student.classSection} • Admission No: ${student.admissionNumber}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                          if (student.rollNo.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              "Roll No: ${student.rollNo}",
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (student.fatherName.isNotEmpty)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Father", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                            Text("${student.fatherName}\n${student.fatherMobile}", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          ],
                                        ),
                                      ),
                                    if (student.motherName.isNotEmpty)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Mother", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                            Text("${student.motherName}\n${student.motherMobile}", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Event Info Box
                        if (event != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE9D5FF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event_note_rounded, size: 18, color: Color(0xFF7E22CE)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (event.venue.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Venue: ${event.venue}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7E22CE),
                                    ),
                                  ),
                                ],
                                if (event.startDate.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Dates: ${event.startDate} - ${event.endDate} (${event.startTime} - ${event.endTime})",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9333EA),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Approved Attendees List
                        if (approvedAttendees.isNotEmpty) ...[
                          Row(
                            children: [
                              const Icon(Icons.groups_rounded, size: 18, color: Color(0xFF132A60)),
                              const SizedBox(width: 8),
                              Text(
                                "APPROVED ATTENDEES (${approvedAttendees.length})",
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          ...approvedAttendees.map((attendee) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: attendee.photoUrl.isNotEmpty
                                          ? Image.network(
                                              attendee.photoUrl,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 44,
                                                height: 44,
                                                color: const Color(0xFFE0F2FE),
                                                child: const Icon(Icons.person, color: Color(0xFF0284C7), size: 22),
                                              ),
                                            )
                                          : Container(
                                              width: 44,
                                              height: 44,
                                              color: const Color(0xFFE0F2FE),
                                              child: const Icon(Icons.person, color: Color(0xFF0284C7), size: 22),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attendee.name,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            "Relation: ${attendee.personType} • ${attendee.mobileNo}",
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          if (attendee.maskedAadhaar.isNotEmpty)
                                            Text(
                                              "Aadhaar: ${attendee.maskedAadhaar}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: attendee.isCheckedIn ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        attendee.isCheckedIn ? "Checked In" : "Pending",
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: attendee.isCheckedIn ? const Color(0xFF059669) : const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            color: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
                label: const Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF132A60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: const Color(0xFF132A60).withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

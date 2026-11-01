import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_aig_admins_app/models/free_staff_model.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_detail_model.dart';
import 'package:smart_aig_admins_app/models/staff_duties_model.dart';
import 'package:smart_aig_admins_app/services/invigilator_duty_service.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class InvigilatorDutyDetailScreen extends StatefulWidget {
  final int planId;
  final String planName;

  const InvigilatorDutyDetailScreen({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  State<InvigilatorDutyDetailScreen> createState() => _InvigilatorDutyDetailScreenState();
}

class _InvigilatorDutyDetailScreenState extends State<InvigilatorDutyDetailScreen> {
  final InvigilatorDutyService _dutyService = InvigilatorDutyService();
  bool isLoading = true;
  bool isFreeStaffLoading = false;
  bool isStaffDutiesLoading = false;
  InvigilatorDutyDetail? detail;
  FreeStaffData? freeStaffData;
  StaffDutiesData? staffDutiesData;
  String? selectedDate;
  int activeTabIndex = 0; // 0: Assignments, 1: Free Staff, 2: Staff Overviews

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails({String? date}) async {
    setState(() => isLoading = true);
    final response = await _dutyService.getInvigilatorDutyDetails(widget.planId, date: date);
    if (response.success && response.data != null) {
      setState(() {
        detail = response.data;
        selectedDate = detail?.selectedDate;
        isLoading = false;
      });
      if (activeTabIndex == 1) {
        _fetchFreeStaff(date: selectedDate);
      } else if (activeTabIndex == 2) {
        _fetchStaffDuties();
      }
    } else {
      setState(() => isLoading = false);
      CustomSnackBar.showError("Error", "Failed to fetch details");
    }
  }

  Future<void> _fetchFreeStaff({String? date}) async {
    setState(() => isFreeStaffLoading = true);
    final response = await _dutyService.getFreeStaff(widget.planId, examDate: date);
    if (response.success && response.data != null) {
      setState(() {
        freeStaffData = response.data;
        isFreeStaffLoading = false;
      });
    } else {
      setState(() => isFreeStaffLoading = false);
      CustomSnackBar.showError("Error", "Failed to fetch free staff");
    }
  }

  Future<void> _fetchStaffDuties() async {
    setState(() => isStaffDutiesLoading = true);
    final response = await _dutyService.getStaffDuties(widget.planId);
    if (response.success && response.data != null) {
      setState(() {
        staffDutiesData = response.data;
        isStaffDutiesLoading = false;
      });
    } else {
      setState(() => isStaffDutiesLoading = false);
      CustomSnackBar.showError("Error", "Failed to fetch staff duties");
    }
  }

  void _showDateSelectionDialog() {
    if (detail == null || detail!.availableExamDates.isEmpty) return;

    Get.dialog(
      Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Icon & Title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A60).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF132A60),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Select Exam Date",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF132A60),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose a date to view duty assignments",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // Date Items List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: detail!.availableExamDates.length,
                  itemBuilder: (context, index) {
                    final dateObj = detail!.availableExamDates[index];
                    bool isSelected = dateObj.date == selectedDate;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          if (!isSelected) {
                            _fetchDetails(date: dateObj.date);
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  dateObj.formatted,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14,
                                    color: isSelected ? const Color(0xFF132A60) : const Color(0xFF334155),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(
              widget.planName.toUpperCase(),
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF132A60)))
              : detail == null
                  ? const Center(child: Text("No data found"))
                  : Column(
                      children: [
                        _buildDateInfoBanner(),
                        _buildToggleTabs(),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (activeTabIndex == 0) await _fetchDetails(date: selectedDate);
                              if (activeTabIndex == 1) await _fetchFreeStaff(date: selectedDate);
                              if (activeTabIndex == 2) await _fetchStaffDuties();
                            },
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              children: [
                                if (activeTabIndex == 0) ...[
                                  _buildSummaryCard(),
                                  const SizedBox(height: 16),
                                  const Row(
                                    children: [
                                      Icon(Icons.meeting_room_rounded, size: 18, color: Color(0xFF132A60)),
                                      SizedBox(width: 8),
                                      Text(
                                        "ROOM ASSIGNMENTS",
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ...detail!.rooms.map((room) => _buildRoomCard(room)),
                                ] else if (activeTabIndex == 1) ...[
                                  if (isFreeStaffLoading)
                                    const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: Color(0xFF132A60))))
                                  else if (freeStaffData == null || freeStaffData!.freeStaff.isEmpty)
                                    _buildEmptyFreeStaff()
                                  else ...[
                                    _buildFreeStaffCounts(),
                                    const SizedBox(height: 16),
                                    Text(
                                      "FREE STAFF MEMBERS (${freeStaffData!.freeStaff.length})",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
                                    ),
                                    const SizedBox(height: 10),
                                    ...freeStaffData!.freeStaff.map((staff) => _buildStaffCard(staff)),
                                  ]
                                ] else if (activeTabIndex == 2) ...[
                                  if (isStaffDutiesLoading)
                                    const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator(color: Color(0xFF132A60))))
                                  else if (staffDutiesData == null || staffDutiesData!.staffDuties.isEmpty)
                                    const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No staff duties found")))
                                  else ...[
                                    const Row(
                                      children: [
                                        Icon(Icons.groups_rounded, size: 18, color: Color(0xFF132A60)),
                                        SizedBox(width: 8),
                                        Text(
                                          "DUTY OVERVIEW BY STAFF",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...staffDutiesData!.staffDuties.map((duty) => _buildStaffDutyCard(duty)),
                                  ]
                                ],
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildDateInfoBanner() {
    if (activeTabIndex == 2) return const SizedBox(height: 8);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showDateSelectionDialog,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF4338CA), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            detail!.formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60), fontSize: 14.5),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              detail!.dayName,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF4338CA), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Tap to change exam date",
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.unfold_more_rounded, color: Color(0xFF475569), size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem("Room Wise", Icons.door_front_door_rounded, 0)),
          Expanded(child: _buildTabItem("Free Staff", Icons.person_search_rounded, 1)),
          Expanded(child: _buildTabItem("Duty View", Icons.groups_rounded, 2)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    bool isActive = activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => activeTabIndex = index);
        if (index == 1 && freeStaffData == null) {
          _fetchFreeStaff(date: selectedDate);
        } else if (index == 2 && staffDutiesData == null) {
          _fetchStaffDuties();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF132A60) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF132A60).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final s = detail!.summary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132A60).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A60).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF132A60), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ASSIGNMENT SUMMARY",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60), fontSize: 12, letterSpacing: 0.5),
                    ),
                    Text(
                      "${detail!.dayName}, ${detail!.formattedDate}",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (detail!.examTiming != null && detail!.examTiming!.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled_rounded, color: Color(0xFF4338CA), size: 13),
                      const SizedBox(width: 4),
                      Text(
                        detail!.examTiming!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4338CA), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
          ),

          Row(
            children: [
              Expanded(
                child: _buildSummaryBox("Total Rooms", s.totalRooms.toString(), Icons.door_front_door_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF), const Color(0xFFBFDBFE)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox("On Duty", s.totalTeachersOnDuty.toString(), Icons.assignment_turned_in_rounded, const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox("Available", s.totalFreeTeachers.toString(), Icons.person_search_rounded, const Color(0xFF4338CA), const Color(0xFFEEF2FF), const Color(0xFFC7D2FE)),
              ),
            ],
          ),

          if (s.unassignedRooms > 0 || s.fullyAssignedRooms > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 15, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Assigned Rooms: ${s.fullyAssignedRooms}",
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 12, width: 1, color: const Color(0xFFCBD5E1)),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          s.unassignedRooms > 0 ? Icons.warning_amber_rounded : Icons.task_alt_rounded,
                          size: 15,
                          color: s.unassignedRooms > 0 ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Unassigned: ${s.unassignedRooms}",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: s.unassignedRooms > 0 ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, IconData icon, Color color, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.5, color: color.withValues(alpha: 0.85), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(DutyRoom room) {
    final bool isUnassigned = room.status.toLowerCase().contains("unassigned") || room.assignedTeachers.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: isUnassigned ? const Color(0xFFFFEDD5) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF132A60).withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    room.roomName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
                if (room.status.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUnassigned ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isUnassigned ? const Color(0xFFFFEDD5) : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Text(
                      room.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUnassigned ? const Color(0xFFC2410C) : const Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.groups_rounded, size: 14, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        "${room.studentCount} Students",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRowWithIcon(Icons.class_rounded, "Classes", room.classes.join(", ")),
                const SizedBox(height: 8),
                _buildInfoRowWithIcon(Icons.menu_book_rounded, "Subjects", room.subjects.join(", ")),
                const SizedBox(height: 8),
                _buildInfoRowWithIcon(Icons.airline_seat_recline_normal_rounded, "Capacity", "${room.capacity} Seats"),
              ],
            ),
          ),

          // Teachers List Section
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, size: 15, color: Color(0xFF4338CA)),
                    const SizedBox(width: 6),
                    Text(
                      "TEACHERS ON DUTY (${room.assignedTeachers.length})",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4338CA), letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (room.assignedTeachers.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEA580C)),
                        SizedBox(width: 6),
                        Text(
                          "No teachers assigned to this room yet",
                          style: TextStyle(fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else
                  ...room.assignedTeachers.map((teacher) => _buildTeacherListItem(teacher)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherListItem(AssignedTeacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF132A60).withValues(alpha: 0.08),
            child: Text(
              teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60), fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                Row(
                  children: [
                    Text(
                      teacher.staffType.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                    if (teacher.designation != null && teacher.designation!.isNotEmpty) ...[
                      Text(
                        " • ${teacher.designation}",
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (teacher.phone != null && teacher.phone!.isNotEmpty)
            _buildContactActions(teacher.phone!),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      CustomSnackBar.showError("Invalid Phone", "No valid phone number provided.");
      return;
    }
    final Uri url = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      CustomSnackBar.showError("Call Failed", "Could not place call to $cleanPhone.");
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isEmpty) {
      CustomSnackBar.showError("Invalid Phone", "No valid WhatsApp number provided.");
      return;
    }
    final Uri url = Uri.parse("https://wa.me/$cleanPhone");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        CustomSnackBar.showError("WhatsApp Error", "Could not open WhatsApp for $cleanPhone.");
      }
    } catch (e) {
      CustomSnackBar.showError("WhatsApp Error", "Could not open WhatsApp.");
    }
  }

  Widget _buildContactActions(String phone) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _makePhoneCall(phone),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone_enabled_rounded, size: 13, color: Colors.green),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => _openWhatsApp(phone),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.whatsapp, size: 13, color: Color(0xFF25D366)),
                SizedBox(width: 4),
                Text(
                  "WhatsApp",
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF25D366)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Free Staff Section UI ---

  Widget _buildFreeStaffCounts() {
    final c = freeStaffData!.counts;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(color: const Color(0xFF132A60).withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF4338CA).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF4338CA), size: 18),
              ),
              const SizedBox(width: 10),
              const Text("Staff Availability", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60), fontSize: 14)),
              const Spacer(),
              _buildCountBadge("Available Today", const Color(0xFF4338CA)),
            ],
          ),
          const Divider(height: 20, thickness: 0.8, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox("Total Teacher", c.totalStaff.toString(), Icons.groups_rounded, const Color(0xFF475569), const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox("Busy Teacher", c.assignedStaff.toString(), Icons.work_rounded, const Color(0xFFEA580C), const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox("Free Teacher", c.freeStaff.toString(), Icons.how_to_reg_rounded, const Color(0xFF059669), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF90A4AE).withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF132A60).withValues(alpha: 0.08),
              child: Text(
                staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60), fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          staff.staffType.toUpperCase(),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (staff.designation != null && staff.designation!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text("•  ${staff.designation}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                  if (staff.teachingSubjects.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: staff.teachingSubjects.map((s) => _buildMiniBadge(s)).toList(),
                    ),
                  ],
                  if (staff.phone != null && staff.phone!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildContactActions(staff.phone!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
      ),
    );
  }

  Widget _buildStaffDutyCard(StaffDutyMember duty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF90A4AE).withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF132A60).withValues(alpha: 0.08),
                  child: Text(
                    duty.name.isNotEmpty ? duty.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(duty.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      Row(
                        children: [
                          Text(duty.staffType, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          if (duty.designation != null && duty.designation!.isNotEmpty) ...[
                            Text(" • ${duty.designation}", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: duty.totalDuties > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: duty.totalDuties > 0 ? const Color(0xFFA7F3D0) : const Color(0xFFFFEDD5),
                    ),
                  ),
                  child: Text(
                    "${duty.totalDuties} Duties",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: duty.totalDuties > 0 ? const Color(0xFF047857) : const Color(0xFFC2410C),
                    ),
                  ),
                ),
              ],
            ),
            if (duty.datesAssigned.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text("ASSIGNED DATES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: duty.datesAssigned.map((date) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF132A60).withValues(alpha: 0.1)),
                  ),
                  child: Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF132A60))),
                )).toList(),
              ),
            ],
            if (duty.phone != null && duty.phone!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildContactActions(duty.phone!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFreeStaff() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF132A60).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_off_rounded, size: 44, color: Color(0xFF132A60)),
            ),
            const SizedBox(height: 14),
            const Text("All staff members are assigned.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF132A60))),
            const SizedBox(height: 4),
            const Text("No free staff available for this date.", style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

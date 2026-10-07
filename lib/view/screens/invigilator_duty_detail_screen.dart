import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_detail_model.dart';
import 'package:smart_aig_admins_app/models/free_staff_model.dart';
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
              "Select Exam Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF132A60)),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: detail!.availableExamDates.length,
                itemBuilder: (context, index) {
                  final dateObj = detail!.availableExamDates[index];
                  bool isSelected = dateObj.date == selectedDate;
                  return ListTile(
                    onTap: () {
                      Get.back();
                      if (!isSelected) {
                        _fetchDetails(date: dateObj.date);
                      }
                    },
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                    ),
                    title: Text(
                      dateObj.formatted,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF132A60) : const Color(0xFF475569),
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            children: [
                              if (activeTabIndex == 0) ...[
                                _buildSummaryCard(),
                                const SizedBox(height: 16),
                                const Text(
                                  "ROOM ASSIGNMENTS",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF132A60), letterSpacing: 1),
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
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF132A60), letterSpacing: 1),
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
                                  const Text(
                                    "DUTY OVERVIEW BY STAFF",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF132A60), letterSpacing: 1),
                                  ),
                                  const SizedBox(height: 10),
                                  ...staffDutiesData!.staffDuties.map((duty) => _buildStaffDutyCard(duty)),
                                ]
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDateInfoBanner() {
    if (activeTabIndex == 2) return const SizedBox(height: 8);

    return GestureDetector(
      onTap: _showDateSelectionDialog,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFF132A60).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${detail!.dayName}, ${detail!.formattedDate}",
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF132A60), fontSize: 16),
                  ),
                  const Text(
                    "Click to change exam date",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem("Room Wise", 0)),
          Expanded(child: _buildTabItem("Free Staff", 1)),
          Expanded(child: _buildTabItem("Duty View", 2)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF132A60) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : const Color(0xFF132A60),
          ),
        ),
      ),
    );
  }

  // Removed _buildDateSelector as requested and replaced with a banner


  Widget _buildSummaryCard() {
    final s = detail!.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132A60).withOpacity(0.05),
            blurRadius: 10,
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
                  color: const Color(0xFF132A60).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF132A60), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail!.formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF132A60), fontSize: 14),
                  ),
                  Text(
                    detail!.dayName,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              if (detail!.examTiming != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF6366F1), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        detail!.examTiming!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem("Total Rooms", s.totalRooms.toString(), Icons.door_front_door_rounded, const Color(0xFF0F172A)),
              _buildSummaryItem("On Duty", s.totalTeachersOnDuty.toString(), Icons.assignment_turned_in_rounded, Colors.green.shade700),
              _buildSummaryItem("Available", s.totalFreeTeachers.toString(), Icons.person_search_rounded, const Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(DutyRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF132A60).withOpacity(0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.roomName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                const Spacer(),
                _buildCountBadge("${room.studentCount} Students", Colors.green),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRowWithIcon(Icons.class_rounded, "Classes", room.classes.join(", ")),
                const SizedBox(height: 10),
                _buildInfoRowWithIcon(Icons.menu_book_rounded, "Subjects", room.subjects.join(", ")),
                const SizedBox(height: 10),
                _buildInfoRowWithIcon(Icons.airline_seat_recline_normal_rounded, "Capacity", "${room.capacity} Seats"),
              ],
            ),
          ),

          // Teachers List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, size: 16, color: Color(0xFF6366F1)),
                    const SizedBox(width: 8),
                    Text(
                      "TEACHERS ON DUTY (${room.assignedTeachers.length})",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF6366F1), letterSpacing: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (room.assignedTeachers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text("⚠️ No teachers assigned yet", style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherListItem(AssignedTeacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF132A60).withOpacity(0.08),
            child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF132A60)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                ),
                Text(
                  teacher.staffType.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          if (teacher.phone != null && teacher.phone!.isNotEmpty)
            _buildActionIcon(Icons.phone_enabled_rounded, Colors.green, teacher.phone!),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // --- Free Staff Section UI ---

  Widget _buildFreeStaffCounts() {
    final c = freeStaffData!.counts;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF132A60).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Staff Availability", style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF132A60), fontSize: 14)),
              const Spacer(),
              _buildCountBadge("Available Today", const Color(0xFF6366F1)),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Total Teacher", c.totalStaff.toString(), Icons.groups_rounded, const Color(0xFF475569)),
              _buildSummaryItem("Busy Teacher", c.assignedStaff.toString(), Icons.work_rounded, Colors.orange.shade700),
              _buildSummaryItem("Free Teacher", c.freeStaff.toString(), Icons.how_to_reg_rounded, Colors.green.shade700),
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
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF90A4AE).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF132A60).withOpacity(0.1),
              child: Text(
                staff.name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF132A60), fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          staff.staffType.toUpperCase(),
                          style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (staff.designation != null) ...[
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
                    const SizedBox(height: 12),
                    _buildActionIcon(Icons.phone_enabled_rounded, Colors.green, staff.phone!),
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
        color: const Color(0xFF6366F1).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
      ),
    );
  }

  Widget _buildStaffDutyCard(StaffDutyMember duty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFF90A4AE).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF132A60).withOpacity(0.1),
                  child: Text(
                    duty.name[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF132A60)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(duty.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                      Text(duty.staffType, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: duty.totalDuties > 0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${duty.totalDuties} Duties",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: duty.totalDuties > 0 ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (duty.datesAssigned.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("ASSIGNED DATES", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: duty.datesAssigned.map((date) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132A60).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF132A60).withOpacity(0.1)),
                  ),
                  child: Text(date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF132A60))),
                )).toList(),
              ),
            ],
            if (duty.phone != null && duty.phone!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildActionIcon(Icons.phone_enabled_rounded, Colors.green, duty.phone!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFreeStaff() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Icon(Icons.person_off_rounded, size: 60, color: const Color(0xFF132A60).withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text("All staff members are assigned.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF132A60))),
            const SizedBox(height: 8),
            const Text("No free staff available for this date.", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

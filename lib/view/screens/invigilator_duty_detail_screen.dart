import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/invigilator_duty_detail_model.dart';
import 'package:smart_aig_admins_app/services/invigilator_duty_service.dart';

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
  InvigilatorDutyDetail? detail;
  String? selectedDate;

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
    } else {
      setState(() => isLoading = false);
      Get.snackbar("Error", "Failed to fetch details", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.8, -1.0),
          end: Alignment(0.8, 1.0),
          colors: [Color(0xFFCBE2FE), Color(0xFFE2DCFE), Color(0xFFFFE2EA)],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF132A60), size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            widget.planName.toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF132A60)),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF132A60)))
            : detail == null
                ? const Center(child: Text("No data found"))
                : Column(
                    children: [
                      _buildDateSelector(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => _fetchDetails(date: selectedDate),
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            children: [
                              _buildSummaryCard(),
                              const SizedBox(height: 16),
                              const Text(
                                "ROOM ASSIGNMENTS",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF132A60), letterSpacing: 1),
                              ),
                              const SizedBox(height: 10),
                              ...detail!.rooms.map((room) => _buildRoomCard(room)),
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

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: detail!.availableExamDates.length,
        itemBuilder: (context, index) {
          final dateObj = detail!.availableExamDates[index];
          bool isSelected = dateObj.date == selectedDate;
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                _fetchDetails(date: dateObj.date);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF132A60) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                dateObj.formatted,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF132A60),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    final s = detail!.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF132A60), size: 20),
              const SizedBox(width: 8),
              Text(
                detail!.formattedDate,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
              ),
              if (detail!.examTiming != null) ...[
                const Spacer(),
                const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 16),
                const SizedBox(width: 4),
                Text(
                  detail!.examTiming!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ]
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Rooms", s.totalRooms.toString(), Icons.meeting_room_rounded),
              _buildSummaryItem("On Duty", s.totalTeachersOnDuty.toString(), Icons.how_to_reg_rounded),
              _buildSummaryItem("Free", s.totalFreeTeachers.toString(), Icons.person_search_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRoomCard(DutyRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF132A60), borderRadius: BorderRadius.circular(6)),
              child: Text(room.roomName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text("${room.studentCount} Students", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF132A60))),
          ],
        ),
        subtitle: Text(
          room.classes.join(", "),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildRoomDetailRow("Subjects", room.subjects.join(", ")),
                const SizedBox(height: 8),
                _buildRoomDetailRow("Capacity", room.capacity.toString()),
                const SizedBox(height: 12),
                const Text("ASSIGNED TEACHERS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                const SizedBox(height: 8),
                if (room.assignedTeachers.isEmpty)
                  const Text("No teachers assigned", style: TextStyle(fontSize: 13, color: Colors.red, fontStyle: FontStyle.italic))
                else
                  ...room.assignedTeachers.map((teacher) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 15, backgroundColor: Color(0xFFEDE9FE), child: Icon(Icons.person, size: 16, color: Color(0xFF6366F1))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  if (teacher.staffType.isNotEmpty) Text(teacher.staffType, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            if (teacher.phone != null) Icon(Icons.phone_enabled_rounded, size: 18, color: Colors.green.shade600),
                          ],
                        ),
                      )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRoomDetailRow(String label, String value) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
      ],
    );
  }
}

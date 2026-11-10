import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/models/event_search_student_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_search_students_controller.dart';

class EventSearchStudentsScreen extends StatefulWidget {
  final ActiveEventModel? event;

  const EventSearchStudentsScreen({super.key, this.event});

  @override
  State<EventSearchStudentsScreen> createState() => _EventSearchStudentsScreenState();
}

class _EventSearchStudentsScreenState extends State<EventSearchStudentsScreen> {
  late final EventSearchStudentsController controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EventSearchStudentsController>()
        ? Get.find<EventSearchStudentsController>()
        : Get.put(EventSearchStudentsController());

    if (widget.event != null) {
      controller.initForEvent(widget.event!.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

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
              "SEARCH STUDENTS",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Column(
            children: [
              // Header Section (Search Input)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      if (event != null) {
                        controller.onSearchChanged(val, event.id);
                      }
                    },
                    style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: "Search student by name, admission no...",
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                              onPressed: () {
                                _searchController.clear();
                                if (event != null) {
                                  controller.onSearchChanged('', event.id);
                                }
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),

              // Content Body (List / Loading / Error / Empty)
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.studentsList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF132A60),
                      ),
                    );
                  }

                  if (controller.hasError.value && controller.studentsList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (event != null) {
                          await controller.fetchStudents(eventId: event.id);
                        }
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    controller.errorMessage.value,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (event != null) {
                                        controller.fetchStudents(eventId: event.id);
                                      }
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text("Retry"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF132A60),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final bool isSearchEmpty = controller.searchQuery.value.trim().isEmpty;
                  final students = controller.studentsList;

                  if (students.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (event != null && !isSearchEmpty) {
                          await controller.fetchStudents(eventId: event.id);
                        }
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 40),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEEF2FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSearchEmpty ? Icons.person_search_rounded : Icons.search_off_rounded,
                                      size: 48,
                                      color: const Color(0xFF4338CA),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isSearchEmpty ? "Search Students" : "No Students Found",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isSearchEmpty
                                        ? "Type student name or admission number in the search bar above to search."
                                        : "No student matches '${controller.searchQuery.value}'",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (event != null) {
                        await controller.fetchStudents(eventId: event.id);
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildStudentCard(student);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(EventSearchStudentModel student) {
    final String classSec = [
      if (student.className != null && student.className!.isNotEmpty) student.className,
      if (student.sectionName != null && student.sectionName!.isNotEmpty) student.sectionName,
    ].join(' - ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: student.passExists ? const Color(0xFF818CF8) : Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Student Basic Info & Avatar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar / Student Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFEEF2FF),
                    child: student.studentPhotoUrl != null && student.studentPhotoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: student.studentPhotoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => _buildAvatarPlaceholder(student),
                          )
                        : _buildAvatarPlaceholder(student),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Class Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.studentName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (student.admissionNumber.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                "Adm: ${student.admissionNumber}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          if (classSec.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school_outlined, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  "Class: $classSec",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          if (student.rollNo != null &&
                              student.rollNo!.isNotEmpty &&
                              student.rollNo != 'N/A')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.format_list_numbered_rounded, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  "Roll: ${student.rollNo}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),

          // Parent Info Row
          if ((student.fatherName != null && student.fatherName!.isNotEmpty) ||
              (student.motherName != null && student.motherName!.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (student.fatherName != null && student.fatherName!.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Father: ${student.fatherName}",
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (student.motherName != null && student.motherName!.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Mother: ${student.motherName}",
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Pass Details Footer Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: student.passExists ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  student.passExists ? Icons.badge_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: student.passExists ? const Color(0xFF4338CA) : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    student.passExists
                        ? (student.passNumber ?? "Pass Generated")
                        : "No Pass Issued",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: student.passExists ? const Color(0xFF4338CA) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (student.passExists && student.approvalStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: student.approvalStatus?.toLowerCase() == 'approved'
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      student.approvalStatus!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: student.approvalStatus?.toLowerCase() == 'approved'
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (student.passExists && student.checkinStatus != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      student.checkinStatus!.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
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

  Widget _buildAvatarPlaceholder(EventSearchStudentModel student) {
    final String initial = student.studentName.isNotEmpty
        ? student.studentName[0].toUpperCase()
        : 'S';

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/models/event_pass_application_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view/screens/create_event_pass_screen.dart';
import 'package:smart_aig_admins_app/view/screens/event_search_students_screen.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_entry_controller.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_pass_applications_controller.dart';

class EventEntryScreen extends StatefulWidget {
  const EventEntryScreen({super.key});

  @override
  State<EventEntryScreen> createState() => _EventEntryScreenState();
}

class _EventEntryScreenState extends State<EventEntryScreen> with SingleTickerProviderStateMixin {
  late final EventEntryController entryController;
  late final EventPassApplicationsController passController;
  late final TabController _tabController;
  final TextEditingController _passSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    entryController = Get.isRegistered<EventEntryController>()
        ? Get.find<EventEntryController>()
        : Get.put(EventEntryController());

    passController = Get.isRegistered<EventPassApplicationsController>()
        ? Get.find<EventPassApplicationsController>()
        : Get.put(EventPassApplicationsController());

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        if (_tabController.index == 1) {
          passController.fetchPassApplications();
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passSearchController.dispose();
    super.dispose();
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
            title: const Text(
              "EVENT ENTRY",
              style: AppColors.appBarTitleStyle,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  splashFactory: NoSplash.splashFactory,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF132A60),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF132A60).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, size: 16),
                          SizedBox(width: 6),
                          Text("Entry View"),
                        ],
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined, size: 16),
                          SizedBox(width: 6),
                          Text("Pass View"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildEntryViewTab(entryController),
              _buildPassViewTab(passController),
            ],
          ),
          floatingActionButton: _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Get.to(() => const CreateEventPassScreen());
                  },
                  backgroundColor: const Color(0xFF132A60),
                  elevation: 4,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    "Create Pass",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ================= TAB 1: ENTRY VIEW =================

  Widget _buildEntryViewTab(EventEntryController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF132A60),
          ),
        );
      }

      if (controller.hasError.value) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchActiveEvents(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Failed to Load Events",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchActiveEvents(),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF132A60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final events = controller.activeEventsList;

      if (events.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.fetchActiveEvents(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 56,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No Active Events Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "There are currently no active events available.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchActiveEvents(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return _buildEventCard(event);
          },
        ),
      );
    });
  }

  // ================= TAB 2: PASS VIEW =================

  Widget _buildPassViewTab(EventPassApplicationsController controller) {
    return Column(
      children: [
        // Header Controls Section (Event Selector, Search & Status Chips)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              // Event Selector Dropdown
              Obx(() {
                final events = entryController.activeEventsList;
                if (events.isEmpty) return const SizedBox.shrink();

                final int selectedId = controller.currentEventId ?? events.first.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: events.any((e) => e.id == selectedId) ? selectedId : events.first.id,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      items: events.map((evt) {
                        return DropdownMenuItem<int>(
                          value: evt.id,
                          child: Text(
                            "Event: ${evt.title} (${evt.eventCode})",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.fetchPassApplications(eventId: val);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                );
              }),

              // Search Input Box
              Container(
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
                  controller: _passSearchController,
                  onChanged: (val) {
                    controller.onSearchChanged(val);
                  },
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Search pass no, student name, admission no...",
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                    suffixIcon: _passSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                            onPressed: () {
                              _passSearchController.clear();
                              controller.onSearchChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Status Filter Chips
              Obx(() {
                final selected = controller.selectedStatus.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All Passes", "all", selected == 'all', const Color(0xFF132A60)),
                      const SizedBox(width: 6),
                      _buildFilterChip("Approved", "approved", selected == 'approved', const Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      _buildFilterChip("Pending", "pending", selected == 'pending', const Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      _buildFilterChip("Rejected", "rejected", selected == 'rejected', const Color(0xFFEF4444)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Pass Applications List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.applicationsList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF132A60),
                ),
              );
            }

            if (controller.hasError.value && controller.applicationsList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchPassApplications(),
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
                              onPressed: () => controller.fetchPassApplications(),
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

            final applications = controller.filteredApplicationsList;

            if (applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchPassApplications(),
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
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              size: 56,
                              color: Color(0xFFCBD5E1),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No Pass Applications Found",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "There are no pass applications matching your filter criteria.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
              onRefresh: () => controller.fetchPassApplications(),
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 14, right: 14, top: 6, bottom: 80),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final pass = applications[index];
                  return _buildPassApplicationCard(pass);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showUpdateStatusDialog(BuildContext context, EventPassApplicationModel pass, String action) {
    final isApprove = action.toLowerCase() == 'approve';
    final remarksController = TextEditingController(
      text: isApprove ? "Approved by Gate In-Charge" : "",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                isApprove ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${isApprove ? 'Approve' : 'Reject'} Pass",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pass No: ${pass.passNumber}",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF132A60)),
              ),
              if (pass.student != null) ...[
                const SizedBox(height: 2),
                Text(
                  "Student: ${pass.student!.name}",
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: remarksController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Admin Remarks",
                  hintText: isApprove ? "e.g. Approved by Gate In-Charge" : "e.g. Rejected by Admin",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await passController.updatePassStatus(
                  passId: pass.id,
                  action: action,
                  remarks: remarksController.text.trim().isEmpty ? null : remarksController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                isApprove ? "APPROVE" : "REJECT",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String status, bool isSelected, Color activeColor) {
    return InkWell(
      onTap: () => passController.setStatusFilter(status),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildPassApplicationCard(EventPassApplicationModel pass) {
    final bool isApproved = pass.approvalStatus?.toLowerCase() == 'approved';
    final bool isPending = pass.approvalStatus?.toLowerCase() == 'pending';
    final Color statusColor = isApproved
        ? const Color(0xFF10B981)
        : isPending
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final Color statusBg = isApproved
        ? const Color(0xFFD1FAE5)
        : isPending
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);

    final student = pass.student;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
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
          // 1. Pass Number & Status Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusBg.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 18, color: Color(0xFF132A60)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pass.passNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132A60),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (pass.approvalStatus ?? 'Status').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (pass.checkinStatus != null && pass.checkinStatus!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pass.checkinStatus!.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Student Info Header
                if (student != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: const Color(0xFFEEF2FF),
                          child: student.photoUrl != null && student.photoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: student.photoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4338CA),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4338CA),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (student.admissionNumber.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: Text(
                                      "Adm: ${student.admissionNumber}",
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.school_outlined, size: 14, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(
                                  "Class: ${student.className ?? ''}${student.section != null ? ' - ${student.section}' : ''}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                if (student.rollNo != null && student.rollNo != 'N/A') ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    "Roll: ${student.rollNo}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
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
                  const SizedBox(height: 10),
                ],

                // 3. Attendees List
                if (pass.attendees.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people_alt_outlined, size: 15, color: Color(0xFF4338CA)),
                            const SizedBox(width: 6),
                            Text(
                              "ATTENDEES (${pass.totalAttendeesApproved}/${pass.totalAttendeesRequested})",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4338CA),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...pass.attendees.map((attendee) => _buildAttendeeItem(attendee)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 4. Action & Remarks Info Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pass.createdAt != null && pass.createdAt!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              "Created: ${pass.createdAt}",
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      if (pass.actionByName != null && pass.actionByName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 13, color: Color(0xFF0369A1)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Approved By: ${pass.actionByName}${pass.actionByRole != null ? ' (${pass.actionByRole})' : ''}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0369A1),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (pass.adminRemarks != null && pass.adminRemarks!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF059669)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Remarks: ${pass.adminRemarks}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF047857),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 5. Action Buttons Row (Approve / Reject)
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (isPending) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusDialog(context, pass, 'reject'),
                          icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                          label: const Text("Reject", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            elevation: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusDialog(context, pass, 'approve'),
                          icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                          label: const Text("Approve", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ] else if (isApproved) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusDialog(context, pass, 'reject'),
                          icon: const Icon(Icons.cancel_outlined, size: 15, color: Colors.white),
                          label: const Text("Reject Pass", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusDialog(context, pass, 'approve'),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 15, color: Colors.white),
                          label: const Text("Approve Pass", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 1,
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

  Widget _buildAttendeeItem(EventPassAttendeeModel attendee) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 32,
              height: 32,
              color: const Color(0xFFE2E8F0),
              child: attendee.photoUrl != null && attendee.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: attendee.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 18, color: Color(0xFF64748B)),
                    )
                  : const Icon(Icons.person, size: 18, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      attendee.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (attendee.personType != null && attendee.personType!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          attendee.personType!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (attendee.mobileNo != null && attendee.mobileNo!.isNotEmpty)
                  Text(
                    "Mobile: ${attendee.mobileNo}",
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: attendee.isCheckedIn ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              attendee.isCheckedIn ? "CHECKED IN" : "NOT ENTERED",
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: attendee.isCheckedIn ? const Color(0xFF059669) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EVENT CARD (ENTRY VIEW) =================

  Widget _buildEventCard(ActiveEventModel event) {
    final bool isLive = event.liveTelecast?.isLive ?? false;

    return GestureDetector(
      onTap: () {
        Get.to(() => EventSearchStudentsScreen(event: event));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: AppColors.cardBorderRadius,
          border: Border.all(
            color: Colors.white,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image (if available)
            if (event.bannerUrl != null && event.bannerUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: CachedNetworkImage(
                    imageUrl: event.bannerUrl!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded, size: 40, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Title & Event Code Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (event.subTitle != null && event.subTitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                event.subTitle!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sensors_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                "LIVE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          event.eventCode,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 12),

                  // Date, Time & Venue Info Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Venue
                      if (event.venue != null && event.venue!.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFFEF4444),
                          label: "Venue",
                          value: event.venue!,
                        ),

                      // Start Date
                      if (event.startDate != null && event.startDate!.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.calendar_today_rounded,
                          iconColor: const Color(0xFF0284C7),
                          label: "Date",
                          value: event.startDate!,
                        ),

                      // Time
                      if (event.startTime != null && event.startTime!.isNotEmpty)
                        _buildInfoItem(
                          icon: Icons.access_time_filled_rounded,
                          iconColor: const Color(0xFF10B981),
                          label: "Time",
                          value: event.endTime != null && event.endTime!.isNotEmpty
                              ? "${event.startTime} - ${event.endTime}"
                              : event.startTime!,
                        ),

                      // Max Guests
                      _buildInfoItem(
                        icon: Icons.people_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        label: "Max Guests",
                        value: "${event.maxGuestsPerStudent} per student",
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Rule Flags / Tags Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (event.requiresApproval)
                        _buildTagChip("Requires Approval", const Color(0xFFEA580C), const Color(0xFFFFEDD5)),
                      if (event.requirePhoto)
                        _buildTagChip("Photo Required", const Color(0xFF2563EB), const Color(0xFFDBEAFE)),
                      if (event.requireAadhaar)
                        _buildTagChip("Aadhaar Required", const Color(0xFF0D9488), const Color(0xFFCCFBF1)),
                      if (event.allowMultipleCheckins)
                        _buildTagChip("Multiple Checkins", const Color(0xFF059669), const Color(0xFFD1FAE5)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

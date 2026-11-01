import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/student_count_model.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/student_count_controller.dart';

class StudentCountScreen extends StatefulWidget {
  const StudentCountScreen({super.key});

  @override
  State<StudentCountScreen> createState() => _StudentCountScreenState();
}

class _StudentCountScreenState extends State<StudentCountScreen> {
  late final StudentCountController controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<StudentCountController>()
        ? Get.find<StudentCountController>()
        : Get.put(StudentCountController());
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              "STUDENT COUNT",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!controller.success.value || controller.countData.value == null) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchStudentCount(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF132A60).withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                size: 54,
                                color: Color(0xFF132A60),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Failed to Load Counts",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Could not fetch student counts at this moment.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchStudentCount(),
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
                  ],
                ),
              );
            }

            final data = controller.countData.value!;
            final filteredList = data.classWiseCounts.where((item) {
              if (_searchQuery.isEmpty) return true;
              final query = _searchQuery.toLowerCase();
              final className = item.className.toLowerCase();
              final sectionName = item.sectionName.toLowerCase();
              final streamName = item.streamName.toLowerCase();
              return className.contains(query) ||
                  sectionName.contains(query) ||
                  streamName.contains(query);
            }).toList();

            return RefreshIndicator(
              onRefresh: () => controller.fetchStudentCount(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Academic Year Header Pill
                    if (data.academicYear.isNotEmpty || data.date.isNotEmpty)
                      _buildAcademicHeaderPill(data.academicYear, data.date),

                    if (data.academicYear.isNotEmpty || data.date.isNotEmpty)
                      const SizedBox(height: 12),

                    // Overall Summary Card
                    _buildOverallSummaryCard(data.overallStats),

                    const SizedBox(height: 20),

                    // Section Title & Search Bar
                    Row(
                      children: [
                        const Icon(Icons.class_rounded, size: 20, color: Color(0xFF132A60)),
                        const SizedBox(width: 8),
                        const Text(
                          "Class Wise Breakdown",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A60).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${filteredList.length} Classes",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF132A60),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Search Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: "Search class, section or stream...",
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Class Wise List or Empty Search
                    if (filteredList.isEmpty)
                      _buildEmptySearchState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final classCount = filteredList[index];
                          return _buildClassWiseCard(classCount);
                        },
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAcademicHeaderPill(String academicYear, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132A60).withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (academicYear.isNotEmpty) ...[
            const Icon(Icons.school_rounded, size: 16, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Academic Year: $academicYear",
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (date.isNotEmpty) ...[
            if (academicYear.isNotEmpty) const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallSummaryCard(OverallStats stats) {
    final int overall = stats.overallTotal;
    final int boys = stats.boysTotal;
    final int girls = stats.girlsTotal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: Colors.white, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withAlpha(38),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Row(
            children: [
              Icon(Icons.insights_rounded, size: 18, color: Color(0xFF132A60)),
              SizedBox(width: 6),
              Text(
                "OVERALL STATISTICS",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Single Horizontal Row with 3 Cards: Total, Boys, Girls
          Row(
            children: [
              // 1. Total Students Card (Soft Green)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.groups_rounded, size: 20, color: Color(0xFF059669)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        overall.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        maxLines: 2,
                        "Total Students",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 2. Boys Card (Soft Blue)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.boy_rounded, size: 20, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        boys.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Boys",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3. Girls Card (Soft Pink)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFBCFE8), width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4899).withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.girl_rounded, size: 20, color: Color(0xFFDB2777)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        girls.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Girls",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9D174D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassWiseCard(ClassWiseCount item) {
    final int classTotal = item.total;
    final int boys = item.boys;
    final int girls = item.girls;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: const Color(0xFF132A60).withAlpha(30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Class Name, Section & Stream Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A60).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 16,
                  color: Color(0xFF132A60),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.className,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.sectionName.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Text(
                    "Sec ${item.sectionName}",
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
              ],
              if (item.streamName.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    item.streamName,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // 3 Cards in 1 Row: Total, Boys, Girls
          Row(
            children: [
              // 1. Total Card (Soft Green)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.groups_rounded, size: 18, color: Color(0xFF059669)),
                      const SizedBox(height: 3),
                      Text(
                        classTotal.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // 2. Boys Card (Soft Blue)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.boy_rounded, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(height: 3),
                      Text(
                        boys.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "Boys",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // 3. Girls Card (Soft Pink)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFBCFE8), width: 1),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.girl_rounded, size: 18, color: Color(0xFFDB2777)),
                      const SizedBox(height: 3),
                      Text(
                        girls.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        "Girls",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9D174D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              "No classes found matching '$_searchQuery'",
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

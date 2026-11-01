import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/marks_entry_controller.dart';
import 'package:smart_aig_admins_app/models/marks_entry_model.dart';
import 'package:smart_aig_admins_app/models/marks_entry_classes_model.dart';
import 'package:smart_aig_admins_app/view/screens/marks_entry_details_screen.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class MarksEntryScreen extends StatelessWidget {
  const MarksEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MarksEntryController controller = Get.put(MarksEntryController());

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
              "MARKS ENTRY",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!controller.success.value || controller.examList.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => controller.fetchExams(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0038A8).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_note_rounded,
                              size: 60,
                              color: Color(0xFF0038A8),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "No Exams Found",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "There are no exams listed for marks entry yet.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchExams(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: controller.examList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exam = controller.examList[index];
                  return _buildExamCard(context, exam, controller);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExamCard(
      BuildContext context, ExamData exam, MarksEntryController controller) {
    return Obx(() {
      final isLoadingClasses = controller.loadingClassesMap[exam.id] ?? false;
      final classes = controller.examClassesMap[exam.id] ?? [];

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: AppColors.cardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0038A8).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_document,
                      color: Color(0xFF0038A8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Session: ${exam.session}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            if (isLoadingClasses)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0038A8)),
                    ),
                  ),
                ),
              )
            else if (classes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "No classes found for this exam",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        "SELECT CLASS:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...classes.map((classData) => _buildClassTile(
                          context,
                          exam: exam,
                          classData: classData,
                        )),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildClassTile(
    BuildContext context, {
    required ExamData exam,
    required ClassData classData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0038A8).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarksEntryDetailsScreen(
                  examId: exam.id,
                  classId: classData.id,
                  className: classData.name,
                  examTitle: exam.title,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF0038A8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    classData.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

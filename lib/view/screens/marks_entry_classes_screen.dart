import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/view_models/getX/marks_entry_classes_controller.dart';
import 'package:smart_aig_admins_app/models/marks_entry_classes_model.dart';
import 'package:smart_aig_admins_app/view/screens/marks_entry_details_screen.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';

class MarksEntryClassesScreen extends StatelessWidget {
  final int examId;
  final String examTitle;

  const MarksEntryClassesScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    final MarksEntryClassesController controller = Get.put(
      MarksEntryClassesController(examId: examId),
      tag: examId.toString(),
    );

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
          title: Column(
            children: [
              const Text(
                "SELECT CLASS",
                style: AppColors.appBarTitleStyle,
              ),
              Text(
                examTitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.success.value || controller.classList.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => controller.fetchClasses(),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No classes found for this exam",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchClasses(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.classList.length,
              itemBuilder: (context, index) {
                final classData = controller.classList[index];
                return _buildClassCard(context, classData);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassData classData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: AppColors.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  examId: examId,
                  classId: classData.id,
                  className: classData.name,
                  examTitle: examTitle,
                ),
              ),
            );
          },
          borderRadius: AppColors.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0038A8).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF0038A8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    classData.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

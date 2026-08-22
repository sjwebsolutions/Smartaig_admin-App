import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/homework_status_model.dart';
import 'package:smart_aig_admins_app/services/homework_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeworkController extends GetxController {
  final HomeworkService _homeworkService = HomeworkService();

  var isLoading = true.obs;
  var homeworkData = Rxn<HomeworkData>();
  var success = false.obs;

  // Badge logic
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeworkStatus();
  }

  Future<void> markAsRead() async {
    unreadCount.value = 0;
    if (homeworkData.value != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        String currentKey = _generateDataKey(homeworkData.value!);
        await prefs.setString('last_seen_homework_data', currentKey);
      } catch (e) {
        print("Error saving homework read status: $e");
      }
    }
  }

  String _generateDataKey(HomeworkData data) {
    return data.statusData.map((item) =>
      "${item.className}_${item.teacher}_${item.subject}_${item.status}_${item.uploadedAt}_${item.isDiary}"
    ).join("|");
  }

  Future<void> fetchHomeworkStatus({
    String? date,
    int? classId,
    int? sectionId,
    int? streamId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _homeworkService.getHomeworkUploadStatus(
        date: date,
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
      );
      success.value = response.success;
      if (response.success && response.data != null) {
        final prefs = await SharedPreferences.getInstance();
        String currentKey = _generateDataKey(response.data!);
        String lastSeenKey = prefs.getString('last_seen_homework_data') ?? '';

        if (currentKey.isNotEmpty && currentKey != lastSeenKey) {
          unreadCount.value = 1;
          
          if (lastSeenKey.isNotEmpty) {
            NotificationService.to.showLocalNotification(
              "Homework Update",
              "Latest homework status is now available.",
            );
          }
        }
        homeworkData.value = response.data;
        print("Homework Status: ${response.data!.statusData.length} classes found");
      }
    } catch (e) {
      print("HomeworkController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

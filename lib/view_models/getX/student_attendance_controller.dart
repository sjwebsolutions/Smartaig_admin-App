// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_aig_admins_app/models/student_attendance_report_model.dart';
// import 'package:smart_aig_admins_app/services/student_attendance_service.dart';
// import 'package:smart_aig_admins_app/services/notification_service.dart';
//
// class StudentAttendanceController extends GetxController {
//   final StudentAttendanceService _attendanceService = StudentAttendanceService();
//
//   var isLoading = true.obs;
//   var attendanceData = Rxn<AttendanceData>();
//   var success = false.obs;
//
//   // Badge logic
//   var unreadCount = 0.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAttendanceSummary();
//   }
//
//   Future<void> markAsRead() async {
//     unreadCount.value = 0;
//     if (attendanceData.value != null) {
//       final prefs = await SharedPreferences.getInstance();
//       String today = DateTime.now().toString().split(' ')[0];
//       // Save that we have seen this count for today
//       await prefs.setInt('last_seen_student_present_$today', attendanceData.value!.stats.present);
//     }
//   }
//
//   Future<void> fetchAttendanceSummary() async {
//     try {
//       isLoading.value = true;
//       final response = await _attendanceService.getTodaySummary();
//       success.value = response.success;
//       if (response.success && response.data != null) {
//         final prefs = await SharedPreferences.getInstance();
//         String today = DateTime.now().toString().split(' ')[0];
//         int lastSeenCount = prefs.getInt('last_seen_student_present_$today') ?? -1;
//
//         // Sirf tabhi notification dikhao jab count pehle se zyada ho (yani naya attendance laga ho)
//         if (response.data!.stats.present > 0 && response.data!.stats.present > lastSeenCount) {
//           unreadCount.value = 1;
//
//           // Notification sirf tab bajao jab app pehle se chal raha ho (startup par nahi agar same data hai)
//           if (lastSeenCount != -1) {
//             NotificationService.to.showLocalNotification(
//               "Student Attendance Updated",
//               "New student attendance has been marked.",
//             );
//           }
//         }
//
//         attendanceData.value = response.data;
//       }
//     } catch (e) {
//       print("StudentAttendanceController Error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }


import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_aig_admins_app/models/student_attendance_report_model.dart';
import 'package:smart_aig_admins_app/services/student_attendance_service.dart';
import 'package:smart_aig_admins_app/services/notification_service.dart';

class StudentAttendanceController extends GetxController {
  final StudentAttendanceService _attendanceService =
  StudentAttendanceService();

  final RxBool isLoading = true.obs;
  final Rxn<AttendanceData> attendanceData = Rxn<AttendanceData>();
  final RxBool success = false.obs;

  // Badge
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceSummary();
  }

  Future<void> markAsRead() async {
    unreadCount.value = 0;

    final data = attendanceData.value;

    if (data == null) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayKey();

      await prefs.setInt(
        'last_seen_student_present_$today',
        data.stats.presentToday,
      );
    } catch (e) {
      print('markAsRead Error: $e');
    }
  }

  Future<void> fetchAttendanceSummary() async {
    try {
      isLoading.value = true;

      final response = await _attendanceService.getTodaySummary();

      success.value = response.success;

      if (!response.success || response.data == null) {
        attendanceData.value = null;
        unreadCount.value = 0;
        return;
      }

      final data = response.data!;

      attendanceData.value = data;

      final prefs = await SharedPreferences.getInstance();

      final today = _getTodayKey();

      final lastSeenCount =
          prefs.getInt('last_seen_student_present_$today') ?? -1;

      final currentPresentCount = data.stats.presentToday;

      // New attendance found
      if (currentPresentCount > 0 &&
          currentPresentCount > lastSeenCount) {
        unreadCount.value = 1;

        // First app load par notification nahi bajegi
        if (lastSeenCount != -1) {
          try {
            if (Get.isRegistered<NotificationService>()) {
              await NotificationService.to.showLocalNotification(
                'Student Attendance Updated',
                'New student attendance has been marked.',
              );
            }
          } catch (e) {
            print('Notification Error: $e');
          }
        }
      }
    } catch (e) {
      print('StudentAttendanceController Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/teacher_attendance_report_model.dart';
import 'package:smart_aig_admins_app/services/teacher_attendance_service.dart';

class TeacherAttendanceController extends GetxController {
  final TeacherAttendanceService _attendanceService = TeacherAttendanceService();

  var isLoading = true.obs;
  var attendanceData = Rxn<TeacherAttendanceData>();
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceSummary();
  }

  Future<void> fetchAttendanceSummary() async {
    try {
      isLoading.value = true;
      final response = await _attendanceService.getTodaySummary();
      success.value = response.success;
      if (response.success && response.data != null) {
        attendanceData.value = response.data;
        print("Teacher Attendance Data: ${response.data!.stats.totalTeachers} total teachers");
      }
    } catch (e) {
      print("TeacherAttendanceController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

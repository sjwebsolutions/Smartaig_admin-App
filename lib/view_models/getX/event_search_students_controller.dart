import 'dart:async';
import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/event_search_student_model.dart';
import 'package:smart_aig_admins_app/services/event_service.dart';

class EventSearchStudentsController extends GetxController {
  final EventService _eventService = EventService();

  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var studentsList = <EventSearchStudentModel>[].obs;
  var totalCount = 0.obs;
  var searchQuery = ''.obs;

  int? currentEventId;
  Timer? _debounceTimer;

  void initForEvent(int eventId) {
    currentEventId = eventId;
    searchQuery.value = '';
    studentsList.clear();
    totalCount.value = 0;
    isLoading.value = false;
    hasError.value = false;
  }

  void onSearchChanged(String query, int eventId) {
    searchQuery.value = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      studentsList.clear();
      totalCount.value = 0;
      isLoading.value = false;
      hasError.value = false;
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchStudents(eventId: eventId, query: query.trim());
    });
  }

  Future<void> fetchStudents({required int eventId, String? query}) async {
    final String q = query ?? searchQuery.value;
    if (q.trim().isEmpty) {
      studentsList.clear();
      totalCount.value = 0;
      isLoading.value = false;
      hasError.value = false;
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _eventService.searchStudents(
        eventId: eventId,
        searchQuery: q.trim(),
      );

      if (response.success) {
        studentsList.assignAll(response.data);
        totalCount.value = response.totalCount;
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? "Failed to load students.";
        studentsList.clear();
        totalCount.value = 0;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = "An error occurred: $e";
      studentsList.clear();
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}

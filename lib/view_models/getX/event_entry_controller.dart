import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/services/event_service.dart';

class EventEntryController extends GetxController {
  final EventService _eventService = EventService();

  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var activeEventsList = <ActiveEventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveEvents();
  }

  Future<void> fetchActiveEvents() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _eventService.getActiveEvents();

      if (response.success) {
        activeEventsList.assignAll(response.data);
      } else {
        hasError.value = true;
        errorMessage.value = response.message ?? "Failed to fetch active events.";
        activeEventsList.clear();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = "An error occurred while loading events: $e";
      activeEventsList.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

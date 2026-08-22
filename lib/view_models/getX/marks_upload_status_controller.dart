import 'package:get/get.dart';
import 'package:smart_aig_admins_app/models/marks_upload_status_model.dart';
import 'package:smart_aig_admins_app/services/marks_entry_service.dart';

class MarksUploadStatusController extends GetxController {
  final int marksEntryId;
  final int classId;
  final int? sectionId;
  final int? streamId;
  
  final MarksEntryService _marksEntryService = MarksEntryService();

  MarksUploadStatusController({
    required this.marksEntryId,
    required this.classId,
    this.sectionId,
    this.streamId,
  });

  var isLoading = true.obs;
  var statusList = <MarksUploadStatusItem>[].obs;
  var success = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUploadStatus();
  }

  Future<void> fetchUploadStatus() async {
    try {
      isLoading.value = true;
      final response = await _marksEntryService.getUploadStatus(
        marksEntryId: marksEntryId,
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
      );
      success.value = response.success;
      if (response.success) {
        statusList.assignAll(response.data);
      }
    } catch (e) {
      print("MarksUploadStatusController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_aig_admins_app/models/active_event_model.dart';
import 'package:smart_aig_admins_app/models/event_search_student_model.dart';
import 'package:smart_aig_admins_app/models/issue_walk_in_pass_model.dart';
import 'package:smart_aig_admins_app/services/event_service.dart';
import 'package:smart_aig_admins_app/utils/app_colors.dart';
import 'package:smart_aig_admins_app/view_models/getX/event_pass_applications_controller.dart';

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 12) {
      digitsOnly = digitsOnly.substring(0, 12);
    }
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CreateEventPassScreen extends StatefulWidget {
  const CreateEventPassScreen({super.key});

  @override
  State<CreateEventPassScreen> createState() => _CreateEventPassScreenState();
}

class _AttendeeFormHolder {
  String personType;
  TextEditingController nameController;
  TextEditingController mobileController;
  TextEditingController whatsappController;
  TextEditingController aadhaarController;
  File? photoFile;
  String? existingPhotoUrl;
  String? existingPhotoPath;
  bool isAutoFilled;

  _AttendeeFormHolder({
    this.personType = 'father',
    String name = '',
    String mobile = '',
    String whatsapp = '',
    String aadhaar = '',
    this.photoFile,
    this.existingPhotoUrl,
    this.existingPhotoPath,
    this.isAutoFilled = false,
  })  : nameController = TextEditingController(text: name),
        mobileController = TextEditingController(text: mobile),
        whatsappController = TextEditingController(text: whatsapp),
        aadhaarController = TextEditingController(text: aadhaar);

  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    aadhaarController.dispose();
  }
}

class _CreateEventPassScreenState extends State<CreateEventPassScreen> {
  final EventService _eventService = EventService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingEvents = true;
  List<ActiveEventModel> _activeEvents = [];
  ActiveEventModel? _selectedEvent;

  // Student Search
  final TextEditingController _studentSearchController = TextEditingController();
  bool _isSearchingStudents = false;
  List<EventSearchStudentModel> _searchedStudents = [];
  EventSearchStudentModel? _selectedStudent;

  // Settings
  final TextEditingController _gateNameController = TextEditingController(text: 'main gate');
  final TextEditingController _remarksController = TextEditingController(text: 'Walk-in entry issued at gate');
  bool _autoApprove = true;
  bool _autoCheckin = true;

  // Attendees List
  final List<_AttendeeFormHolder> _attendees = [_AttendeeFormHolder()];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _studentSearchController.dispose();
    _gateNameController.dispose();
    _remarksController.dispose();
    for (var att in _attendees) {
      att.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });
    final res = await _eventService.getActiveEvents();
    if (mounted) {
      setState(() {
        _isLoadingEvents = false;
        if (res.success) {
          _activeEvents = res.data;
          if (_activeEvents.isNotEmpty) {
            _selectedEvent = _activeEvents.first;
          }
        }
      });
    }
  }

  Future<void> _searchStudents(String query) async {
    if (_selectedEvent == null || query.trim().isEmpty) {
      setState(() {
        _searchedStudents = [];
        _isSearchingStudents = false;
      });
      return;
    }

    setState(() {
      _isSearchingStudents = true;
    });

    final res = await _eventService.searchStudents(
      eventId: _selectedEvent!.id,
      searchQuery: query.trim(),
    );

    if (mounted) {
      setState(() {
        _isSearchingStudents = false;
        if (res.success) {
          _searchedStudents = res.data;
        } else {
          _searchedStudents = [];
        }
      });
    }
  }

  void _selectStudent(EventSearchStudentModel student) {
    setState(() {
      _selectedStudent = student;
      _searchedStudents = [];
      _studentSearchController.text = "${student.studentName} (${student.admissionNumber})";

      if (_attendees.isNotEmpty) {
        if (student.fatherName != null && student.fatherName!.isNotEmpty) {
          _attendees[0].personType = 'father';
        } else if (student.motherName != null && student.motherName!.isNotEmpty) {
          _attendees[0].personType = 'mother';
        } else {
          _attendees[0].personType = 'student';
        }
        _updateAttendeeInfoFromSelectedStudent(_attendees[0]);
      }
    });
  }

  void _updateAttendeeInfoFromSelectedStudent(_AttendeeFormHolder att) {
    if (_selectedStudent == null) {
      att.isAutoFilled = false;
      return;
    }
    final student = _selectedStudent!;

    if (att.personType == 'father') {
      final bool hasFather = student.fatherName != null && student.fatherName!.isNotEmpty;
      att.nameController.text = student.fatherName ?? '';
      att.mobileController.text = student.fatherMobile ?? '';
      att.whatsappController.text = student.whatsappNo ?? student.fatherMobile ?? '';
      att.aadhaarController.text = _formatAadhaarString(student.fatherAadhaar ?? '');
      att.existingPhotoUrl = student.fatherPhotoUrl;
      att.existingPhotoPath = student.fatherPhotoPath;
      att.isAutoFilled = hasFather;
    } else if (att.personType == 'mother') {
      final bool hasMother = student.motherName != null && student.motherName!.isNotEmpty;
      att.nameController.text = student.motherName ?? '';
      att.mobileController.text = (student.motherMobile != null && student.motherMobile!.isNotEmpty)
          ? student.motherMobile!
          : (student.fatherMobile ?? '');
      att.whatsappController.text = (student.whatsappNo != null && student.whatsappNo!.isNotEmpty)
          ? student.whatsappNo!
          : (student.motherMobile ?? student.fatherMobile ?? '');
      att.aadhaarController.text = _formatAadhaarString(student.motherAadhaar ?? '');
      att.existingPhotoUrl = student.motherPhotoUrl;
      att.existingPhotoPath = student.motherPhotoPath;
      att.isAutoFilled = hasMother;
    } else if (att.personType == 'student') {
      att.nameController.text = student.studentName;
      att.mobileController.text = student.fatherMobile ?? '';
      att.whatsappController.text = student.whatsappNo ?? student.fatherMobile ?? '';
      att.aadhaarController.text = _formatAadhaarString(student.studentAadhaar ?? '');
      att.existingPhotoUrl = student.studentPhotoUrl;
      att.existingPhotoPath = student.studentPhotoPath;
      att.isAutoFilled = true;
    } else {
      att.nameController.clear();
      att.mobileController.clear();
      att.whatsappController.clear();
      att.aadhaarController.clear();
      att.photoFile = null;
      att.existingPhotoUrl = null;
      att.existingPhotoPath = null;
      att.isAutoFilled = false;
    }
  }

  String _formatAadhaarString(String raw) {
    String digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 12) digitsOnly = digitsOnly.substring(0, 12);
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    return buffer.toString();
  }

  void _showImageSourceDialog(_AttendeeFormHolder attendee) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_a_photo_outlined, size: 36, color: Color(0xFF1E2B58)),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Select Photo Source",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Choose Camera or Gallery to select attendee photo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Camera Choice Card
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickAndCropImage(attendee, ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.camera_alt_rounded, size: 30, color: Color(0xFF1E2B58)),
                              SizedBox(height: 8),
                              Text("Camera", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Gallery Choice Card
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _pickAndCropImage(attendee, ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.photo_library_rounded, size: 30, color: Color(0xFF059669)),
                              SizedBox(height: 8),
                              Text("Gallery", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndCropImage(_AttendeeFormHolder attendee, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image != null && mounted) {
        final File? croppedFile = await Get.to<File>(
          () => ImageCropPreviewScreen(
            imageFile: File(image.path),
            personType: attendee.personType.toUpperCase(),
          ),
        );
        if (croppedFile != null && mounted) {
          setState(() {
            attendee.photoFile = croppedFile;
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "Photo Error",
        "Could not capture or process image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addAttendee() {
    final int maxAttendees = _selectedEvent?.maxGuestsPerStudent ?? 2;
    if (_attendees.length >= maxAttendees) {
      Get.snackbar(
        "Limit Reached",
        "Maximum $maxAttendees attendee(s) allowed for this event.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    setState(() {
      _attendees.add(_AttendeeFormHolder());
    });
  }

  void _removeAttendee(int index) {
    if (_attendees.length > 1) {
      setState(() {
        _attendees[index].dispose();
        _attendees.removeAt(index);
      });
    }
  }

  Future<void> _submitWalkInPass() async {
    if (_selectedEvent == null) {
      Get.snackbar("Required Field", "Please select an event.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_selectedStudent == null) {
      Get.snackbar("Required Field", "Please search and select a student.", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validate attendees
    for (int i = 0; i < _attendees.length; i++) {
      if (_attendees[i].nameController.text.trim().isEmpty) {
        Get.snackbar("Required Field", "Please enter full name for Attendee #${i + 1}.", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    final List<WalkInAttendeeInput> attendeeInputs = _attendees.map((a) {
      final String rawAadhaar = a.aadhaarController.text.replaceAll(' ', '').trim();
      return WalkInAttendeeInput(
        personType: a.personType,
        name: a.nameController.text.trim(),
        mobileNo: a.mobileController.text.trim().isEmpty ? null : a.mobileController.text.trim(),
        whatsappNo: a.whatsappController.text.trim().isEmpty ? null : a.whatsappController.text.trim(),
        aadhaarNumber: rawAadhaar.isEmpty ? null : rawAadhaar,
        photoFile: a.photoFile,
        existingPhotoPath: a.existingPhotoPath,
      );
    }).toList();

    final response = await _eventService.issueWalkInPass(
      eventId: _selectedEvent!.id,
      studentId: _selectedStudent!.id,
      autoApprove: _autoApprove,
      autoCheckin: _autoCheckin,
      gateName: _gateNameController.text.trim().isEmpty ? null : _gateNameController.text.trim(),
      remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
      attendees: attendeeInputs,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (response.success && response.data != null) {
        if (Get.isRegistered<EventPassApplicationsController>()) {
          Get.find<EventPassApplicationsController>().fetchPassApplications();
        }

        _showSuccessDialog(response);
      } else {
        Get.snackbar(
          "Issue Failed",
          response.message ?? "Could not issue walk-in pass.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _showSuccessDialog(IssueWalkInPassResponseModel response) {
    final data = response.data!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Pass Issued Successfully!",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                response.message ?? "Walk-in pass issued.",
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pass No:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text(
                          data.passNumber,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Student:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        Text(
                          data.student?.name ?? '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    if (data.gateEntry != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Gate Entry:", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Text(
                            data.gateEntry!.isCheckedIn ? "Checked In (${data.gateEntry!.gateName})" : "Not Checked In",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: data.gateEntry!.isCheckedIn ? const Color(0xFF059669) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2B58),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int maxAttendees = _selectedEvent?.maxGuestsPerStudent ?? 2;

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
              "EVENT CREATE ENTRY",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION 1: SELECT EVENT
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("1. SELECT EVENT", Icons.calendar_today_outlined),
                      const SizedBox(height: 12),
                      if (_isLoadingEvents)
                        const Center(child: CircularProgressIndicator())
                      else if (_activeEvents.isEmpty)
                        const Text("No active events found.", style: TextStyle(color: Colors.red))
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ActiveEventModel>(
                              value: _selectedEvent,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(16),
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E2B58)),
                              items: _activeEvents.map((event) {
                                return DropdownMenuItem<ActiveEventModel>(
                                  value: event,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF1E2B58)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          event.title,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedEvent = val;
                                  _selectedStudent = null;
                                  _searchedStudents = [];
                                  _studentSearchController.clear();
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 2: SELECT STUDENT
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("2. SELECT STUDENT", Icons.person_add_alt_1_outlined),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _studentSearchController,
                        onChanged: (val) => _searchStudents(val),
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: "Type student name, student ID, admis...",
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF1E2B58)),
                          suffixIcon: _studentSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _studentSearchController.clear();
                                      _selectedStudent = null;
                                      _searchedStudents = [];
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2B58), width: 1.5)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      // Search Results Suggestions
                      if (_isSearchingStudents) ...[
                        const SizedBox(height: 8),
                        const Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                      ] else if (_searchedStudents.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _searchedStudents.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final student = _searchedStudents[index];
                              return ListTile(
                                dense: true,
                                title: Text(student.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text("Adm: ${student.admissionNumber} • Class: ${student.className ?? ''}-${student.sectionName ?? ''}"),
                                onTap: () => _selectStudent(student),
                              );
                            },
                          ),
                        ),
                      ],

                      // Selected Student Box Card
                      if (_selectedStudent != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedStudent!.studentName,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                                    ),
                                    Text(
                                      "Adm: ${_selectedStudent!.admissionNumber} • Class: ${_selectedStudent!.className ?? ''}-${_selectedStudent!.sectionName ?? ''}",
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF047857)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 3: PASS SETTINGS
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("3. PASS SETTINGS", Icons.tune_rounded),
                      const SizedBox(height: 12),
                      _buildSwitchRow("Auto Approve Pass", _autoApprove, (val) => setState(() => _autoApprove = val)),
                      const SizedBox(height: 10),
                      _buildSwitchRow("Auto Check-in Pass", _autoCheckin, (val) => setState(() => _autoCheckin = val)),
                      const SizedBox(height: 12),
                      _buildOutlinedTextField(
                        label: "Gate Name",
                        hint: "main gate",
                        controller: _gateNameController,
                        icon: Icons.door_sliding_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildOutlinedTextField(
                        label: "Remarks",
                        hint: "Walk-in entry issued at gate",
                        controller: _remarksController,
                        icon: Icons.edit_note_outlined,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 4: ATTENDEES (1 / MAX)
                _buildCardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("4. ATTENDEES (${_attendees.length} / $maxAttendees)", Icons.groups_outlined),
                      const SizedBox(height: 12),

                      ...List.generate(_attendees.length, (index) => _buildAttendeeCard(index)),

                      const SizedBox(height: 8),

                      // ADD ANOTHER ATTENDEE BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addAttendee,
                          icon: const Icon(Icons.person_add_outlined, size: 18, color: Color(0xFF1E2B58)),
                          label: Text(
                            "+ ADD ANOTHER ATTENDEE (MAX $maxAttendees)",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58), letterSpacing: 0.3),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFF1E2B58), width: 1.5),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CREATE ENTRY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitWalkInPass,
                    icon: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
                    label: Text(
                      _isSubmitting ? "CREATING ENTRY..." : "CREATE ENTRY",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2B58),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF90A4AE).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E2B58)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58), letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFF1E2B58),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    Widget? customIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Color? iconColor,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: readOnly ? const Color(0xFF64748B) : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
        prefixIcon: customIcon ?? (icon != null ? Icon(icon, size: 20, color: iconColor ?? const Color(0xFF1E2B58)) : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2B58), width: 1.5),
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
      ),
    );
  }

  Widget _buildAttendeeCard(int index) {
    final att = _attendees[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Attendee #${index + 1}",
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58)),
              ),
              if (_attendees.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => _removeAttendee(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Person Type Outlined Dropdown
          InputDecorator(
            decoration: InputDecoration(
              labelText: "Person Type *",
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              prefixIcon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.badge_outlined, size: 20, color: Color(0xFF1E2B58)),
                  SizedBox(width: 8),
                  Icon(Icons.face_outlined, size: 20, color: Color(0xFF1E2B58)),
                  SizedBox(width: 8),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              filled: true,
              fillColor: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: att.personType,
                isDense: true,
                borderRadius: BorderRadius.circular(16),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E2B58)),
                items: const [
                  DropdownMenuItem(value: 'father', child: Text('Father', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  DropdownMenuItem(value: 'mother', child: Text('Mother', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  DropdownMenuItem(value: 'student', child: Text('Student', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  DropdownMenuItem(value: 'guardian', child: Text('Guardian', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  DropdownMenuItem(value: 'guest', child: Text('Guest', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                  DropdownMenuItem(value: 'other', child: Text('Other', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      att.personType = val;
                      _updateAttendeeInfoFromSelectedStudent(att);
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 10),
          _buildOutlinedTextField(
            label: "Full Name *",
            hint: "Full Name *",
            controller: att.nameController,
            icon: Icons.person_outline_rounded,
            readOnly: att.isAutoFilled && att.nameController.text.isNotEmpty,
          ),
          const SizedBox(height: 10),
          _buildOutlinedTextField(
            label: "Mobile No (10 Digits) *",
            hint: "Mobile No (10 Digits) *",
            controller: att.mobileController,
            icon: Icons.smartphone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            readOnly: att.isAutoFilled && att.mobileController.text.isNotEmpty,
          ),
          const SizedBox(height: 10),
          _buildOutlinedTextField(
            label: "WhatsApp No (10 Digits)",
            hint: "WhatsApp No (10 Digits)",
            controller: att.whatsappController,
            customIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 20,
                color: Color(0xFF25D366),
              ),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            readOnly: att.isAutoFilled && att.whatsappController.text.isNotEmpty,
          ),
          const SizedBox(height: 10),
          _buildOutlinedTextField(
            label: "Aadhaar No (12 Digits)",
            hint: "Aadhaar No (12 Digits)",
            controller: att.aadhaarController,
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              AadhaarNumberFormatter(),
            ],
            readOnly: att.isAutoFilled && att.aadhaarController.text.isNotEmpty,
          ),

          const SizedBox(height: 12),
          // Photo Pick & Capture Buttons
          Row(
            children: [
              GestureDetector(
                onTap: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                    ? null
                    : () => _showImageSourceDialog(att),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: att.photoFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(att.photoFile!, fit: BoxFit.cover),
                        )
                      : (att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: att.existingPhotoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, color: Color(0xFF1E2B58), size: 24),
                                    SizedBox(height: 4),
                                    Text("Photo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58))),
                                  ],
                                ),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, color: Color(0xFF1E2B58), size: 24),
                                SizedBox(height: 4),
                                Text("Photo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E2B58))),
                              ],
                            ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                      ? null
                      : () => _showImageSourceDialog(att),
                  icon: Icon(
                    (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_outlined,
                    size: 20,
                    color: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E2B58),
                  ),
                  label: Text(
                    (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                        ? "Photo Saved from Database"
                        : "Capture Attendee Photo",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                          ? const Color(0xFF10B981)
                          : const Color(0xFF1E2B58),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                      color: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                    backgroundColor: (att.isAutoFilled && att.existingPhotoUrl != null && att.existingPhotoUrl!.isNotEmpty && att.photoFile == null)
                        ? const Color(0xFFECFDF5)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ImageCropPreviewScreen extends StatefulWidget {
  final File imageFile;
  final String personType;

  const ImageCropPreviewScreen({
    super.key,
    required this.imageFile,
    this.personType = 'ATTENDEE',
  });

  @override
  State<ImageCropPreviewScreen> createState() => _ImageCropPreviewScreenState();
}

class _ImageCropPreviewScreenState extends State<ImageCropPreviewScreen> {
  final TransformationController _transformationController = TransformationController();
  String _selectedRatio = "1:1";
  int _quarterTurns = 0;

  @override
  void dispose() {
    _transformationController.dispose();
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
            title: Text(
              "CROP ${widget.personType} PHOTO",
              style: AppColors.appBarTitleStyle,
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 4),
              const Text(
                "Drag corners to resize or move crop box",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Image & Crop Box Area Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double boxWidth = constraints.maxWidth;
                          final double boxHeight = constraints.maxHeight;

                          double cropW = 260;
                          double cropH = 260;
                          if (_selectedRatio == "3:4") {
                            cropW = 210;
                            cropH = 280;
                          } else if (_selectedRatio == "Free") {
                            cropW = boxWidth * 0.8;
                            cropH = boxHeight * 0.6;
                          }

                          final Rect cropRect = Rect.fromCenter(
                            center: Offset(boxWidth / 2, boxHeight / 2),
                            width: cropW,
                            height: cropH,
                          );

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: RotatedBox(
                                  quarterTurns: _quarterTurns,
                                  child: Image.file(
                                    widget.imageFile,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),

                              // Crop Overlay Painter (Grid & Corner Brackets)
                              CustomPaint(
                                size: Size(boxWidth, boxHeight),
                                painter: _CropBoxOverlayPainter(
                                  cropRect: cropRect,
                                  cornerColor: const Color(0xFF505AC9),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Aspect Ratio & Tool Bar (White Floating Card)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRatioOption("1:1", _selectedRatio == "1:1", () {
                        setState(() {
                          _selectedRatio = "1:1";
                        });
                      }),
                      _buildRatioOption("3:4", _selectedRatio == "3:4", () {
                        setState(() {
                          _selectedRatio = "3:4";
                        });
                      }),
                      _buildRatioOption("Free", _selectedRatio == "Free", () {
                        setState(() {
                          _selectedRatio = "Free";
                        });
                      }),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _quarterTurns = (_quarterTurns + 1) % 4;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF505AC9)),
                              SizedBox(height: 2),
                              Text("Rotate", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Buttons (Cancel & Save)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF505AC9), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF505AC9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, widget.imageFile);
                        },
                        icon: const Icon(Icons.crop_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF505AC9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatioOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF505AC9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _CropBoxOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final Color cornerColor;

  _CropBoxOverlayPainter({
    required this.cropRect,
    this.cornerColor = const Color(0xFF505AC9),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dimmed Overlay Outside Crop Rect
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    final Paint dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(backgroundPath, dimPaint);

    // 2. White Rect Border around Crop Area
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(cropRect, borderPaint);

    // 3. 3x3 Grid Lines inside Crop Area
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double stepX = cropRect.width / 3;
    final double stepY = cropRect.height / 3;

    canvas.drawLine(Offset(cropRect.left + stepX, cropRect.top), Offset(cropRect.left + stepX, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left + stepX * 2, cropRect.top), Offset(cropRect.left + stepX * 2, cropRect.bottom), gridPaint);

    canvas.drawLine(Offset(cropRect.left, cropRect.top + stepY), Offset(cropRect.right, cropRect.top + stepY), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + stepY * 2), Offset(cropRect.right, cropRect.top + stepY * 2), gridPaint);

    // 4. Purple Corner Brackets
    final Paint cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square;

    const double cornerLength = 22.0;

    // Top-Left
    canvas.drawLine(Offset(cropRect.left - 2, cropRect.top), Offset(cropRect.left + cornerLength, cropRect.top), cornerPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top - 2), Offset(cropRect.left, cropRect.top + cornerLength), cornerPaint);

    // Top-Right
    canvas.drawLine(Offset(cropRect.right + 2, cropRect.top), Offset(cropRect.right - cornerLength, cropRect.top), cornerPaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.top - 2), Offset(cropRect.right, cropRect.top + cornerLength), cornerPaint);

    // Bottom-Left
    canvas.drawLine(Offset(cropRect.left - 2, cropRect.bottom), Offset(cropRect.left + cornerLength, cropRect.bottom), cornerPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.bottom + 2), Offset(cropRect.left, cropRect.bottom - cornerLength), cornerPaint);

    // Bottom-Right
    canvas.drawLine(Offset(cropRect.right + 2, cropRect.bottom), Offset(cropRect.right - cornerLength, cropRect.bottom), cornerPaint);
    canvas.drawLine(Offset(cropRect.right, cropRect.bottom + 2), Offset(cropRect.right, cropRect.bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _CropBoxOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect || oldDelegate.cornerColor != cornerColor;
  }
}

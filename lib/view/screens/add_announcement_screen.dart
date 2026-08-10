import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../view_models/getX/announcement_controller.dart';
import '../../models/announcement_detail_model.dart';
import 'dart:io';

class AddAnnouncementScreen extends StatefulWidget {
  final AnnouncementDetail? announcement;
  const AddAnnouncementScreen({super.key, this.announcement});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final AnnouncementController controller = Get.find<AnnouncementController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  int? _selectedTypeId;
  late DateTime _fromDate;
  late DateTime _toDate;
  late String _targetType; 
  File? _imageFile;
  String? _existingImageUrl;

  // Targeting specific state
  int? _selectedClassId;
  int? _selectedStreamId;
  List<int> _selectedSectionIds = [];

  @override
  void initState() {
    super.initState();
    final a = widget.announcement;
    _titleController = TextEditingController(text: a?.title ?? "");
    _descController = TextEditingController(text: a?.description ?? "");
    _selectedTypeId = a?.typeId;
    _fromDate = a != null ? DateTime.parse(a.fromDate) : DateTime.now();
    _toDate = a != null ? DateTime.parse(a.toDate) : DateTime.now().add(const Duration(days: 7));
    _targetType = a?.targetType ?? 'all';
    _existingImageUrl = a?.imageUrl;

    if (a != null && a.targetType == 'specific' && a.targets.isNotEmpty) {
      final firstTarget = a.targets[0];
      _selectedClassId = firstTarget['class_id'];
      _selectedStreamId = firstTarget['stream_id'];
      _selectedSectionIds = List<int>.from(firstTarget['section_ids'] ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Image Source", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3E9FF),
            Colors.white,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF0038A8),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.announcement == null ? "CREATE ANNOUNCEMENT" : "EDIT ANNOUNCEMENT",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("General Details"),
              _buildTextField("Title", _titleController, "Enter title"),
              const SizedBox(height: 16),
              _buildTextField("Description", _descController, "Enter description", maxLines: 4),
              const SizedBox(height: 16),
              
              _buildDropdownSection("Announcement Type", 
                Obx(() => DropdownButtonFormField<int>(
                  value: _selectedTypeId,
                  items: controller.announcementTypes.map((type) {
                    return DropdownMenuItem(value: type.id, child: Text(type.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTypeId = val),
                  decoration: _inputDecoration("Select Type"),
                  validator: (val) => val == null ? "Required" : null,
                ))
              ),
              const SizedBox(height: 16),
              _buildSectionTitle("Image (Optional)"),
              _buildImagePicker(screenHeight),

              const SizedBox(height: 24),
              _buildSectionTitle("Schedule"),
              Row(
                children: [
                  Expanded(child: _buildDatePicker("From Date", _fromDate, (date) => setState(() => _fromDate = date))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDatePicker("To Date", _toDate, (date) => setState(() => _toDate = date))),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Target Audience"),
              Row(
                children: [
                  _buildRadioButton("All Students", 'all'),
                  const SizedBox(width: 20),
                  _buildRadioButton("Specific", 'specific'),
                ],
              ),

              if (_targetType == 'specific') ...[
                const SizedBox(height: 16),
                _buildSpecificTargetingFields(),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.announcement == null ? "CREATE ANNOUNCEMENT" : "UPDATE ANNOUNCEMENT",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                )),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: _inputDecoration(hint),
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildDropdownSection(String label, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        dropdown,
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) onSelect(date);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"),
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioButton(String title, String value) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _targetType = value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: _targetType,
              onChanged: (val) => setState(() => _targetType = val!),
              activeColor: const Color(0xFF1E293B),
            ),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificTargetingFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Obx(() => DropdownButtonFormField<int>(
            value: _selectedClassId,
            items: controller.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => _selectedClassId = val),
            decoration: _inputDecoration("Select Class"),
          )),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<int>(
            value: _selectedStreamId,
            items: controller.streams.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
            onChanged: (val) => setState(() => _selectedStreamId = val),
            decoration: _inputDecoration("Select Stream"),
          )),
          const SizedBox(height: 12),
          _buildMultiSelectSections(),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Sections", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          children: controller.sections.map((section) {
            final isSelected = _selectedSectionIds.contains(section.id);
            return FilterChip(
              label: Text(section.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSectionIds.add(section.id);
                  } else {
                    _selectedSectionIds.remove(section.id);
                  }
                });
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildImagePicker(double screenHeight) {
    return InkWell(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: screenHeight * 0.2, // Responsive height (20% of screen)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _imageFile == null && _existingImageUrl == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text("Add Image", style: TextStyle(color: Colors.grey)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Image.network(_existingImageUrl!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => setState(() {
                        _imageFile = null;
                        _existingImageUrl = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTypeId == null) {
        Get.snackbar("Error", "Please select an announcement type", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      List<Map<String, dynamic>>? targets;
      if (_targetType == 'specific') {
        if (_selectedClassId == null || _selectedStreamId == null || _selectedSectionIds.isEmpty) {
          Get.snackbar("Error", "Please complete targeting selection", backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        targets = [
          {
            "class_id": _selectedClassId,
            "stream_id": _selectedStreamId,
            "section_ids": _selectedSectionIds,
          }
        ];
      }

      if (widget.announcement == null) {
        controller.createAnnouncement(
          title: _titleController.text,
          description: _descController.text,
          typeId: _selectedTypeId!,
          image: _imageFile,
          fromDate: "${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}",
          toDate: "${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}",
          targetType: _targetType,
          targets: targets,
        );
      } else {
        controller.updateAnnouncement(
          id: widget.announcement!.id,
          title: _titleController.text,
          description: _descController.text,
          typeId: _selectedTypeId!,
          image: _imageFile,
          fromDate: "${_fromDate.year}-${_fromDate.month.toString().padLeft(2, '0')}-${_fromDate.day.toString().padLeft(2, '0')}",
          toDate: "${_toDate.year}-${_toDate.month.toString().padLeft(2, '0')}-${_toDate.day.toString().padLeft(2, '0')}",
          targetType: _targetType,
          targets: targets,
        );
      }
    }
  }
}

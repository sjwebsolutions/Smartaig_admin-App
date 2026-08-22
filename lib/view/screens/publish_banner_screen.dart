import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/banner_model.dart';
import '../../view_models/getX/banner_controller.dart';

class PublishBannerScreen extends StatefulWidget {
  final BannerModel banner;
  const PublishBannerScreen({super.key, required this.banner});

  @override
  State<PublishBannerScreen> createState() => _PublishBannerScreenState();
}

class _PublishBannerScreenState extends State<PublishBannerScreen> {
  final BannerController controller = Get.find<BannerController>();
  final _formKey = GlobalKey<FormState>();

  late bool _audienceParents;
  late bool _audienceTeachers;
  late String _targetType;
  late TextEditingController _daysController;
  final List<int> _selectedClassIds = [];

  @override
  void initState() {
    super.initState();
    // Initialize with existing banner data
    _audienceParents = widget.banner.targetedAudiences.contains('Parents');
    _audienceTeachers = widget.banner.targetedAudiences.contains('Teachers');
    _targetType = widget.banner.targetType.toLowerCase() == 'specific'
        ? 'specific'
        : 'all';
    _daysController = TextEditingController(
      text: widget.banner.displayDays.toString(),
    );

    if (widget.banner.targetedClassIds.isNotEmpty) {
      _selectedClassIds.addAll(
        widget.banner.targetedClassIds
            .map((e) => int.tryParse(e.toString()) ?? 0)
            .where((e) => e != 0),
      );
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_audienceParents && !_audienceTeachers) {
      Get.snackbar(
        "Error",
        "Please select at least one audience",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_targetType == 'specific' && _selectedClassIds.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one class for specific targeting",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    controller.publishBanner(
      id: widget.banner.id,
      audienceParents: _audienceParents ? 1 : 0,
      audienceTeachers: _audienceTeachers ? 1 : 0,
      targetType: _targetType,
      classIds: _targetType == 'specific' ? _selectedClassIds : null,
      displayDays: int.tryParse(_daysController.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF8F9FE)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: const Color(0xFFF8F9FE),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: const Color(0xFF1E293B),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "PUBLISH SETTINGS",
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Preview Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Image.network(
                          widget.banner.imageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: Colors.grey[100],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.banner.bannerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Target Audience Section
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 20,
                        color: Color(0xFF0038A8),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "TARGET AUDIENCE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCheckboxTile(
                            title: "Parents",
                            value: _audienceParents,
                            onChanged: (val) =>
                                setState(() => _audienceParents = val ?? false),
                          ),
                        ),
                        Expanded(
                          child: _buildCheckboxTile(
                            title: "Teachers",
                            value: _audienceTeachers,
                            onChanged: (val) => setState(
                              () => _audienceTeachers = val ?? false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Target Type Section
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.track_changes_rounded,
                        size: 20,
                        color: Color(0xFF0038A8),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "TARGET TYPE",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInlineRadioTile(
                                "All Students",
                                "all",
                              ),
                            ),
                            Expanded(
                              child: _buildInlineRadioTile(
                                "Specific Classes",
                                "specific",
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_targetType == 'specific') ...[
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _buildClassSelection(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Duration Section
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Color(0xFF0038A8),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "DISPLAY DURATION",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "How many days should this banner be visible?",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              int? val = int.tryParse(value);
                              if (val != null && (val > 5 || val == 0)) {
                                _daysController.clear();
                                Get.snackbar(
                                  "Alert",
                                  "Only 1 to 5 days are allowed",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            }
                          },
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          decoration: _inputDecoration(
                            "Enter days (1-5)",
                            suffix: "DAYS",
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Required";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isPublishing.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0038A8),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0xFF1E2E5D).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isPublishing.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rocket_launch_rounded),
                                SizedBox(width: 10),
                                Text(
                                  "PUBLISH BANNER",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0038A8)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0038A8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0038A8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0038A8).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInlineRadioTile(String title, String value) {
    return InkWell(
      onTap: () => setState(() => _targetType = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: _targetType,
            onChanged: (val) => setState(() => _targetType = val!),
            activeColor: const Color(0xFF0038A8),
            visualDensity: VisualDensity.compact,
          ),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: value,
      groupValue: _targetType,
      onChanged: (val) => setState(() => _targetType = val!),
      activeColor: const Color(0xFF0038A8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildClassSelection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Obx(() {
        if (controller.isLoadingClasses.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.bannerClasses.map((c) {
            final isSelected = _selectedClassIds.contains(c.id);
            return FilterChip(
              label: Text(c.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedClassIds.add(c.id);
                  } else {
                    _selectedClassIds.remove(c.id);
                  }
                });
              },
              selectedColor: const Color(0xFF0038A8).withOpacity(0.1),
              checkmarkColor: const Color(0xFF0038A8),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF0038A8)
                    : const Color(0xFF1E293B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF0038A8)
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      suffixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF0038A8),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      counterText: "",
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0038A8), width: 2),
      ),
    );
  }
}
